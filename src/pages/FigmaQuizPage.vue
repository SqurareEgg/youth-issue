<template>
  <div style="min-height: 100vh; background-color: white;">
    <FigmaHeader />

    <div style="min-height: 100vh; background-color: #F9FAFB;">
      <!-- Back Button & Header -->
      <div style="background-color: white; border-bottom: 1px solid #E5E7EB;">
        <div class="container" style="padding: 1.5rem 1rem;">
          <q-btn
            flat
            icon="arrow_back"
            label="뒤로 가기"
            @click="handleBack"
            style="color: #4B5563; margin-bottom: 1rem;"
            no-caps
          />

          <div v-if="quiz">
            <h1 style="font-size: 1.875rem; font-weight: 700; margin-bottom: 0.5rem;">{{ quiz.title }}</h1>
            <p style="color: #4B5563;">{{ quiz.description }}</p>
          </div>
        </div>
      </div>

      <div class="container" style="padding: 2rem 1rem; max-width: 800px; margin: 0 auto;">
        <!-- 로딩 중 -->
        <div v-if="loading" style="text-align: center; padding: 3rem;">
          <q-spinner size="50px" color="orange" />
          <p style="margin-top: 1rem; color: #4B5563;">퀴즈를 불러오는 중...</p>
        </div>

        <!-- 결과 화면 -->
        <div v-else-if="showResult" style="text-align: center;">
          <q-card style="padding: 2rem;">
            <q-icon
              :name="result.score >= 60 ? 'emoji_events' : 'replay'"
              :color="result.score >= 60 ? 'orange' : 'grey'"
              size="80px"
              style="margin-bottom: 1rem;"
            />
            <h2 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem;">
              {{ result.score }}점
            </h2>
            <p style="font-size: 1.125rem; color: #4B5563; margin-bottom: 0.5rem;">
              {{ result.correctCount }} / {{ result.totalQuestions }} 정답
            </p>
            <p style="font-size: 1rem; color: #4B5563; margin-bottom: 2rem;">
              {{ result.score >= 60 ? '🎉 합격입니다!' : '😢 불합격입니다. 다시 도전해보세요!' }}
            </p>

            <div style="display: flex; flex-direction: column; gap: 0.75rem;">
              <q-btn
                label="다시 풀기"
                color="orange"
                unelevated
                no-caps
                @click="resetQuiz"
                style="font-size: 1rem; padding: 0.75rem;"
              />
              <q-btn
                label="목록으로 돌아가기"
                outline
                color="grey"
                no-caps
                @click="handleBack"
                style="font-size: 1rem; padding: 0.75rem;"
              />
            </div>
          </q-card>
        </div>

        <!-- 퀴즈 문제 -->
        <div v-else-if="questions.length > 0">
          <div style="margin-bottom: 2rem;">
            <q-linear-progress
              :value="(currentQuestionIndex + 1) / questions.length"
              color="orange"
              size="8px"
            />
            <p style="text-align: center; margin-top: 0.5rem; font-size: 0.875rem; color: #4B5563;">
              {{ currentQuestionIndex + 1 }} / {{ questions.length }}
            </p>
          </div>

          <q-card style="padding: 2rem; margin-bottom: 2rem;">
            <div style="margin-bottom: 2rem;">
              <div style="display: inline-block; background-color: #F97316; color: white; padding: 0.5rem 1rem; border-radius: 0.5rem; font-weight: 600; margin-bottom: 1rem;">
                문제 {{ currentQuestionIndex + 1 }}
              </div>
              <h2 style="font-size: 1.25rem; font-weight: 700; line-height: 1.6;">
                {{ currentQuestion.question }}
              </h2>
            </div>

            <div style="display: flex; flex-direction: column; gap: 1rem;">
              <q-card
                v-for="(option, index) in currentQuestion.options"
                :key="index"
                clickable
                @click="selectAnswer(index)"
                :style="{
                  padding: '1rem',
                  cursor: 'pointer',
                  border: userAnswers[currentQuestion.id] === index ? '2px solid #F97316' : '1px solid #E5E7EB',
                  backgroundColor: userAnswers[currentQuestion.id] === index ? '#FFF7ED' : 'white'
                }"
              >
                <div style="display: flex; align-items: center; gap: 1rem;">
                  <div
                    :style="{
                      width: '32px',
                      height: '32px',
                      borderRadius: '50%',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: '600',
                      backgroundColor: userAnswers[currentQuestion.id] === index ? '#F97316' : '#F3F4F6',
                      color: userAnswers[currentQuestion.id] === index ? 'white' : '#4B5563'
                    }"
                  >
                    {{ index + 1 }}
                  </div>
                  <span style="flex: 1; font-size: 1rem;">{{ option }}</span>
                </div>
              </q-card>
            </div>
          </q-card>

          <div style="display: flex; gap: 1rem;">
            <q-btn
              v-if="currentQuestionIndex > 0"
              label="이전"
              outline
              color="grey"
              no-caps
              @click="previousQuestion"
              style="flex: 1; padding: 0.75rem; font-size: 1rem;"
            />
            <q-btn
              v-if="currentQuestionIndex < questions.length - 1"
              label="다음"
              color="orange"
              unelevated
              no-caps
              @click="nextQuestion"
              :disable="userAnswers[currentQuestion.id] === undefined"
              style="flex: 1; padding: 0.75rem; font-size: 1rem;"
            />
            <q-btn
              v-else
              label="제출하기"
              color="orange"
              unelevated
              no-caps
              @click="submitQuizAnswers"
              :disable="!isAllAnswered"
              :loading="submitting"
              style="flex: 1; padding: 0.75rem; font-size: 1rem;"
            />
          </div>

          <div v-if="currentQuestionIndex === questions.length - 1 && !isAllAnswered" style="margin-top: 1rem; text-align: center;">
            <p style="color: #EF4444; font-size: 0.875rem;">
              모든 문제에 답해주세요. ({{ answeredCount }} / {{ questions.length }})
            </p>
          </div>
        </div>

        <!-- 퀴즈가 없을 때 -->
        <div v-else style="text-align: center; padding: 3rem;">
          <q-icon name="quiz" size="80px" color="grey" style="opacity: 0.5;" />
          <p style="margin-top: 1rem; color: #4B5563; font-size: 1.125rem;">퀴즈를 찾을 수 없습니다.</p>
        </div>
      </div>
    </div>

    <FigmaFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import FigmaHeader from '../components/figma/FigmaHeader.vue'
