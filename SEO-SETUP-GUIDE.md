# SEO 및 메타 태그 설정 가이드

## ✅ 적용 완료 내용

### 1. 기본 SEO 메타 태그 (`index.html`)
- **캐노니컬 태그**: 검색 엔진에 원본 사이트임을 알림
- **Open Graph 태그**: 카카오톡, 페이스북 공유 시 표시되는 정보
- **Twitter Card 태그**: 트위터 공유 시 표시되는 정보
- **기타 SEO 태그**: robots, keywords, description 등

### 2. 동적 메타 태그 (`useMeta.ts`)
각 페이지별로 자동으로 메타 태그가 설정됩니다:
- **홈페이지** (`FigmaLandingPage.vue`)
- **카테고리 페이지** (`FigmaCategoryPage.vue`) - 카테고리별 동적 설정

---

## 🔧 실제 도메인으로 변경하는 방법

현재 임시로 `https://youth-policy.vercel.app`로 설정되어 있습니다.
**실제 도메인**이 결정되면 아래 파일들을 수정하세요:

### 1. `index.html` 수정

```html
<!-- 현재 (변경 전) -->
<link rel="canonical" href="https://youth-policy.vercel.app/">
<meta property="og:url" content="https://youth-policy.vercel.app/">
<meta property="og:image" content="https://youth-policy.vercel.app/og-image.jpg">

<!-- 변경 후 -->
<link rel="canonical" href="https://yourdomain.com/">
<meta property="og:url" content="https://yourdomain.com/">
<meta property="og:image" content="https://yourdomain.com/og-image.jpg">
```

### 2. `src/composables/useMeta.ts` 수정

파일 상단의 `BASE_URL` 변수를 수정:

```typescript
// 현재 (변경 전)
const BASE_URL = 'https://youth-policy.vercel.app'

// 변경 후
const BASE_URL = 'https://yourdomain.com'
```

---

## 📸 OG 이미지 준비

Open Graph 이미지를 준비해야 합니다:

### 이미지 규격
- **크기**: 1200 x 630 픽셀 (권장)
- **형식**: JPG 또는 PNG
- **파일명**: `og-image.jpg`
- **위치**: `public/` 폴더

### 카테고리별 이미지 (선택사항)
카테고리별로 다른 이미지를 사용하려면 다음 이미지들을 준비:
- `public/images/category-job.jpg`
- `public/images/category-housing.jpg`
- `public/images/category-education.jpg`
- `public/images/category-finance.jpg`
- `public/images/category-participation.jpg`

---

## 🎯 SEO 효과

### 1. 검색 엔진 최적화
- **캐노니컬 태그**: 중복 콘텐츠 문제 방지
- **구조화된 메타 데이터**: 검색 결과 노출 개선
- **키워드 최적화**: 청년정책, 청년복지 등

### 2. 소셜 미디어 최적화
- **카카오톡 공유**: 이미지, 제목, 설명이 자동으로 표시
- **페이스북/인스타그램**: Open Graph 태그 활용
- **트위터**: Twitter Card로 깔끔하게 표시

### 3. 도용 방지
- 다른 사이트가 코드를 복사해도 캐노니컬 URL은 원본을 가리킴
- 검색 엔진은 항상 원본 사이트를 우선순위로 인식

---

## 🧪 테스트 방법

### 1. Open Graph 태그 테스트
- **Facebook Debugger**: https://developers.facebook.com/tools/debug/
- **카카오톡 테스트**: 카카오톡에 URL 공유 후 확인
- **Twitter Card Validator**: https://cards-dev.twitter.com/validator

### 2. 구글 검색 최적화 확인
- **Google Search Console**: https://search.google.com/search-console
- **Rich Results Test**: https://search.google.com/test/rich-results

---

## 📝 추가 최적화 팁

### 1. 구조화된 데이터 (Schema.org)
나중에 추가하면 좋은 것:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "EducationalOrganization",
  "name": "청년있슈",
  "description": "청년을 위한 6가지 필수 정책 교육",
  "url": "https://yourdomain.com"
}
</script>
```

### 2. Sitemap 생성
검색 엔진이 모든 페이지를 찾을 수 있도록:
- `public/sitemap.xml` 파일 생성
- Google Search Console에 제출

### 3. robots.txt
크롤링 규칙 설정:
- `public/robots.txt` 파일 생성

---

## ❓ FAQ

**Q: 메타 태그가 반영되려면 얼마나 걸리나요?**
A: 구글 검색 결과에는 며칠~몇 주, 카카오톡/페이스북은 캐시를 삭제하면 즉시 반영됩니다.

**Q: OG 이미지가 카카오톡에 안 뜹니다.**
A: 카카오톡 캐시 삭제가 필요합니다. https://developers.kakao.com/tool/clear/og 에서 URL 입력 후 캐시 삭제하세요.

**Q: 페이지마다 다른 메타 태그를 설정하고 싶어요.**
A: 각 페이지의 `<script setup>`에 `useMeta()` 호출을 추가하면 됩니다.

```typescript
// 예시: FigmaQuizPage.vue
import { useMeta } from '../composables/useMeta'

useMeta({
  title: '퀴즈 풀기',
  description: '청년 정책 퀴즈를 풀고 이해도를 확인하세요',
  canonicalUrl: 'https://yourdomain.com/quiz'
})
```

---

## 📞 문제 해결

메타 태그 관련 문제가 생기면:
1. 브라우저 개발자 도구(F12) > Elements 탭에서 `<head>` 확인
2. `<meta>` 태그들이 올바르게 삽입되었는지 확인
3. 캐시 삭제 후 재테스트

---

**작성일**: 2026-04-30
**버전**: 1.0
