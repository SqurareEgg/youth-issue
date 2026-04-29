# 프로젝트명 변경 가이드

프로젝트명을 "youth-policy-figma"에서 "youth-issue"로 변경하는 가이드입니다.

---

## ✅ 이미 완료된 작업

### 1. **package.json** ✅
- `name`: `"youth-policy-figma"` → `"youth-issue"`
- `description`: Figma 언급 제거

### 2. **README.md** ✅
- 모든 Figma 관련 내용 제거
- 프로젝트 설명 업데이트
- 저장소 URL 변경: `youth-policy-figma` → `youth-issue`

### 3. **SEO 메타 태그** ✅
- `index.html`: 메타 태그에서 Figma 언급 제거
- `useMeta.ts`: SEO 최적화 설정 완료

---

## 🔧 수동으로 변경해야 할 것들

### 1. **GitHub 저장소명 변경**

현재 저장소: `https://github.com/SqurareEgg/youth-policy-figma`

#### 변경 방법:
1. GitHub 저장소 페이지 접속
2. **Settings** 탭 클릭
3. **General** > **Repository name** 섹션에서
4. `youth-policy-figma` → `youth-issue` 로 변경
5. **Rename** 버튼 클릭

#### 로컬 Git 원격 저장소 URL 업데이트:
```bash
# 현재 원격 저장소 확인
git remote -v

# 원격 저장소 URL 업데이트
git remote set-url origin https://github.com/SqurareEgg/youth-issue.git

# 확인
git remote -v
```

---

### 2. **Vercel 프로젝트명 변경**

현재 배포 URL: `https://youth-policy-figma.vercel.app`
목표 URL: `https://youth-issue.vercel.app`

#### 방법 A: Vercel 대시보드에서 변경

1. [Vercel Dashboard](https://vercel.com/dashboard) 접속
2. `youth-policy-figma` 프로젝트 선택
3. **Settings** 탭 클릭
4. **General** > **Project Name** 섹션에서
5. `youth-policy-figma` → `youth-issue` 로 변경
6. **Save** 버튼 클릭

> ⚠️ **주의**: 프로젝트명을 변경하면 배포 URL도 자동으로 변경됩니다.
> - 기존: `https://youth-policy-figma.vercel.app`
> - 새로운: `https://youth-issue.vercel.app`

#### 방법 B: Vercel CLI로 변경

```bash
# Vercel 로그인
vercel login

# 프로젝트 링크 해제
vercel unlink

# 새 이름으로 재배포
vercel --prod
# 프롬프트에서 프로젝트명을 "youth-issue"로 입력
```

---

### 3. **커스텀 도메인 설정 (선택사항)**

Vercel 기본 도메인 대신 커스텀 도메인을 사용하려면:

#### 예시: `youthissue.com` 또는 `youth-issue.kr`

1. Vercel Dashboard > 프로젝트 선택
2. **Settings** > **Domains** 탭
3. **Add Domain** 버튼 클릭
4. 도메인 입력 (예: `youthissue.com`)
5. DNS 레코드 설정:
   - **A 레코드**: `76.76.21.21`
   - **CNAME**: `cname.vercel-dns.com`
6. 도메인 인증 대기 (수 분~수 시간)

#### SEO 메타 태그 업데이트:
커스텀 도메인 설정 후 다음 파일들 수정:

**`index.html`**:
```html
<link rel="canonical" href="https://youthissue.com/">
<meta property="og:url" content="https://youthissue.com/">
<meta property="og:image" content="https://youthissue.com/og-image.jpg">
```

**`src/composables/useMeta.ts`**:
```typescript
const BASE_URL = 'https://youthissue.com'  // 또는 실제 도메인
```

---

### 4. **폴더명 변경 (선택사항)**

현재 폴더명: `YouthV2-Figma`

로컬 폴더명도 변경하려면:

```bash
# 상위 폴더로 이동
cd ..

# 폴더명 변경
mv YouthV2-Figma youth-issue

# 새 폴더로 이동
cd youth-issue
```

> ⚠️ **주의**: 폴더명을 변경해도 Git 저장소는 영향을 받지 않습니다.

---

### 5. **파일명 변경 (비권장)**

컴포넌트 파일명에서 "Figma" 제거 (예: `FigmaHeader.vue` → `Header.vue`)

#### ⚠️ **비권장 이유:**
- 수많은 import 경로 수정 필요 (100개 이상)
- 실수로 인한 버그 발생 가능성
- 배포/SEO에는 영향 없음

#### 만약 꼭 변경하고 싶다면:
프로젝트 전체 검색/치환 기능 사용:
1. VS Code에서 `Ctrl+Shift+H` (검색/치환)
2. `Figma` 검색 후 케이스별로 치환

---

## 📝 변경 완료 체크리스트

- [x] `package.json` - name, description 수정
- [x] `README.md` - Figma 언급 제거, 새 저장소 URL
- [x] SEO 메타 태그 업데이트
- [ ] **GitHub 저장소명 변경** → `youth-issue`
- [ ] **로컬 Git 원격 URL 업데이트**
- [ ] **Vercel 프로젝트명 변경** → `youth-issue`
- [ ] 커스텀 도메인 설정 (선택)
- [ ] 폴더명 변경 (선택)

---

## 🚀 변경 후 확인 사항

### 1. Git 원격 저장소 확인
```bash
git remote -v
# origin  https://github.com/SqurareEgg/youth-issue.git (fetch)
# origin  https://github.com/SqurareEgg/youth-issue.git (push)
```

### 2. Vercel 배포 확인
- 새 URL 접속: `https://youth-issue.vercel.app`
- 기존 URL은 자동으로 리다이렉트됨

### 3. SEO 메타 태그 확인
- 브라우저 개발자 도구(F12) > Elements > `<head>` 확인
- Open Graph Debugger: https://developers.facebook.com/tools/debug/

---

## ❓ FAQ

**Q: 기존 URL(`youth-policy-figma.vercel.app`)은 어떻게 되나요?**
A: Vercel이 자동으로 새 URL로 리다이렉트합니다. 기존 링크도 계속 작동합니다.

**Q: GitHub 저장소 이름을 바꾸면 기존 클론은 어떻게 되나요?**
A: 로컬에서 `git remote set-url` 명령어로 원격 URL만 업데이트하면 됩니다.

**Q: 파일명(FigmaXXX.vue)도 꼭 바꿔야 하나요?**
A: 아니요. 파일명은 내부 구조이므로 배포/SEO에 영향 없습니다. 변경하지 않는 것을 권장합니다.

**Q: 커스텀 도메인 없이도 괜찮나요?**
A: 네! Vercel 기본 도메인(`youth-issue.vercel.app`)으로도 충분히 전문적입니다.

---

**작성일**: 2026-04-30
**버전**: 1.0
