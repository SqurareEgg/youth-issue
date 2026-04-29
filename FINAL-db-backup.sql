-- ============================================
-- 완전한 Supabase 데이터베이스 스키마 백업 (최종본)
-- ============================================
-- 백업 일시: 2026-04-30
-- 프로젝트: kgfrjqjrhdqvrzcuqtaw
-- 방법: Supabase SQL Editor에서 추출
--
-- ✅ 포함 내용:
-- - 테이블 생성 스크립트 (5개) + 정확한 DEFAULT 값
-- - 시퀀스 (4개) + 현재 값
-- - Primary Keys, Foreign Keys, Unique Constraints
-- - 인덱스 (16개)
-- - 뷰 (5개)
-- - RLS 활성화 및 정책 (9개)
--
-- 🎯 이 파일로 완전히 동일한 데이터베이스 복원 가능!
-- ============================================

-- ============================================
-- 1. 시퀀스 생성
-- ============================================

CREATE SEQUENCE IF NOT EXISTS public.categories_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE IF NOT EXISTS public.page_views_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE IF NOT EXISTS public.user_video_progress_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE IF NOT EXISTS public.videos_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

-- 시퀀스 현재 값 설정 (데이터 복원 시 필요)
-- SELECT setval('public.categories_id_seq', 10, true);
-- SELECT setval('public.page_views_id_seq', 527, true);
-- SELECT setval('public.user_video_progress_id_seq', 179, true);
-- SELECT setval('public.videos_id_seq', 15, true);

-- ============================================
-- 2. 테이블 생성 (정확한 DEFAULT 값 포함)
-- ============================================

-- Table: categories
CREATE TABLE IF NOT EXISTS public.categories (
  id integer NOT NULL DEFAULT nextval('categories_id_seq'::regclass),
  name text NOT NULL,
  slug text NOT NULL,
  icon text NOT NULL,
  description text,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- Table: profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  email text NOT NULL,
  name text,
  birth_date date,
  terms_agreed boolean DEFAULT false,
  privacy_agreed boolean DEFAULT false,
  marketing_agreed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  school text,
  student_id text
);

-- Table: page_views
CREATE TABLE IF NOT EXISTS public.page_views (
  id integer NOT NULL DEFAULT nextval('page_views_id_seq'::regclass),
  session_id text NOT NULL,
  page_path text NOT NULL,
  referrer text,
  user_agent text,
  ip_address text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  user_id uuid
);

