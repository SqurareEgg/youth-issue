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