import FigmaFooter from '../components/figma/FigmaFooter.vue'
import { useAuth } from '../composables/useAuth'
import { useLearning } from '../composables/useLearning'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()

const { user } = useAuth()
const { submitQuiz } = useLearning()

// 카테고리 슬러그 → 퀴즈 ID 매핑
const categoryToQuizId: Record<string, number> = {
  'job': 1,
  'housing': 2,
  'education': 3,
  'finance-welfare-culture': 4,
  'participation': 5
}

const categorySlug = computed(() => route.params.category as string)
const quizId = computed(() => categoryToQuizId[categorySlug.value] || 1)

const quiz = ref<any>(null)
const questions = ref<any[]>([])
const loading = ref(true)
const submitting = ref(false)

const currentQuestionIndex = ref(0)
const userAnswers = ref<Record<number, number>>({})

const showResult = ref(false)
const result = ref<any>(null)

const currentQuestion = computed(() => questions.value[currentQuestionIndex.value])

const answeredCount = computed(() => Object.keys(userAnswers.value).length)

const isAllAnswered = computed(() => {
  return questions.value.every(q => userAnswers.value[q.id] !== undefined)
})

// 하드코딩된 퀴즈 데이터
const quizData: Record<string, any> = {
  'job': {
    title: '일자리 정책 기본 Quiz',
    description: '일자리 정책의 기본 내용을 확인하는 퀴즈입니다.',
    questions: [
      {
        id: 1,
        question: '청년 일자리 첫걸음 보장제가 대상으로 하는 인원 규모는?',
        options: ['5만 명', '10만 명', '15만 명', '30만 명'],
        correct_answer: 2,
        explanation: '청년 일자리 첫걸음 보장제는 고용보험 DB와 연계하여 장기 미취업 위험군 약 15만 명을 선제적으로 발굴하는 것을 목표로 합니다.'
      },
      {
        id: 2,
        question: '2026년부터 국민취업지원제도의 구직촉진수당은 월 얼마인가요?',
        options: ['40만 원', '50만 원', '60만 원', '70만 원'],
        correct_answer: 2,
        explanation: '구직촉진수당은 2025년 월 50만 원에서 2026년부터 월 60만 원으로 상향되며, 최대 6개월간 지급됩니다.'
      },
      {
        id: 3,
        question: '비수도권 중소기업에 취업한 청년에게 지급되는 최대 근속 인센티브 금액은?',
        options: ['480만 원', '600만 원', '720만 원', '900만 원'],
        correct_answer: 2,
        explanation: '비수도권 중소기업 취업 청년에게는 2년간 최대 720만 원의 청년일자리도약장려금이 지급됩니다.'
      },
      {
        id: 4,
        question: '청년 일자리 첫걸음 플랫폼이 연계되는 데이터는 무엇인가요?',
        options: ['주민등록 DB', '대학 학적 DB', '건강보험 DB', '고용보험 DB'],
        correct_answer: 3,
        explanation: '청년 일자리 첫걸음 플랫폼은 고용보험 DB와 연계하여 미취업 위험군을 조기에 발굴합니다.'
      },
      {
        id: 5,
        question: '청년도전지원사업의 최대 참여 수당은 얼마인가요?',
        options: ['100만 원', '150만 원', '200만 원', '250만 원'],
        correct_answer: 3,
        explanation: '청년도전지원사업은 참여 수준에 따라 50만 원에서 최대 250만 원까지 참여 수당을 지급합니다.'
      },
      {
        id: 6,
        question: 'AI 맞춤형 고용서비스의 주요 목적은 무엇인가요?',
        options: ['면접 자동 대행', '이력서 자동 제출', '개인별 직무·훈련 맞춤 추천', '기업 평가 시스템'],
        correct_answer: 2,
        explanation: 'AI 고용서비스는 청년의 역량과 유형을 분석하여 적합 직무와 훈련 과정을 맞춤 추천하는 것이 목적입니다.'
      },
      {
        id: 7,
        question: '국가기술자격 응시료 감면 비율은 얼마인가요?',
        options: ['30%', '40%', '50%', '70%'],
        correct_answer: 2,
        explanation: '청년의 구직 비용 부담 완화를 위해 국가기술자격 응시료 50% 감면이 적용되며, 대상 종목은 540개로 확대됩니다.'
      },
      {
        id: 8,
        question: '군 복무 중 AI 온라인 교육을 받을 수 있는 장병 규모는?',
        options: ['20만 명', '30만 명', '50만 명', '80만 명'],
        correct_answer: 2,
        explanation: '군 복무 중 역량 개발을 위해 전체 장병 50만 명을 대상으로 AI 온라인 교육이 시행됩니다.'
      },
      {
        id: 9,
        question: '플랫폼 종사자와 프리랜서 청년 보호를 위해 추진되는 법안은?',
        options: ['노동기본법', '청년고용법', '플랫폼근로법', '일하는 사람 권리 기본법'],
        correct_answer: 3,
        explanation: '플랫폼 종사자와 프리랜서의 권익 보호를 위해 「일하는 사람 권리 기본법」 제정이 추진됩니다.'
      },
      {
        id: 10,
        question: '2030년까지 추가 조성되는 혁신창업펀드 규모는?',
        options: ['3,000억 원', '5,000억 원', '7,000억 원', '1조 원'],
        correct_answer: 2,
        explanation: '청년 창업 활성화를 위해 2030년까지 7,000억 원 규모의 혁신창업펀드가 추가 조성됩니다.'
      }
    ]
  },
  'housing': {
    title: '주거 정책 기본 Quiz',
    description: '주거 정책의 기본 내용을 확인하는 퀴즈입니다.',
    questions: [
      {
        id: 11,
        question: '2026년부터 청년 주거 정책의 가장 큰 변화는 무엇일까요?',
        options: ['잠깐 지원하고 끝나는 정책', '월세만 지원하는 정책', '계속 도움받을 수 있는 주거 안전망 정책', '대학생만 대상인 정책'],
        correct_answer: 2,
        explanation: '이제 청년 주거 정책은 일시적인 지원이 아니라, 공공주택·월세·상담까지 지속적으로 지원하는 구조로 바뀝니다.'
      },
      {
        id: 12,
        question: '앞으로 청년을 위한 공공주택은 얼마나 공급될까요?',
        options: ['10만 호', '20만 호', '40만 호 이상', '정확한 계획 없음'],
        correct_answer: 2,
        explanation: '2030년까지 청년을 위한 공공주택이 40만 호 이상 공급될 예정입니다.'
      },
      {
        id: 13,
        question: '공공임대주택을 신청할 때 달라지는 점은 무엇일까요?',
        options: ['직접 방문 신청만 가능', '지역마다 따로 신청해야 함', '한 곳에서 확인하고 신청 가능', '추첨 방식이 사라짐'],
        correct_answer: 2,
        explanation: '여러 기관을 돌아다닐 필요 없이 하나의 통합 시스템에서 확인·신청할 수 있도록 바뀝니다.'
      },
      {
        id: 14,
        question: '청년도 공공분양 주택을 받을 수 있을까요?',
        options: ['불가능하다', '결혼해야만 가능하다', '청년 특별·우선공급으로 가능', '무주택자만 가능'],
        correct_answer: 2,
        explanation: '청년을 위한 특별공급·우선공급 제도가 계속 운영됩니다.'
      },
      {
        id: 15,
        question: '청년월세지원은 앞으로 어떻게 달라질까요?',
        options: ['올해만 하고 종료', '예산 있을 때만 운영', '계속 받을 수 있는 사업으로 전환', '대학생만 대상'],
        correct_answer: 2,
        explanation: '청년월세지원은 이제 일시 지원이 아니라 계속사업으로 운영됩니다.'
      },
      {
        id: 16,
        question: '월세 지원을 받을 수 있는 청년의 범위는 어떻게 되나요?',
        options: ['아주 소득이 낮은 일부만', '조건이 더 까다로워짐', '대상이 점점 확대됨', '소득 기준이 사라짐'],
        correct_answer: 2,
        explanation: '기존 중위소득 60% 기준은 단계적으로 완화되어 더 많은 청년이 받을 수 있도록 개선됩니다.'
      },
      {
        id: 17,
        question: '대학생이 받을 수 있는 새로운 주거 지원은 무엇일까요?',
        options: ['등록금 감면', '기숙사 무료 제공', '주거비 장학금 지원', '교통비 지원'],
        correct_answer: 2,
        explanation: '원거리 대학에 다니는 저소득층 대학생에게 월세·관리비 등에 사용할 수 있는 주거안정 장학금이 지원됩니다.'
      },
      {
        id: 18,
        question: '전세사기를 막기 위해 가장 중요하게 바뀌는 점은?',
        options: ['피해 후 보상 확대', '경찰 수사 강화', '계약 전에 미리 확인해주는 제도', '보험 의무 가입'],
        correct_answer: 2,
        explanation: '이제는 사기 당한 뒤가 아니라 계약 전에 위험을 확인해주는 예방 중심 정책이 강화됩니다.'
      },
      {
        id: 19,
        question: '반지하에 사는 청년도 지원을 받을 수 있을까요?',
        options: ['아니다', '일부 지역만 가능', '공공임대 우선 지원 가능', '상담만 가능'],
        correct_answer: 2,
        explanation: '열악한 환경에 거주하는 청년에게는 공공임대 우선 공급과 이주 지원이 함께 이루어집니다.'
      },
      {
        id: 20,
        question: '지방으로 취업하거나 이사하면 어떤 도움을 받을 수 있을까요?',
        options: ['집만 제공', '교통비만 지원', '주거와 일자리를 함께 지원', '별도 지원 없음'],
        correct_answer: 2,
        explanation: '지역으로 이동하는 청년에게는 주거·일자리·생활을 함께 지원하는 정착형 주거 모델이 확대됩니다.'
      }
    ]
  },
  'education': {
    title: '교육 정책 기본 Quiz',
    description: '교육 정책의 기본 내용을 확인하는 퀴즈입니다.',
    questions: [
      {
        id: 21,
        question: '앞으로 5년간 정부가 교육을 지원하는 청년 규모는?',
        options: ['50만 명', '100만 명', '200만 명 이상', '일부 전공자만 대상'],
        correct_answer: 2,
        explanation: '향후 5년간 200만 명 이상의 청년에게 AI 등 미래역량 교육이 지원됩니다.'
      },
      {
        id: 22,
        question: 'AI 교육은 어떤 청년이 받을 수 있을까요?',
        options: ['IT 전공자만', '대학생만', '취업 준비생만', '학생·구직자·재직자 모두'],
        correct_answer: 3,
        explanation: 'AI 교육은 생애주기별 맞춤형으로 제공되어 전공과 상관없이 누구나 참여할 수 있습니다.'
      },
      {
        id: 23,
        question: '지역에 살아도 AI 교육을 받을 수 있는 이유는?',
        options: ['방문 교육만 운영', '학교 재학생만 가능', '온라인 중심 교육 환경 구축', '지역별 인원 제한'],
        correct_answer: 2,
        explanation: '온라인 중심 학습 체계로 지역·소득과 관계없이 교육 참여가 가능합니다.'
      },
      {
        id: 24,
        question: '취업 준비 중인 청년이 받을 수 있는 교육은 무엇일까요?',
        options: ['이론 중심 강의', '자격증 시험 대비', 'AI 직무 중심 실무 교육', '일반 교양 수업'],
        correct_answer: 2,
        explanation: '구직 청년을 위해 AI 직무 중심 온라인 교육과 실무 훈련 과정이 제공됩니다.'
      },
      {
        id: 25,
        question: '군 복무 중에도 가능한 교육은?',
        options: ['독학만 가능', '외부 학원 수강', 'AI·SW 온라인 교육', '전역 후만 가능'],
        correct_answer: 2,
        explanation: '군 장병 50만 명을 대상으로 AI·SW 온라인 교육이 확대됩니다.'
      },
      {
        id: 26,
        question: '실무 경험을 쌓을 수 있는 교육 방식은?',
        options: ['시험 위주 수업', '이론 강의 중심', '프로젝트 기반 교육', '온라인 강의만 수강'],
        correct_answer: 2,
        explanation: '기업과 함께 프로젝트를 수행하는 실무 중심 교육이 강화됩니다.'
      },
      {
        id: 27,
        question: '재직 중인 청년도 교육을 받을 수 있을까요?',
        options: ['불가능하다', '휴직해야 가능', '재직 중에도 참여 가능', '공무원만 가능'],
        correct_answer: 2,
        explanation: '중소기업 재직자 등도 AI 특화 교육과 공동훈련센터를 통해 참여할 수 있습니다.'
      },
      {
        id: 28,
        question: '이공계 대학원생에게 새롭게 강화되는 지원은?',
        options: ['등록금 면제', '연구실 제공', '연구생활비 지원', '학점 인정 확대'],
        correct_answer: 2,
        explanation: '석사 월 80만 원, 박사 월 110만 원 수준의 연구생활장려금이 지원됩니다.'
      },
      {
        id: 29,
        question: '국가가 집중적으로 키우는 분야가 아닌 것은?',
        options: ['AI 반도체', '에너지 신산업', '정보보안', '일반 취미 교육'],
        correct_answer: 3,
        explanation: '국가 전략산업 중심으로 전문 인재 양성이 추진됩니다.'
      },
      {
        id: 30,
        question: '교육비 부담을 줄이기 위해 달라지는 제도는?',
        options: ['장학금 축소', '대출 대상 제한', '국가장학금 대상 확대', '학비 전액 자부담'],
        correct_answer: 2,
        explanation: '국가장학금 지원 대상이 9구간까지 확대되고, 학자금 대출도 모든 재학생이 신청할 수 있습니다.'
      }
    ]
  },
  'finance-welfare-culture': {
    title: '금융･복지･문화 정책 기본 Quiz',
    description: '금융･복지･문화 정책의 기본 내용을 확인하는 퀴즈입니다.',
    questions: [
      {
        id: 31,
        question: '청년미래적금의 가장 큰 특징은 무엇인가요?',
        options: ['납입 기간 5년 운영', '정부 기여금 폐지', '납입 기간 단축과 정부 기여금 확대', '고소득 청년만 가입 가능'],
        correct_answer: 2,
        explanation: '청년미래적금은 기존 청년도약계좌보다 납입 기간을 3년으로 단축하고, 정부 기여금을 최대 12%까지 확대한 새로운 자산 형성 상품입니다.'
      },
      {
        id: 32,
        question: '장병 내일준비적금의 정부 지원 방식으로 옳은 것은?',
        options: ['일부 금액만 지원', '이자만 지원', '납입금 100% 매칭', '만기 시 일시금 지급'],
        correct_answer: 2,
        explanation: '군 복무 중 병사가 납입한 금액에 대해 정부가 100%를 매칭해주며, 비과세 혜택도 함께 제공됩니다.'
      },
      {
        id: 33,
        question: '초급 군 간부를 위한 자산 형성 정책은 무엇인가요?',
        options: ['청년도약계좌', '내일저축계좌', '장기간부 도약적금', '청년미래적금'],
        correct_answer: 2,
        explanation: '초급 간부 장기 복무자를 대상으로 월 최대 30만 원 납입액에 대해 정부가 100% 매칭하는 \'장기간부 도약적금\'이 신설됩니다.'
      },
      {
        id: 34,
        question: '청년 자산형성 5종 세트에 포함되는 내용으로 옳은 것은?',
        options: ['보험 상품만 연계', '대출 상품 통합', '여러 자산 형성 제도를 연계', '하나의 통장으로 통합'],
        correct_answer: 2,
        explanation: '청년미래적금, 내일저축계좌, 주택드림청약통장 등 여러 자산 형성 제도를 연계하여 체계적인 자산 관리가 가능하도록 개선됩니다.'
      },
      {
        id: 35,
        question: '햇살론 유스 금리 인하의 주요 대상은 누구인가요?',
        options: ['고소득 청년', '자영업자', '미취업 청년·고졸 취업준비생', '공무원'],
        correct_answer: 2,
        explanation: '취업 전 청년의 이자 부담을 낮추기 위해 햇살론 유스 금리를 학자금 대출 수준으로 인하하는 방안이 추진됩니다.'
      },
      {
        id: 36,
        question: '청년 채무조정 특례를 통해 받을 수 있는 지원은?',
        options: ['원금 전액 면제', '신용등급 삭제', '이자율 최대 70% 인하', '대출 제한 강화'],
        correct_answer: 2,
        explanation: '채무로 어려움을 겪는 청년에게 이자율을 최대 70%까지 인하하고 원금 감면 비율도 확대하여 회복을 지원합니다.'
      },
      {
        id: 37,
        question: '고립·은둔 등 위기청년을 전담 지원하는 기관은?',
        options: ['청년상담소', '자립지원센터', '청년미래센터', '정신건강복지센터'],
        correct_answer: 2,
        explanation: '위기청년을 조기에 발굴하고 지원하기 위해 전국 단위로 청년미래센터를 확대 구축합니다.'
      },
      {
        id: 38,
        question: '가족돌봄청년에게 지원되는 자기돌봄비는 얼마인가요?',
        options: ['월 50만 원', '연 100만 원', '연 200만 원', '연 300만 원'],
        correct_answer: 2,
        explanation: '가족을 돌보느라 자신의 삶을 돌보기 어려운 청년에게 연 200만 원의 자기돌봄비가 지급됩니다.'
      },
      {
        id: 39,
        question: '청년 정신건강 검진 제도의 변화로 옳은 것은?',
        options: ['검진 대상 축소', '5년 주기 유지', '검진 주기 2년으로 단축', '병원 방문 의무화'],
        correct_answer: 2,
        explanation: '우울증 등 정신건강 문제를 조기에 발견하기 위해 정신건강 검진 주기가 2년으로 단축됩니다.'
      },
      {
        id: 40,
        question: '청년 교통비 부담을 줄이기 위해 도입되는 제도는?',
        options: ['청년교통바우처', '지역 교통카드', 'K-패스 \'모두의 카드\'', '청년정기권'],
        correct_answer: 2,
        explanation: '월 5.5만 원으로 대중교통을 무제한 이용할 수 있는 K-패스 \'모두의 카드\'가 도입되어 교통비 부담을 경감합니다.'
      }
    ]
  },
  'participation': {
    title: '참여 정책 기본 Quiz',
    description: '참여 정책의 기본 내용을 확인하는 퀴즈입니다.',
    questions: [
      {
        id: 41,
        question: '참여 정책의 핵심 방향으로 가장 맞는 것은?',
        options: ['정책 수혜 확대', '단기 의견 수렴', '정책 결정 과정에 청년 참여 확대', '설문조사 중심 참여'],
        correct_answer: 2,
        explanation: '청년은 정책의 수혜자가 아니라 국정 운영의 파트너로 참여하는 구조로 전환됩니다.'
      },
      {
        id: 42,
        question: '정부위원회 청년 위원 비율은 어떻게 달라지나요?',
        options: ['5% → 10%', '10% → 15%', '10% → 20% 이상', '비율 유지'],
        correct_answer: 2,
        explanation: '정부 주요 위원회에 청년 참여를 제도적으로 보장하기 위해 청년 위원 비율이 20% 이상으로 확대됩니다.'
      },
      {
        id: 43,
        question: '청년이 직접 정책을 제안하는 공식 기구는?',
        options: ['청년미래센터', '지역청년회의', '청년정책조정위원회 전문위원회', '청년포럼'],
        correct_answer: 2,
        explanation: '6개 분과 전문위원회에 청년 60명이 참여하여 정책을 직접 제안하고 수립 과정에 참여합니다.'
      },
      {
        id: 44,
        question: '청년 제안을 실제 정책으로 반영하기 위한 회의체는?',
        options: ['대통령 자문회의', '국무회의', '청년정책 관계장관회의', '정책 공청회'],
        correct_answer: 2,
        explanation: '국무총리 주재 관계장관회의를 통해 청년 제안을 정책으로 연결하는 실행 구조가 마련됩니다.'
      },
      {
        id: 45,
        question: '온라인 정책 참여가 가능한 플랫폼은?',
        options: ['정부24', '청년희망넷', '온통청년', '청년마당'],
        correct_answer: 2,
        explanation: '온통청년 플랫폼이 AI·빅데이터 기반으로 고도화되어 정책 투표와 피드백 기능이 추가됩니다.'
      },
      {
        id: 46,
        question: '정책 참여 이력을 보상으로 연결하기 위해 검토 중인 제도는?',
        options: ['참여 수당제', '정책 마일리지', '청년 참여 포인트제', '인센티브 카드'],
        correct_answer: 2,
        explanation: '청년 참여 활동을 포인트로 적립해 지원사업 참여 시 우대 혜택으로 활용하는 제도가 검토 중입니다.'
      },
      {
        id: 47,
        question: '청년친화도시는 매년 몇 개 도시가 지정되나요?',
        options: ['1개', '2개', '3개', '제한 없음'],
        correct_answer: 2,
        explanation: '매년 3개 도시를 선정해 청년 정책을 집중적으로 지원합니다.'
      },
      {
        id: 48,
        question: '지역 청년정책 실험을 위한 제도는?',
        options: ['청년토론회', '청년미래센터', '지역청년정책실험실', '정책 워크숍'],
        correct_answer: 2,
        explanation: '지역 특성에 맞는 청년 정책을 실험하고 우수 사례를 전국으로 확산합니다.'
      },
      {
        id: 49,
        question: '청년 참여 정책을 전담·지원하는 기관으로 추진되는 것은?',
        options: ['청년지원청', '국가청년센터', '한국청년정책진흥원', '청년미래재단'],
        correct_answer: 2,
        explanation: '청년 정책 전달과 참여 활동을 전문적으로 지원하는 전담 기구 신설이 추진됩니다.'
      },
      {
        id: 50,
        question: '글로벌 교류 확대 정책의 목적은?',
        options: ['단기 연수 제공', '해외 취업 알선', '청년 간 국제 네트워크 형성', '관광 활성화'],
        correct_answer: 2,
        explanation: '아태 청년교류단, CAMPUS Asia 등을 통해 청년이 글로벌 무대에서 역량을 확장하도록 지원합니다.'
      }
    ]
  }
}