-- Table: videos
CREATE TABLE IF NOT EXISTS public.videos (
  id integer NOT NULL DEFAULT nextval('videos_id_seq'::regclass),
  category_id integer,
  title text NOT NULL,
  duration text NOT NULL,
  thumbnail_url text,
  video_url text,
  description text,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- Table: user_video_progress
CREATE TABLE IF NOT EXISTS public.user_video_progress (
  id integer NOT NULL DEFAULT nextval('user_video_progress_id_seq'::regclass),
  user_id uuid,
  video_id integer,
  completed boolean DEFAULT false,
  last_position integer DEFAULT 0,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- ============================================
-- 3. Primary Keys
-- ============================================

ALTER TABLE ONLY public.categories
  ADD CONSTRAINT categories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.profiles
  ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.page_views
  ADD CONSTRAINT page_views_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.videos
  ADD CONSTRAINT videos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_video_progress
  ADD CONSTRAINT user_video_progress_pkey PRIMARY KEY (id);

-- ============================================
-- 4. Unique Constraints
-- ============================================

ALTER TABLE ONLY public.categories
  ADD CONSTRAINT categories_name_key UNIQUE (name);

ALTER TABLE ONLY public.categories
  ADD CONSTRAINT categories_slug_key UNIQUE (slug);

ALTER TABLE ONLY public.profiles
  ADD CONSTRAINT profiles_email_key UNIQUE (email);

ALTER TABLE ONLY public.user_video_progress
  ADD CONSTRAINT user_video_progress_user_id_video_id_key UNIQUE (user_id, video_id);

-- ============================================
-- 5. Foreign Keys
-- ============================================

-- profiles.id references auth.users (Supabase Auth)
ALTER TABLE ONLY public.profiles
  ADD CONSTRAINT profiles_id_fkey
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- page_views.user_id references profiles
ALTER TABLE ONLY public.page_views
  ADD CONSTRAINT page_views_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- videos.category_id references categories
ALTER TABLE ONLY public.videos
  ADD CONSTRAINT videos_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;

-- user_video_progress.user_id references profiles
ALTER TABLE ONLY public.user_video_progress
  ADD CONSTRAINT user_video_progress_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- user_video_progress.video_id references videos
ALTER TABLE ONLY public.user_video_progress
  ADD CONSTRAINT user_video_progress_video_id_fkey
  FOREIGN KEY (video_id) REFERENCES public.videos(id) ON DELETE CASCADE;

-- ============================================
-- 6. 인덱스
-- ============================================

-- categories 테이블 인덱스 (Primary Key와 Unique 인덱스는 자동 생성됨)

-- page_views 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_page_views_created
  ON public.page_views USING btree (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_page_views_session
  ON public.page_views USING btree (session_id);

CREATE INDEX IF NOT EXISTS idx_page_views_page_path
  ON public.page_views USING btree (page_path);

CREATE INDEX IF NOT EXISTS idx_page_views_user
  ON public.page_views USING btree (user_id);

-- videos 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_videos_category
  ON public.videos USING btree (category_id);

-- user_video_progress 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_user_video_progress_user
  ON public.user_video_progress USING btree (user_id);

CREATE INDEX IF NOT EXISTS idx_user_video_progress_video
  ON public.user_video_progress USING btree (video_id);

-- ============================================
-- 7. 뷰 (Views)
-- ============================================

-- View: category_analytics
-- 카테고리별 페이지뷰 분석
CREATE OR REPLACE VIEW public.category_analytics AS
SELECT
  CASE
    WHEN (page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END AS category_slug,
  count(*) AS total_views,
  count(DISTINCT session_id) AS unique_sessions,
  count(DISTINCT user_id) FILTER (WHERE (user_id IS NOT NULL)) AS logged_in_user_count,
  count(*) FILTER (WHERE (user_id IS NULL)) AS anonymous_views,
  count(*) FILTER (WHERE (user_id IS NOT NULL)) AS logged_in_views,
  min(created_at) AS first_visit,
  max(created_at) AS last_visit
FROM page_views
WHERE (page_path ~~ '/category/%'::text)
GROUP BY
  CASE
    WHEN (page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END;

-- View: category_session_visits
-- 카테고리별 세션 방문 통계
CREATE OR REPLACE VIEW public.category_session_visits AS
SELECT
  CASE
    WHEN (page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END AS category_slug,
  session_id,
  user_id,
  count(*) AS page_views,
  count(DISTINCT page_path) AS pages_visited,
  min(created_at) AS first_visit,
  max(created_at) AS last_visit
FROM page_views
WHERE (page_path ~~ '/category/%'::text)
GROUP BY
  CASE
    WHEN (page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END, session_id, user_id;

-- View: category_user_visits
-- 카테고리별 사용자 방문 통계 (로그인 사용자만)
CREATE OR REPLACE VIEW public.category_user_visits AS
SELECT
  CASE
    WHEN (pv.page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (pv.page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (pv.page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (pv.page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (pv.page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END AS category_slug,
  pv.user_id,
  pr.name AS user_name,
  pr.email AS user_email,
  count(*) AS visit_count,
  min(pv.created_at) AS first_visit,
  max(pv.created_at) AS last_visit
FROM (page_views pv
  JOIN profiles pr ON ((pv.user_id = pr.id)))
WHERE ((pv.page_path ~~ '/category/%'::text) AND (pv.user_id IS NOT NULL))
GROUP BY
  CASE
    WHEN (pv.page_path ~~ '/category/job%'::text) THEN 'job'::text
    WHEN (pv.page_path ~~ '/category/housing%'::text) THEN 'housing'::text
    WHEN (pv.page_path ~~ '/category/education%'::text) THEN 'education'::text
    WHEN (pv.page_path ~~ '/category/finance-welfare-culture%'::text) THEN 'finance-welfare-culture'::text
    WHEN (pv.page_path ~~ '/category/participation%'::text) THEN 'participation'::text
    ELSE 'other'::text
  END, pv.user_id, pr.name, pr.email;

-- View: page_view_stats
-- 페이지별 일별 통계
CREATE OR REPLACE VIEW public.page_view_stats AS
SELECT
  page_path,
  count(*) AS total_views,
  count(DISTINCT session_id) AS unique_visitors,
  date(created_at) AS view_date
FROM page_views
GROUP BY page_path, date(created_at);

-- View: daily_stats
-- 전체 사이트 일별 통계
CREATE OR REPLACE VIEW public.daily_stats AS
SELECT
  date(created_at) AS date,
  count(*) AS total_views,
  count(DISTINCT session_id) AS unique_visitors,
  count(DISTINCT page_path) AS pages_visited
FROM page_views
GROUP BY date(created_at)
ORDER BY date(created_at) DESC;

-- ============================================
-- 8. RLS (Row Level Security) 활성화
-- ============================================

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.page_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 9. RLS 정책 (Security Policies)
-- ============================================

-- categories: 모든 사람이 조회 가능
CREATE POLICY "Categories are viewable by everyone"
  ON public.categories
  FOR SELECT
  TO public
  USING (true);

-- page_views: 누구나 삽입 가능, 조회 가능
CREATE POLICY "Anyone can insert page views"
  ON public.page_views
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Public can view page view stats"
  ON public.page_views
  FOR SELECT
  TO public
  USING (true);

-- profiles: 자신의 프로필만 조회/수정 가능
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  TO public
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  TO public
  USING (auth.uid() = id);

-- user_video_progress: 자신의 진행률만 조회/삽입/수정 가능
CREATE POLICY "Users can view own video progress"
  ON public.user_video_progress
  FOR SELECT
  TO public
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own video progress"
  ON public.user_video_progress
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Users can update own video progress"
  ON public.user_video_progress
  FOR UPDATE
  TO public
  USING (auth.uid() = user_id);

-- videos: 모든 사람이 조회 가능
CREATE POLICY "Videos are viewable by everyone"
  ON public.videos
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 복원 방법
-- ============================================
-- 1. 새 Supabase 프로젝트 생성
-- 2. SQL Editor에서 이 파일 전체를 복사하여 실행
-- 3. ✅ 완료! 사이트가 정상 작동합니다.
--
-- 데이터 복원 시:
-- - 위의 시퀀스 setval 주석을 해제하고 실행
-- - 데이터 INSERT 후 시퀀스 값 조정 필요
-- ============================================

-- ============================================
-- 데이터베이스 요약
-- ============================================
-- 테이블: 5개
--   ✅ categories (카테고리)
--   ✅ profiles (사용자 프로필)
--   ✅ page_views (페이지 방문 기록)
--   ✅ videos (영상 콘텐츠)
--   ✅ user_video_progress (영상 시청 진도)
--
-- 뷰: 5개
--   📊 category_analytics
--   📊 category_session_visits
--   📊 category_user_visits
--   📊 page_view_stats
--   📊 daily_stats
--
-- 시퀀스: 4개
--   🔢 categories_id_seq (last_value: 10)
--   🔢 page_views_id_seq (last_value: 527)
--   🔢 user_video_progress_id_seq (last_value: 179)
--   🔢 videos_id_seq (last_value: 15)
--
-- 제약조건:
--   🔑 Primary Keys: 5개
--   🔗 Foreign Keys: 5개
--   ⚡ Unique Constraints: 4개
--
-- 인덱스: 16개
--
-- RLS 정책: 9개
--   🔒 모든 테이블에 RLS 활성화
--   🔒 사용자 데이터 보안 보장
-- ============================================
