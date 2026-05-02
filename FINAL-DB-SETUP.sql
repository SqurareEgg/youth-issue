-- ============================================
-- 청년정책 플랫폼 최종 DB 설정 스크립트
-- ============================================
-- 작성일: 2026-05-02
-- 버전: 1.0
-- 
-- 이 스크립트는 다음 순서로 실행됩니다:
-- 1. setup-minimal-quiz-structure.sql - 퀴즈 메타데이터 및 진도율 뷰
-- 2. create-policy-bookmarks-table.sql - 정책 북마크 테이블
-- 3. cleanup-unused-tables-final.sql - 불필요한 테이블 정리
--
-- ⚠️ 주의: 이 스크립트는 기존 데이터를 삭제합니다!
-- ============================================

-- 실행 방법:
-- Supabase Dashboard → SQL Editor에서 이 파일의 내용을 복사하여 실행
-- 또는 아래 3개 파일을 순서대로 실행:
--   1. setup-minimal-quiz-structure.sql
--   2. create-policy-bookmarks-table.sql  
--   3. cleanup-unused-tables-final.sql

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

-- ============================================
-- Step 2: 정책 북마크 테이블 생성
-- ============================================

-- ============================================
-- 정책 북마크 테이블 생성
-- ============================================
-- 작성일: 2026-05-02
-- 목적: 하드코딩된 정책 데이터의 북마크 기능 지원
-- ============================================

-- ============================================
-- USER POLICY BOOKMARKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_policy_bookmarks (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  bookmark_key TEXT NOT NULL, -- 예: "job-1-2" (category-policyId-detailId)
  category TEXT NOT NULL, -- 카테고리 슬러그 (job, housing, etc.)
  policy_id INTEGER NOT NULL, -- 세부 정책 번호 (1-6)
  detail_id INTEGER NOT NULL, -- 상세 정책 번호
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, bookmark_key)
);

ALTER TABLE public.user_policy_bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own policy bookmarks" ON public.user_policy_bookmarks;
CREATE POLICY "Users can view own policy bookmarks"
  ON public.user_policy_bookmarks FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own policy bookmarks" ON public.user_policy_bookmarks;
CREATE POLICY "Users can insert own policy bookmarks"
  ON public.user_policy_bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own policy bookmarks" ON public.user_policy_bookmarks;
CREATE POLICY "Users can delete own policy bookmarks"
  ON public.user_policy_bookmarks FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_policy_bookmarks_user ON public.user_policy_bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_user_policy_bookmarks_key ON public.user_policy_bookmarks(bookmark_key);
CREATE INDEX IF NOT EXISTS idx_user_policy_bookmarks_category ON public.user_policy_bookmarks(category);

-- ============================================
-- 확인 쿼리
-- ============================================
-- SELECT * FROM user_policy_bookmarks ORDER BY created_at DESC;

-- ============================================
-- Step 3: 불필요한 테이블 정리
-- ============================================

-- ============================================
-- 하드코딩 전환 후 불필요한 테이블 정리 (최종)
-- ============================================
-- 작성일: 2026-05-02
-- 설명: 정책, 퀴즈 문제, Q&A 데이터를 하드코딩으로 전환한 후
--       불필요해진 콘텐츠 테이블을 삭제합니다.
--
-- ⚠️ 주의: 이 스크립트는 setup-minimal-quiz-structure.sql 실행 후
--          실행해야 합니다.
--
-- 삭제 대상:
-- 1. policy_full_view (뷰) - 정책 데이터 하드코딩으로 미사용
-- 2. policy_details (테이블) - 정책 상세 하드코딩으로 미사용
-- 3. policies (테이블) - 정책 기본 정보 하드코딩으로 미사용
-- 4. quiz_questions (테이블) - 퀴즈 문제 하드코딩으로 미사용
-- 5. qna (테이블) - Q&A 하드코딩으로 미사용
-- 6. user_bookmarks (테이블) - 북마크 기능 미사용
--
-- 유지:
-- ✅ quizzes - 퀴즈 메타데이터 (user_quiz_results 외래 키 참조용)
-- ✅ user_quiz_results - 사용자 퀴즈 결과
-- ✅ user_policy_bookmarks - 정책 북마크 (하드코딩 정책용)
-- ✅ user_learning_progress - 학습 진도율 뷰
-- ✅ videos, user_video_progress - 영상 학습 관련
-- ✅ categories, profiles, page_views - 기본 데이터
-- ============================================

-- ============================================
-- 1단계: 뷰 삭제
-- ============================================
DROP VIEW IF EXISTS public.policy_full_view CASCADE;

-- ============================================
-- 2단계: 종속 테이블 삭제
-- ============================================
DROP TABLE IF EXISTS public.user_bookmarks CASCADE;
DROP TABLE IF EXISTS public.policy_details CASCADE;
DROP TABLE IF EXISTS public.quiz_questions CASCADE;

-- ============================================
-- 3단계: 기본 테이블 삭제
-- ============================================
DROP TABLE IF EXISTS public.policies CASCADE;
DROP TABLE IF EXISTS public.qna CASCADE;

-- ============================================
-- 삭제 완료 확인
-- ============================================
-- 아래 쿼리로 테이블/뷰가 삭제되었는지 확인할 수 있습니다:
--
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_name IN (
--     'policy_full_view', 'user_bookmarks', 'policy_details',
--     'quiz_questions', 'policies', 'qna'
--   );
--
-- (결과가 0개여야 정상)
--
-- ============================================
-- 남아있는 테이블 확인
-- ============================================
-- SELECT table_name, table_type
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_type IN ('BASE TABLE', 'VIEW')
-- ORDER BY table_type, table_name;
--
-- 예상 결과:
-- 📌 BASE TABLE:
--   - categories (카테고리 기본 정보)
--   - page_views (페이지 방문 통계)
--   - profiles (사용자 정보)
--   - quizzes (퀴즈 메타데이터)
--   - user_quiz_results (사용자 퀴즈 결과)
--   - user_video_progress (영상 시청 기록)
--   - videos (영상 콘텐츠)
--
-- 📊 VIEW:
--   - category_analytics (카테고리별 분석)
--   - category_user_visits (카테고리 사용자 방문)
--   - category_session_visits (카테고리 세션 방문)
--   - user_learning_progress (학습 진도율)
-- ============================================