// 퀴즈 데이터 로드
const loadQuiz = () => {
  loading.value = true

  try {
    const categoryData = quizData[categorySlug.value]

    if (!categoryData) {
      throw new Error('퀴즈를 찾을 수 없습니다.')
    }

    quiz.value = {
      title: categoryData.title,
      description: categoryData.description
    }

    questions.value = categoryData.questions
  } catch (error: any) {
    console.error('퀴즈 로딩 에러:', error)
    $q.notify({
      type: 'negative',
      message: error.message || '퀴즈를 불러오는 중 오류가 발생했습니다.',
      position: 'top'
    })
    router.back()
  } finally {
    loading.value = false
  }
}

// 정답 선택 (0-based index)
const selectAnswer = (answerIndex: number) => {
  userAnswers.value[currentQuestion.value.id] = answerIndex
}

// 다음 문제
const nextQuestion = () => {
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++
  }
}

// 이전 문제
const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
  }
}

// 퀴즈 제출 (로컬 채점 + DB 저장)
const submitQuizAnswers = async () => {
  if (!isAllAnswered.value) {
    $q.notify({
      type: 'warning',
      message: '모든 문제에 답해주세요.',
      position: 'top'
    })
    return
  }

  if (!user.value) {
    $q.notify({
      type: 'warning',
      message: '로그인이 필요합니다.',
      position: 'top'
    })
    return
  }

  submitting.value = true

  try {
    // 정답 개수 계산
    let correctCount = 0
    questions.value.forEach(question => {
      const userAnswer = userAnswers.value[question.id]
      if (userAnswer === question.correct_answer) {
        correctCount++
      }
    })

    // 점수 계산 (100점 만점)
    const totalQuestions = questions.value.length
    const score = Math.round((correctCount / totalQuestions) * 100)

    // DB에 결과 저장
    const submitResult = await submitQuiz(
      user.value.id,
      quizId.value,
      userAnswers.value
    )

    if (!submitResult.success) {
      throw new Error(submitResult.error || '퀴즈 결과 저장 실패')
    }

    result.value = {
      score: score,
      correctCount: correctCount,
      totalQuestions: totalQuestions
    }
    showResult.value = true

    $q.notify({
      type: 'positive',
      message: '퀴즈가 제출되었습니다!',
      position: 'top'
    })
  } catch (error: any) {
    console.error('퀴즈 제출 에러:', error)
    $q.notify({
      type: 'negative',
      message: error.message || '퀴즈 제출 중 오류가 발생했습니다.',
      position: 'top'
    })
  } finally {
    submitting.value = false
  }
}

// 퀴즈 다시 풀기
const resetQuiz = () => {
  currentQuestionIndex.value = 0
  userAnswers.value = {}
  showResult.value = false
  result.value = null
}

// 뒤로 가기
const handleBack = () => {
  if (categorySlug.value) {
    router.push({ name: 'category', params: { category: categorySlug.value } })
  } else {
    router.back()
  }
}

onMounted(() => {
  loadQuiz()
})
</script>

<style scoped>
.container {
  max-width: 1280px;
  margin: 0 auto;
}
</style>
