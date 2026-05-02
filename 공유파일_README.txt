=====================================
청년정책 플랫폼 - 공유 파일 안내
=====================================
작성일: 2026-05-02

📦 포함된 파일
=====================================

1. FINAL-DB-SETUP.sql (13KB)
   - 최종 DB 설정 통합 스크립트
   - Supabase SQL Editor에서 실행
   - 퀴즈 메타데이터 + 북마크 테이블 생성 + 불필요한 테이블 정리

2. youth-issue-source.tar.gz (11MB)
   - 소스 코드 압축 파일
   - 포함 내용:
     * src/ - 소스 코드
     * public/ - 정적 파일
     * package.json, package-lock.json - 의존성
     * quasar.config.js - Quasar 설정
     * README.md - 프로젝트 설명
     * DB 마이그레이션 스크립트들

🚀 설치 및 실행 방법
=====================================

[1단계] DB 설정
1. Supabase 프로젝트 생성 (https://supabase.com)
2. SQL Editor 열기
3. FINAL-DB-SETUP.sql 파일 내용 복사 & 실행
4. 카테고리와 퀴즈 메타데이터 자동 생성됨

[2단계] 소스 코드 설정
1. youth-issue-source.tar.gz 압축 해제
   - Windows: 7-Zip, Bandizip 등 사용
   - Mac/Linux: tar -xzf youth-issue-source.tar.gz

2. 의존성 설치
   cd youth-issue
   npm install

3. 환경 변수 설정
   .env 파일 생성:
   VITE_SUPABASE_URL=your-supabase-url
   VITE_SUPABASE_ANON_KEY=your-supabase-anon-key

4. 개발 서버 실행
   npm run dev

5. 빌드 (프로덕션)
   npm run build

📊 DB 구조 설명
=====================================

유지되는 테이블 (8개):
- categories: 카테고리 정보
- profiles: 사용자 정보
- videos: 영상 콘텐츠
- user_video_progress: 영상 진행률
- quizzes: 퀴즈 메타데이터
- user_quiz_results: 퀴즈 결과
- user_policy_bookmarks: 정책 북마크
- page_views: 페이지 통계

뷰 (4개):
- user_learning_progress: 학습 진도율
- category_analytics: 카테고리 분석
- category_user_visits: 사용자 방문
- category_session_visits: 세션 방문

하드코딩된 데이터:
- 정책 (policies): FigmaPolicyDetailPage.vue
- 퀴즈 문제 (quiz_questions): FigmaQuizPage.vue
- Q&A (qna): FigmaQnAPage.vue

💡 주요 기능
=====================================

✅ 구현 완료:
- 카테고리별 정책 학습
- 영상 학습 및 진행률 추적
- 퀴즈 풀이 및 결과 저장
- 정책 북마크 (로그인/비로그인 모두 지원)
- 학습 진도율 계산
- 페이지 방문 통계
- 즉시 피드백 퀴즈 시스템

🔧 기술 스택
=====================================

Frontend:
- Vue 3 (Composition API)
- Quasar Framework
- TypeScript
- Vite

Backend:
- Supabase (PostgreSQL)
- Row Level Security (RLS)
- Views for analytics

📝 추가 정보
=====================================

상세 문서:
- DB-MIGRATION-GUIDE.md: DB 마이그레이션 가이드
- README.md: 프로젝트 전체 설명

문의사항이 있으시면 연락주세요!
