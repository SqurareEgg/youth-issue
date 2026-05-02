# 데이터베이스 마이그레이션 가이드

## 📋 개요

정책, 퀴즈, Q&A 데이터를 **하드코딩**으로 전환하고,
**사용자 진행 상태 데이터만 DB에 유지**하는 최적화 작업입니다.

## 🎯 목적

- ✅ 콘텐츠 데이터(정책/퀴즈/Q&A) → 하드코딩 (이미 완료됨)
- ✅ 사용자 진행 데이터 → DB 저장
- ✅ 퀴즈 결과 제출 → DB 저장 (새로 추가)
- ✅ 학습 진도율 계산 → DB 기반

## 🔧 변경 사항

### 1. 코드 수정
- **FigmaQuizPage.vue**
  - `useLearning` composable 추가
  - 퀴즈 제출 시 DB에 저장하도록 수정
  - 카테고리 슬러그 → 퀴즈 ID 매핑 추가

### 2. DB 구조 변경

#### ✅ 유지되는 테이블
| 테이블 | 용도 |
|--------|------|
| `categories` | 카테고리 기본 정보 |
| `profiles` | 사용자 정보 |
| `videos` | 영상 콘텐츠 |
| `user_video_progress` | 영상 시청 기록 |
| **`quizzes`** | **퀴즈 메타데이터 (최소)** |
| **`user_quiz_results`** | **사용자 퀴즈 결과** |
| `page_views` | 페이지 통계 |

#### ✅ 유지되는 뷰
| 뷰 | 용도 |
|----|------|
| `user_learning_progress` | 학습 진도율 계산 |
| `category_analytics` | 카테고리별 분석 |
| `category_user_visits` | 카테고리 사용자 방문 |
| `category_session_visits` | 카테고리 세션 방문 |

#### ❌ 삭제되는 테이블/뷰
| 테이블/뷰 | 이유 |
|-----------|------|
| `policies` | 정책 데이터 하드코딩됨 |
| `policy_details` | 정책 상세 하드코딩됨 |
| `policy_full_view` | 뷰 불필요 |
| `quiz_questions` | 퀴즈 문제 하드코딩됨 |
| `qna` | Q&A 하드코딩됨 |
| `user_bookmarks` | 북마크 기능 미사용 |

## 📝 실행 순서

### Step 1: 퀴즈 메타데이터 설정
```bash
# Supabase Dashboard → SQL Editor에서 실행
```

파일: `setup-minimal-quiz-structure.sql`

이 스크립트는:
1. `quizzes` 테이블 생성 (메타데이터만)
2. `user_quiz_results` 테이블 생성
3. `user_learning_progress` 뷰 생성
4. 퀴즈 메타데이터 시드 데이터 삽입 (5개 카테고리)

### Step 2: 불필요한 테이블 정리
```bash
# Supabase Dashboard → SQL Editor에서 실행
```

파일: `cleanup-unused-tables-final.sql`

이 스크립트는:
1. `policy_full_view` 뷰 삭제
2. `user_bookmarks`, `policy_details`, `quiz_questions` 테이블 삭제
3. `policies`, `qna` 테이블 삭제

## 🧪 테스트 방법

### 1. 퀴즈 제출 테스트
1. 로그인 후 카테고리 페이지 접속
2. 퀴즈 풀기
3. 제출 후 결과 확인
4. Supabase에서 `user_quiz_results` 테이블 확인:
   ```sql
   SELECT * FROM user_quiz_results
   ORDER BY created_at DESC
   LIMIT 10;
   ```

### 2. 학습 진도율 확인
1. 카테고리 페이지에서 진도율 표시 확인
2. Supabase에서 뷰 확인:
   ```sql
   SELECT * FROM user_learning_progress
   WHERE user_id = 'YOUR_USER_ID';
   ```

### 3. 최종 테이블 목록 확인
```sql
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type IN ('BASE TABLE', 'VIEW')
ORDER BY table_type, table_name;
```

예상 결과:
- BASE TABLE: 7개 (categories, page_views, profiles, quizzes, user_quiz_results, user_video_progress, videos)
- VIEW: 4개 (category_analytics, category_session_visits, category_user_visits, user_learning_progress)

## ⚠️ 주의사항

1. **데이터 백업**
   - 스크립트 실행 전 반드시 백업 수행
   - 기존 `supabase-schema-backup-*.sql` 파일 보관

2. **실행 순서 준수**
   - `setup-minimal-quiz-structure.sql` 먼저 실행
   - `cleanup-unused-tables-final.sql` 나중에 실행

3. **기존 데이터 손실**
   - policies, qna 테이블 데이터는 삭제됨
   - 필요시 하드코딩된 데이터로 이관 완료됨

4. **user_quiz_results 데이터**
   - 기존 퀴즈 결과 데이터는 유지됨
   - 새로 제출하는 퀴즈부터 DB에 저장됨

## 📊 카테고리-퀴즈 매핑

| 카테고리 슬러그 | 카테고리 ID | 퀴즈 ID | 퀴즈 제목 |
|----------------|-------------|---------|-----------|
| job | 1 | 1 | 일자리 정책 기본 Quiz |
| housing | 2 | 2 | 주거 정책 기본 Quiz |
| education | 3 | 3 | 교육 정책 기본 Quiz |
| finance-welfare-culture | 4 | 4 | 금융·복지·문화 정책 기본 Quiz |
| participation | 5 | 5 | 참여·소통 정책 기본 Quiz |

## 🔍 트러블슈팅

### 퀴즈 제출 시 404 에러
- `quizzes` 테이블에 메타데이터가 없는 경우
- `setup-minimal-quiz-structure.sql` 실행 확인

### 학습 진도율이 표시되지 않음
- `user_learning_progress` 뷰가 없는 경우
- `setup-minimal-quiz-structure.sql` 실행 확인

### "Could not find the table" 에러
- 필요한 테이블이 삭제된 경우
- `restore-all-deleted-tables.sql` 로 복구 후 재시도

## ✅ 완료 체크리스트

- [ ] `setup-minimal-quiz-structure.sql` 실행
- [ ] `cleanup-unused-tables-final.sql` 실행
- [ ] 퀴즈 제출 테스트
- [ ] 학습 진도율 확인
- [ ] 최종 테이블 목록 확인 (7개 테이블 + 4개 뷰)
- [ ] 코드 커밋 및 푸시
- [ ] 프로덕션 배포
