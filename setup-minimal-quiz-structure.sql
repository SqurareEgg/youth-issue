-- ============================================
-- 최소 퀴즈 구조 설정 및 시드 데이터
-- ============================================
-- 작성일: 2026-05-02
-- 목적: 하드코딩된 퀴즈 데이터를 사용하되,
--       사용자 진행 상태 추적을 위한 최소한의 DB 구조 유지
--
-- 구조:
-- 1. quizzes 테이블 - 퀴즈 메타데이터만 저장 (외래 키 참조용)
-- 2. user_quiz_results - 사용자 퀴즈 결과 저장
-- 3. user_learning_progress 뷰 - 학습 진도율 계산
-- ============================================

-- ============================================
-- 1. QUIZZES TABLE (최소 메타데이터만)
-- ============================================
CREATE TABLE IF NOT EXISTS public.quizzes (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES public.categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Quizzes are viewable by everyone" ON public.quizzes;
CREATE POLICY "Quizzes are viewable by everyone"
  ON public.quizzes FOR SELECT
  USING (true);

-- ============================================
-- 2. USER QUIZ RESULTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_quiz_results (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  quiz_id INTEGER REFERENCES public.quizzes(id) ON DELETE CASCADE,
  score INTEGER NOT NULL, -- 0-100
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  answers JSONB, -- User's answers: {"1": 0, "2": 2, ...} (question_id: selected_option_index)
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE public.user_quiz_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own quiz results" ON public.user_quiz_results;
CREATE POLICY "Users can view own quiz results"
  ON public.user_quiz_results FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own quiz results" ON public.user_quiz_results;
CREATE POLICY "Users can insert own quiz results"
  ON public.user_quiz_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 3. INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_quiz_results_user ON public.user_quiz_results(user_id);
CREATE INDEX IF NOT EXISTS idx_user_quiz_results_quiz ON public.user_quiz_results(quiz_id);

-- ============================================
-- 4. USER LEARNING PROGRESS VIEW
-- ============================================
DROP VIEW IF EXISTS user_learning_progress;

CREATE OR REPLACE VIEW user_learning_progress AS
WITH video_progress AS (
  SELECT
    p.id AS user_id,
    v.category_id,
    COUNT(v.id) AS total_videos,
    COUNT(CASE WHEN uvp.completed = true THEN 1 END) AS completed_videos
  FROM public.profiles p
  CROSS JOIN public.videos v
  LEFT JOIN public.user_video_progress uvp
    ON v.id = uvp.video_id AND p.id = uvp.user_id
  GROUP BY p.id, v.category_id
),
quiz_progress AS (
  SELECT
    p.id AS user_id,
    q.category_id,
    COUNT(DISTINCT q.id) AS total_quizzes,
    COUNT(DISTINCT CASE WHEN uqr.score >= 60 THEN q.id END) AS completed_quizzes
  FROM public.profiles p
  CROSS JOIN public.quizzes q
  LEFT JOIN (
    SELECT DISTINCT ON (user_id, quiz_id) *
    FROM public.user_quiz_results
    ORDER BY user_id, quiz_id, completed_at DESC
  ) uqr ON q.id = uqr.quiz_id AND p.id = uqr.user_id
  GROUP BY p.id, q.category_id
)
SELECT
  vp.user_id,
  vp.category_id,
  c.name AS category_name,
  vp.total_videos,
  vp.completed_videos,
  qp.total_quizzes,
  qp.completed_quizzes,
  (vp.total_videos + qp.total_quizzes) AS total_items,
  (vp.completed_videos + qp.completed_quizzes) AS completed_items,
  ROUND(
    (COALESCE(vp.completed_videos, 0) + COALESCE(qp.completed_quizzes, 0))::DECIMAL /
    NULLIF((COALESCE(vp.total_videos, 0) + COALESCE(qp.total_quizzes, 0)), 0) * 100,
    2
  ) AS completion_percentage
FROM video_progress vp
JOIN quiz_progress qp ON vp.user_id = qp.user_id AND vp.category_id = qp.category_id
JOIN public.categories c ON vp.category_id = c.id;

-- ============================================
-- 5. 퀴즈 메타데이터 시드 데이터
-- ============================================
-- 기존 퀴즈 데이터 삭제 (중복 방지)
TRUNCATE public.quizzes CASCADE;

-- 카테고리 ID를 먼저 확인
-- SELECT id, slug FROM public.categories;

-- 퀴즈 메타데이터 삽입
INSERT INTO public.quizzes (id, category_id, title, description) VALUES
  (1, 1, '일자리 정책 기본 Quiz', '일자리 정책의 기본 내용을 확인하는 퀴즈입니다.'),
  (2, 2, '주거 정책 기본 Quiz', '주거 정책의 기본 내용을 확인하는 퀴즈입니다.'),
  (3, 3, '교육 정책 기본 Quiz', '교육 정책의 기본 내용을 확인하는 퀴즈입니다.'),
  (4, 4, '금융·복지·문화 정책 기본 Quiz', '금융·복지·문화 정책의 기본 내용을 확인하는 퀴즈입니다.'),
  (5, 5, '참여·소통 정책 기본 Quiz', '참여·소통 정책의 기본 내용을 확인하는 퀴즈입니다.');

-- ID 시퀀스 리셋
SELECT setval('quizzes_id_seq', (SELECT MAX(id) FROM quizzes));

-- ============================================
-- 확인 쿼리
-- ============================================
-- SELECT q.id, q.title, c.name AS category_name, c.slug AS category_slug
-- FROM quizzes q
-- JOIN categories c ON q.category_id = c.id
-- ORDER BY q.id;
