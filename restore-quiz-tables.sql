-- ============================================
-- 삭제된 퀴즈 관련 테이블 및 뷰 복구
-- ============================================
-- 작성일: 2026-05-02
-- 설명: drop-unused-tables-revised.sql 실행으로 삭제된
--       퀴즈 관련 테이블과 학습 진도율 뷰를 복구합니다.
--
-- 복구 대상:
-- 1. quizzes (퀴즈 기본 테이블)
-- 2. quiz_questions (퀴즈 문제 테이블)
-- 3. user_quiz_results (사용자 퀴즈 결과 테이블)
-- 4. user_learning_progress (학습 진도율 뷰)
-- ============================================

-- ============================================
-- 1. QUIZZES TABLE (퀴즈 기본 테이블)
-- ============================================
CREATE TABLE IF NOT EXISTS public.quizzes (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES public.categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Quizzes are viewable by everyone"
  ON public.quizzes FOR SELECT
  USING (true);

-- ============================================
-- 2. QUIZ QUESTIONS TABLE (퀴즈 문제 테이블)
-- ============================================
CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id SERIAL PRIMARY KEY,
  quiz_id INTEGER REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options JSONB NOT NULL, -- Array of options: ["Option 1", "Option 2", ...]
  correct_answer INTEGER NOT NULL, -- Index of correct option (0-based)
  explanation TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Quiz questions are viewable by everyone"
  ON public.quiz_questions FOR SELECT
  USING (true);

-- ============================================
-- 3. USER QUIZ RESULTS TABLE (사용자 퀴즈 결과 테이블)
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

CREATE POLICY "Users can view own quiz results"
  ON public.user_quiz_results FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz results"
  ON public.user_quiz_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 4. INDEXES (인덱스)
-- ============================================

-- Quiz Questions
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON public.quiz_questions(quiz_id);

-- User Quiz Results
CREATE INDEX IF NOT EXISTS idx_user_quiz_results_user ON public.user_quiz_results(user_id);
CREATE INDEX IF NOT EXISTS idx_user_quiz_results_quiz ON public.user_quiz_results(quiz_id);

-- ============================================
-- 5. USER LEARNING PROGRESS VIEW (학습 진도율 뷰)
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
-- 복구 완료 확인
-- ============================================
-- 아래 쿼리로 테이블과 뷰가 복구되었는지 확인할 수 있습니다:
--
-- SELECT table_name, table_type
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_name IN (
--     'quizzes', 'quiz_questions', 'user_quiz_results', 'user_learning_progress'
--   )
-- ORDER BY table_type, table_name;
--
-- 예상 결과: 3개의 BASE TABLE과 1개의 VIEW
-- ============================================
