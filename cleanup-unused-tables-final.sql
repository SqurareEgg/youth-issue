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
