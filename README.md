# 청년있슈 - 청년을 위한 6가지 필수 정책 교육 플랫폼

> 청년을 위한 6가지 정책 카테고리를 영상과 퀴즈로 쉽고 재미있게 배우는 교육 플랫폼

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Vue](https://img.shields.io/badge/Vue-3.4.0-green.svg)
![Quasar](https://img.shields.io/badge/Quasar-2.14.0-1976D2.svg)
![Supabase](https://img.shields.io/badge/Supabase-2.91.1-3ECF8E.svg)

**🚀 Live Demo**: [https://youth-issue.vercel.app](https://youth-issue.vercel.app)

## 📋 프로젝트 개요

청년있슈는 청년들이 필요한 정책 정보를 쉽게 찾고 학습할 수 있도록 돕는 통합 플랫폼입니다.
영상 교육, 퀴즈, Q&A를 통해 6가지 필수 청년 정책을 재미있게 배울 수 있습니다.

### 주요 특징

- 🎯 **6가지 청년 정책 카테고리**: 일자리, 주거, 교육, 금융·복지·문화, 참여
- 📚 **다양한 학습 콘텐츠**: 영상 강의, Q&A, OX 퀴즈
- 🔐 **이메일 인증 회원가입**: Supabase 인증 연동 (OTP 방식)
- 📊 **학습 진도 관리**: 영상 시청 기록 및 이수율 추적
- 📈 **방문 통계**: 카테고리별 방문자 통계 및 분석
- 📱 **반응형 디자인**: 모바일, 태블릿, 데스크톱 완벽 지원
- 🎨 **모던 UI/UX**: 직관적이고 사용하기 쉬운 인터페이스

## 🛠️ 기술 스택

### Frontend
- **Framework**: Vue 3 (Composition API + TypeScript)
- **UI Framework**: Quasar 2.14.0
- **Build Tool**: Vite
- **Router**: Vue Router 4
- **State Management**: Composables (Composition API)

### Backend (BaaS)
- **Auth & Database**: Supabase
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime (구독형 데이터)

### Deployment
- **Hosting**: Vercel
- **CI/CD**: Git push 시 자동 배포

## 🚀 시작하기

### 필수 요구사항

- Node.js >= 16.0.0
- npm >= 6.13.4

### 환경 변수 설정

`.env` 파일을 루트 디렉토리에 생성하고 다음 내용을 추가하세요:

```bash
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/SqurareEgg/youth-issue.git
cd youth-issue

# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
```

개발 서버가 시작되면 브라우저에서 `http://localhost:9003`으로 접속합니다.

### 프로덕션 빌드

```bash
npm run build
```

빌드된 파일은 `dist/spa/` 디렉토리에 생성됩니다.

## 📁 프로젝트 구조

```
youth-issue/
├── src/
│   ├── components/
│   │   └── figma/              # UI 컴포넌트
│   ├── composables/            # Vue Composables
│   │   ├── useAuth.ts          # 인증 관리
│   │   ├── useCategories.ts    # 카테고리 데이터
│   │   ├── useLearning.ts      # 학습 콘텐츠 관리
│   │   ├── usePolicies.ts      # 정책 데이터
│   │   ├── usePageViews.ts     # 페이지 방문 통계
│   │   └── useMeta.ts          # SEO 메타 태그
│   ├── lib/
│   │   └── supabase.ts         # Supabase 클라이언트
│   ├── pages/                  # 페이지 컴포넌트
│   ├── router/                 # 라우터 설정
│   ├── types/
│   │   └── supabase.ts         # TypeScript 타입 정의
│   └── App.vue
├── public/                     # 정적 파일
├── supabase/                   # Supabase 관련 파일
│   ├── migrations/             # 데이터베이스 마이그레이션
│   └── seed.sql                # 시드 데이터
└── docs/                       # 문서
```

## 🗺️ 주요 기능

### 1. 인증 시스템
- 이메일 + OTP 인증 회원가입
- 로그인/로그아웃
- 프로필 관리 (학교, 학번 포함)

### 2. 카테고리 학습
- 6가지 정책 카테고리별 콘텐츠
- 카테고리별 영상 강의
- Q&A 섹션
- OX 퀴즈

### 3. 학습 진도 관리
- 영상 시청 진행률 자동 저장
- 마지막 시청 위치 복원
- 80% 이상 시청 시 자동 완료
- 카테고리별 이수율 계산

### 4. 방문 통계
- 페이지 방문 기록 (세션 추적)
- 카테고리별 방문자 통계
- 일별/사용자별 분석
- 관리자 대시보드 (예정)

## 📊 데이터베이스 스키마

주요 테이블:
- `profiles`: 사용자 프로필
- `categories`: 정책 카테고리
- `videos`: 영상 콘텐츠
- `user_video_progress`: 영상 시청 기록
- `page_views`: 페이지 방문 통계

상세 스키마는 `supabase-schema.sql` 파일 참고

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: #F97316 (Orange 500)
- **Secondary**: #3B82F6 (Blue 500)
- **일자리**: Blue Gradient
- **주거**: Orange Gradient
- **교육**: Green Gradient
- **금융·복지·문화**: Pink Gradient
- **참여**: Teal Gradient

### 반응형 브레이크포인트
- Mobile: < 768px
- Tablet: 768px ~ 1024px
- Desktop: > 1024px

## 🔒 보안

- Row Level Security (RLS) 정책 적용
- 사용자별 데이터 접근 제어
- 환경 변수로 민감 정보 관리
- HTTPS 통신

## 📈 SEO 최적화

- 캐노니컬 태그로 원본 사이트 명시
- Open Graph 메타 태그 (SNS 공유 최적화)
- Twitter Card 지원
- 페이지별 동적 메타 태그
- robots.txt 설정

## 🧪 테스트

```bash
# Lint 검사
npm run lint
```

## 📝 개발 가이드

### 새 페이지 추가
1. `src/pages/`에 Vue 파일 생성
2. `src/router/routes.js`에 라우트 추가
3. 필요시 composable 생성

### 새 카테고리 추가
1. Supabase `categories` 테이블에 데이터 추가
2. 관련 영상/퀴즈 데이터 추가
3. `useMeta.ts`의 `categoryMeta`에 메타 정보 추가

## 🐛 트러블슈팅

### Supabase 연결 오류
- `.env` 파일의 환경 변수 확인
- Supabase 프로젝트 URL 및 Key 확인

### 영상 재생 안됨
- Supabase `videos` 테이블의 `video_url` 확인
- YouTube URL 형식 확인

### 빌드 에러
```bash
# node_modules 삭제 후 재설치
rm -rf node_modules
npm install
```

## 🚀 배포

### Vercel 배포

```bash
# Vercel CLI 설치
npm i -g vercel

# 배포
vercel

# 프로덕션 배포
vercel --prod
```

또는 GitHub 연동으로 자동 배포

## 📄 문서

- [데이터베이스 설정 가이드](docs/DATABASE_SETUP_STEPS.md)
- [이수율 계산 가이드](docs/COMPLETION_RATE_GUIDE.md)
- [Supabase 통합 가이드](docs/SUPABASE_INTEGRATION.md)
- [SEO 설정 가이드](SEO-SETUP-GUIDE.md)

## 📞 지원

- **이슈 리포트**: [GitHub Issues](https://github.com/SqurareEgg/youth-issue/issues)
- **문의**: GitHub Discussions

## 📄 라이선스

이 프로젝트는 비공개 프로젝트입니다.

---

**마지막 업데이트**: 2026-04-30
**버전**: 1.0.0
