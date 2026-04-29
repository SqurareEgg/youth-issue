<template>
  <div style="min-height: 100vh; background-color: white; overflow-x: hidden;">
    <FigmaHeader :current-category="categoryName" />

    <div style="min-height: 100vh; background-color: #F9FAFB; overflow-x: hidden;">
      <!-- Back Button & Header -->
      <div style="background-color: white; border-bottom: 1px solid #E5E7EB; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);">
        <div style="max-width: 1280px; margin: 0 auto; padding: 1.5rem 1rem;">
          <q-btn
            flat
            icon="arrow_back"
            label="홈으로 돌아가기"
            @click="handleBack"
            style="color: #6B7280; margin-bottom: 1rem;"
            no-caps
            class="back-button"
          />

          <div>
            <h1 class="page-title">{{ categoryName }} 정책</h1>
            <p class="page-description">청년을 위한 {{ categoryName }} 관련 정책을 학습하고 혜택을 받아보세요</p>
          </div>
        </div>
      </div>

      <!-- 로딩 중 -->
      <div v-if="loading" style="text-align: center; padding: 3rem;">
        <q-spinner size="50px" color="orange" />
        <p style="margin-top: 1rem; color: #4B5563;">데이터를 불러오는 중...</p>
      </div>

      <!-- 메인 레이아웃 -->
      <div v-else class="container">
        <div class="main-layout">
          <!-- 사이드바 (데스크탑) -->
          <aside class="gt-md sidebar">
            <div style="background-color: white; border: 1px solid #E5E7EB; border-radius: 1rem; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); padding: 1rem;">
              <h3 style="font-size: 1.125rem; font-weight: 700; color: #111827; margin-bottom: 1rem; padding: 0 0.75rem; white-space: nowrap;">세부 정책</h3>
              <nav style="display: flex; flex-direction: column; gap: 0.25rem;">
                <button
                  v-for="subPolicy in subPolicies"
                  :key="subPolicy.id"
                  class="sidebar-button"
                  @click="viewPolicy(subPolicy.id)"
                >
                  <span style="font-size: 0.875rem; line-height: 1.25; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{{ subPolicy.title }}</span>
                </button>
              </nav>
            </div>
          </aside>

          <!-- 메인 콘텐츠 -->
          <main class="main-content">
            <!-- 모바일 탭 (모바일만) -->
            <div class="lt-lg mobile-tabs">
              <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.5rem; padding: 1rem 0;">
                <button
                  v-for="(subPolicy, index) in subPolicies"
                  :key="subPolicy.id"
                  class="mobile-tab-button"
                  @click="viewPolicy(subPolicy.id)"
                >
                  <q-icon :name="subPolicy.icon" size="24px" />
                  <span style="font-size: 0.75rem; text-align: center; line-height: 1.25;">정책{{ index + 1 }}</span>
                </button>
              </div>
            </div>

            <!-- 콘텐츠 영역 -->
            <div class="content-area">
              <!-- 카테고리 소개 -->
              <div class="category-intro-section">
                <h2 class="category-intro-title">{{ categoryIntro.title }}</h2>
                <p class="category-intro-description">{{ categoryIntro.description }}</p>
              </div>

              <div class="sections-container">
                <!-- 세부 정책 안내 Section -->
                <section class="policy-section">
                  <h3 class="section-title">세부 정책 안내</h3>

                  <div class="policy-cards-container">
                    <button
                      v-for="(subPolicy, index) in subPolicies"
                      :key="subPolicy.id"
                      class="policy-card"
                      @click="viewPolicy(subPolicy.id)"
                    >
                      <div class="policy-card-content">
                        <span class="policy-number">{{ String(index + 1).padStart(2, '0') }}</span>
                        <h4 class="policy-card-title">{{ subPolicy.title }}</h4>
                      </div>
                      <p class="policy-card-description">{{ subPolicy.description }}</p>
                    </button>
                  </div>
                </section>

                <!-- 학습 현황 Section -->
                <section class="learning-progress-section">
                  <div class="learning-progress-header">
                    <div>
                      <h3 class="learning-progress-title">{{ categoryName }} 정책 학습 현황</h3>
                    </div>
                    <div class="learning-progress-percentage">
                      <span class="learning-progress-number">{{ Math.round(completionRate) }}</span>
                      <span class="learning-progress-percent">%</span>
                    </div>
                  </div>

                  <div>
                    <q-linear-progress
                      :value="completionRate / 100"
                      color="orange"
                      track-color="rgba(249, 115, 22, 0.2)"
                      size="10px"
                      style="border-radius: 9999px;"
                    />
                    <p class="learning-progress-hint">영상을 시청하면 이수율이 올라갑니다.</p>
                  </div>
                </section>

                <!-- 정책을 쉽게 이해하기 Section (동영상/Q&A/Quiz 그리드) -->
                <section>
                  <h3 class="section-title">정책을 쉽게 이해하기</h3>

                  <div class="learning-grid">
                    <!-- 동영상 학습 카드 (왼쪽 큰 카드) -->
                    <div class="learning-card learning-card-video">
                      <div class="learning-card-header">
                        <h3 class="learning-card-title">동영상 학습</h3>
                        <p class="learning-card-description">5분 영상으로 정책의 핵심 내용을 빠르게 파악할 수 있습니다.</p>
                      </div>

                      <div v-if="videos.length > 0" class="video-preview">
                        <div class="video-thumbnail">
                          <div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;">
                            <div style="background-color: rgba(255, 255, 255, 0.9); border-radius: 9999px; padding: 1rem;">
                              <q-icon name="play_arrow" size="32px" color="orange" />
                            </div>
                          </div>
                          <img
                            :src="videos[0].thumbnail_url || 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800'"
                            :alt="videos[0].title"
                            style="width: 100%; height: 100%; object-fit: cover; opacity: 0.8;"
                            @error="handleImageError"
                          />
                        </div>
                        <q-btn
                          label="시청하기"
                          color="orange"
                          unelevated
                          no-caps
                          style="width: 100%; margin-top: 1rem;"
                          @click="() => watchVideo(videos[0].id)"
                        />
                      </div>
                      <div v-else style="text-align: center; padding: 2rem; color: #6B7280;">
                        영상이 준비 중입니다.
                      </div>
                    </div>

                    <!-- 오른쪽 작은 카드들 -->
                    <div class="learning-cards-right">
                      <!-- Q&A 카드 -->
                      <div class="learning-card">
                        <h3 class="learning-card-title">자주 묻는 질문</h3>
                        <p class="learning-card-description">다른 청년들이 궁금해하는 내용을 Q&A 형식으로 확인하세요</p>
                        <q-btn
                          label="질문 보기"
                          flat
                          no-caps
                          class="secondary-button"
                          @click="handleQnAClick"
                        />
                      </div>

                      <!-- Quiz 카드 -->
                      <div class="learning-card">
                        <h3 class="learning-card-title">QUIZ</h3>
                        <p class="learning-card-description">10문제로 구성된 퀴즈로 내가 얼마나 이해했는지 점검해보세요</p>
                        <div style="background-color: #F9FAFB; border-radius: 0.5rem; padding: 0.75rem; margin-top: 0.75rem;">
                          <div style="display: flex; justify-content: space-between; font-size: 0.875rem;">
                            <span style="color: #6B7280;">문항 수</span>
                            <span style="font-weight: 500; color: #111827;">{{ quizzes.length > 0 ? (quizzes[0].questionCount || 10) : 10 }}문제</span>
                          </div>
                        </div>
                        <q-btn
                          label="시작하기"
                          flat
                          no-caps
                          class="secondary-button"
                          style="margin-top: 0.75rem;"
                          @click="quizzes.length > 0 ? startQuiz(quizzes[0].id) : null"
                        />
                      </div>
                    </div>
                  </div>
                </section>
              </div>
            </div>
          </main>
        </div>
      </div>
    </div>

    <FigmaFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onActivated, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import FigmaHeader from '../components/figma/FigmaHeader.vue'
import FigmaFooter from '../components/figma/FigmaFooter.vue'
import { useAuth } from '../composables/useAuth'
import { useLearning } from '../composables/useLearning'
import { useMeta, categoryMeta } from '../composables/useMeta'
import { supabase } from '../lib/supabase'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()

const { user } = useAuth()
const { fetchLearningProgress, fetchVideoProgress, fetchQuizProgress } = useLearning()

// 하드코딩된 데이터를 위한 refs
const videos = ref<any[]>([])
const quizzes = ref<any[]>([])
const qnaList = ref<any[]>([])

const category = computed(() => route.params.category as string)
const categoryData = ref<any>(null)
const completionRate = ref(0)
const loading = ref(true)

// 카테고리 슬러그 → 이름 매핑
const categoryNameMap: Record<string, string> = {
  'job': '일자리',
  'housing': '주거',
  'education': '교육',
  'finance-welfare-culture': '금융･복지･문화',
  'participation': '참여'
}

// 카테고리 이름 가져오기 (데이터 로드 전에도 표시)
const categoryName = computed(() => categoryData.value?.name || categoryNameMap[category.value] || category.value)

// 카테고리별 소개 정보
const categoryIntro = computed(() => {
  const introMap: Record<string, { title: string; description: string }> = {
    'job': {
      title: '일자리 정책: 청년의 내일을 여는 맞춤형 고용 지원',
      description: '대한민국 청년들이 첫 일자리에 성공적으로 진입하고, 안정적인 노동 환경 속에서 꿈을 펼칠 수 있도록 6가지 핵심 사업을 추진합니다.'
    },
    'housing': {
      title: '주거 정책: 안심하고 머물 수 있는 청년의 삶터 확산',
      description: '대한민국 청년들이 주거 불안 없이 미래를 설계할 수 있도록 공적 주택 공급을 대폭 늘리고, 주거비 부담 경감과 안전한 주거 환경 구축을 위한 6가지 핵심 정책을 추진합니다.'
    },
    'education': {
      title: '교육정책: 모든 청년에게 열려있는 성장의 기회 확산',
      description: '대한민국 청년들이 디지털 대전환 시대의 주인공으로 성장할 수 있도록 향후 5년간 200만 명 이상의 청년에게 AI 등 실무형 미래역량 교육을 지원합니다.'
    },
    'finance-welfare-culture': {
      title: '금융·복지·문화 정책: 청년의 삶을 지키는 든든한 일상 안전망 구축',
      description: '대한민국 청년들이 경제적 자립 기반을 다지고 사회적 고립 없이 건강한 일상을 누릴 수 있도록 맞춤형 자산 형성 지원과 두터운 복지 체계를 마련합니다. 청년의 자산 격차 해소와 위기 대응력 강화를 위해 금융, 복지, 문화 전반을 아우르는 핵심 정책을 추진합니다.'
    },
    'participation': {
      title: '참여 정책: 청년이 주도하고 함께 만드는 미래 가치 확산',
      description: '대한민국 청년들이 정책의 단순 수혜자를 넘어 국정 운영의 핵심 파트너로 참여하고, 지역과 글로벌 무대에서 역량을 발휘할 수 있는 지속 가능한 생태계를 구축하기 위해 6가지 핵심 정책을 추진합니다.'
    }
  }

  return introMap[category.value] || { title: '', description: '' }
})

// 카테고리별 세부 정책 리스트
const subPolicies = computed(() => {
  const policyMap: Record<string, Array<{ id: number; title: string; icon: string; description: string }>> = {
    'job': [
      { id: 1, title: '첫 일자리 진입 및 조기 사회진출 지원', icon: 'business_center', description: '청년들이 학교를 졸업한 후 지체 없이 노동시장에 안착할 수 있도록 민간과 공공의 협력을 통한 통합 지원 체계를 가동합니다.' },
      { id: 2, title: '다시 서기 및 안정적 구직 지원', icon: 'refresh', description: '일시적으로 구직을 중단하거나 어려움을 겪는 청년들이 사회로 다시 돌아올 수 있는 튼튼한 안전망을 구축합니다.' },
      { id: 3, title: '실무 역량 강화 및 일경험 확대', icon: 'school', description: '기업 현장에서 바로 활용할 수 있는 실무 능력을 배양하고, 군 복무 기간까지 역량 개발의 기회로 활용합니다.' },
      { id: 4, title: '지역 유입 및 분야별 정착 지원', icon: 'location_on', description: '청년들이 지역에서도 충분한 기회를 찾고 안정적으로 정착할 수 있도록 지역 특화 산업과 연계한 패키지 지원을 강화합니다.' },
      { id: 5, title: '노동환경 개선 및 권익 보호', icon: 'shield', description: '다양한 형태의 노동에 종사하는 청년들의 권리를 보호하고, 쾌적하며 안전한 근무 환경을 조성합니다.' },
      { id: 6, title: '청년 창업 생태계 구축', icon: 'lightbulb', description: '도전적인 아이디어를 보유한 청년이 안심하고 창업에 도전하고, 실패해도 다시 일어설 수 있는 혁신 생태계를 조성합니다.' }
    ],
    'housing': [
      { id: 1, title: '청년 공공주택 공급 확대 및 제도 내실화', icon: 'apartment', description: '청년층을 위한 공적 주택을 2030년까지 40만 호 이상 공급하며, 수도권 도심 요지의 노후 청사와 유휴 국·공유지를 활용하여 청년들의 주거 안정을 실현합니다.' },
      { id: 2, title: '청년 특화·기숙사형 주택', icon: 'apartment_complex', description: '공유 오피스, 피트니스 센터 등 청년들이 선호하는 생활 서비스와 임대주택이 결합된 특화 주택을 공급하여 주거와 생활 편의를 동시에 보장합니다.' },
      { id: 3, title: '대학 기숙사 확충 및 청년친화 시설 개선', icon: 'school', description: '국립대 BTL 기숙사와 연합기숙사를 확충하고, 노후 기숙사의 개축 및 리모델링을 통해 청년친화적 주거 환경을 조성합니다.' },
      { id: 4, title: '지역 일자리 연계 청년 주거 모델 확산', icon: 'location_city', description: '지방 이전 청년들의 정착을 돕기 위해 주거 공간과 생활 인프라, 일자리가 유기적으로 결합된 복합 주거 모델을 확산합니다.' },
      { id: 5, title: '청년 주거비 및 금융 지원 확대', icon: 'account_balance_wallet', description: '무주택·저소득 청년을 대상으로 월세 지원과 주거안정 장학금을 제공하며, 우대 금리 청약통장과 저리 대출로 주거비 부담을 경감합니다.' },
      { id: 6, title: '청년 주거 안정망 및 상담·지원 체계 강화', icon: 'support_agent', description: '전세사기 예방과 불법 주거 감독을 강화하고, 취약 청년의 주거 환경 개선과 함께 찾아가는 주거 상담 서비스를 제공합니다.' }
    ],
    'education': [
      { id: 1, title: 'AI·SW 역량 강화 및 교육 확산', icon: 'computer', description: '학생, 구직자, 재직자의 생애주기별 맞춤형 교육훈련 체계를 AI와 SW 중심으로 전면 개편하여 향후 5년간 200만 명에게 역량 개발을 지원합니다.' },
      { id: 2, title: '온라인 AI 교육 확대 및 청년 주도 AX', icon: 'online_prediction', description: 'STEP 및 국방 AI 교육플랫폼을 연계한 통합 온라인 AI 교육센터를 운영하여 전 국민의 AI 접근성을 제고하고, 청년 주도의 AI 멘토링으로 지역 교육 격차를 해소합니다.' },
      { id: 3, title: '실무 역량 강화 및 맞춤형 인재 양성', icon: 'psychology', description: '프로젝트 기반의 K-디지털 트레이닝과 고급 AI 인재 양성 과정을 통해 연간 5만 명 규모의 AI·빅데이터 실무 인재를 양성하고, 중소기업 재직자의 AI 역량을 강화합니다.' },
      { id: 4, title: '청년 과학기술인 성장 지원', icon: 'science', description: '이공계 장학금 지원을 단계적으로 확대하고, 대학원생 연구생활장려금과 박사후연구원 제도 개선을 통해 청년 과학기술인의 안정적인 연구 환경을 조성합니다.' },
      { id: 5, title: '전략산업 전문 청년 인재 양성', icon: 'precision_manufacturing', description: '에너지, 건축, 의료·의약품, 정보보안 등 국가 전략산업 분야의 맞춤형 전문인재를 2030년까지 14만 명 이상 양성하고, 석·박사급 고급 인재 육성 체계를 구축합니다.' },
      { id: 6, title: '교육-일자리 연계 및 교육 격차 해소', icon: 'connect_without_contact', description: '대학과 기업이 공동으로 운영하는 계약학과를 확대하고, 직업교육 연계 경로를 다양화하며, 국가장학금 지원 대상 확대로 교육 격차를 해소합니다.' }
    ],
    'finance-welfare-culture': [
      { id: 1, title: '청년 초기 자산 형성 지원 강화', icon: 'savings', description: '청년미래적금, 장병내일준비적금 등 다양한 자산형성 지원 제도를 통해 청년들의 초기 자산 형성을 돕고, 5종 세트 연계로 체계적인 자산 관리를 지원합니다.' },
      { id: 2, title: '금융 안전망 구축 및 경제 역량 강화', icon: 'account_balance', description: '햇살론 유스 금리 인하와 채무조정 특례 확대로 금융 부담을 경감하고, 맞춤형 재무 진단과 체험형 교육으로 청년들의 금융 역량을 강화합니다.' },
      { id: 3, title: '고립·은둔 및 가족돌봄 청년 집중 케어', icon: 'volunteer_activism', description: '위기청년 전담 지원 기관인 청년미래센터를 확대하고, 고립·은둔 청년과 가족돌봄 청년을 위한 맞춤형 회복 지원과 자기돌봄비를 제공합니다.' },
      { id: 4, title: '자립 기반 강화 및 복지 사각지대 해소', icon: 'support', description: '자립준비청년 수당과 정착금을 확대하고, 저소득 한부모, 경계선 지능, 장애·이주 청년 등 복지 사각지대에 있는 청년들을 위한 맞춤형 지원을 강화합니다.' },
      { id: 5, title: '마음·신체 건강 통합 관리', icon: 'health_and_safety', description: '정신건강 검진 주기를 단축하고 AI 시스템을 도입하여 마음 건강 문제를 조기에 발견하며, 맞춤형 운동·식단 관리와 식생활 지원으로 신체 건강을 증진합니다.' },
      { id: 6, title: '문화 향유 확대 및 필수 생활비 경감', icon: 'theater_comedy', description: '청년 문화예술 패스를 확대하고 K-패스로 교통비를 절감하며, 문화 콘텐츠 창작 인재를 양성하고 국민연금 첫 보험료 지원 등으로 청년의 필수 생활비를 경감합니다.' }
    ],
    'participation': [
      { id: 1, title: '청년의 국정 참여 확대 및 소통 강화', icon: 'forum', description: '대통령, 국무총리, 대통령비서실장 주재 소통 채널을 통해 청년들이 정기적으로 국정 이슈를 토론하고 정책 방향을 함께 고민하는 실질적인 파트너십을 구축합니다.' },
      { id: 2, title: '정책 결정 권한 강화 및 거버넌스 확립', icon: 'how_to_vote', description: '정부위원회 청년 위원 비율을 20%로 상향하고, 청년정책조정위원회 전문위원회 설치와 청년보좌역 제도 내실화를 통해 청년의 정책 결정 권한을 강화합니다.' },
      { id: 3, title: '디지털 기반 참여 플랫폼 고도화', icon: 'devices', description: 'AI·빅데이터 기반 온통청년 플랫폼을 고도화하고, 온라인 정책 투표 및 피드백 기능을 신설하여 청년들이 상시적으로 정책에 참여할 수 있는 환경을 조성합니다.' },
      { id: 4, title: '지역 중심 청년 생태계 조성', icon: 'location_city', description: '지역 청년지원센터를 허브 기관으로 강화하고, 청년정책실험실과 청년친화도시 지정을 통해 지역 중심의 청년 생태계를 조성합니다.' },
      { id: 5, title: '지속가능한 지원 인프라 및 법령 정비', icon: 'policy', description: '청년 연령 기준을 34세로 상향하고, 청년인재 데이터베이스를 구축하며, 한국청년정책진흥원 신설을 통해 지속 가능한 청년 지원 인프라를 마련합니다.' },
      { id: 6, title: '글로벌 교류 확대 및 상생 문화 확산', icon: 'public', description: '아태 청년교류단 설치와 CAMPUS Asia 공동 학위 운영을 통해 글로벌 교류를 확대하고, 젠더 갈등 해소 공론장 운영으로 상생 문화를 확산합니다.' }
    ]
  }

  return policyMap[category.value] || []
})

// YouTube Video ID 추출
const extractYouTubeId = (url: string): string | null => {
  const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/
  const match = url.match(regex)
  return match ? match[1] : null
}

// YouTube oEmbed API로 썸네일 가져오기
const fetchYouTubeThumbnail = async (videoUrl: string): Promise<string | null> => {
  try {
    const videoId = extractYouTubeId(videoUrl)
    if (!videoId) return null

    const response = await fetch(`https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${videoId}&format=json`)
    if (!response.ok) return null

    const data = await response.json()
    return data.thumbnail_url || null
  } catch (error) {
    console.error('YouTube 썸네일 가져오기 에러:', error)
    return null
  }
}

// 카테고리 데이터 가져오기 (하드코딩 + 학습 진행 상태는 DB에서)
const loadCategoryData = async () => {
  loading.value = true

  try {
    // 카테고리 정보 설정
    const categoryMap: Record<string, any> = {
      'job': { id: 1, name: '일자리', slug: 'job' },
      'housing': { id: 2, name: '주거', slug: 'housing' },
      'education': { id: 3, name: '교육', slug: 'education' },
      'finance-welfare-culture': { id: 4, name: '금융･복지･문화', slug: 'finance-welfare-culture' },
      'participation': { id: 5, name: '참여', slug: 'participation' }
    }

    categoryData.value = categoryMap[category.value]

    if (!categoryData.value) {
      $q.notify({
        type: 'negative',
        message: '카테고리를 찾을 수 없습니다.',
        position: 'top'
      })
      router.push('/')
      return
    }

    // DB에서 영상 데이터 가져오기
    const { data: videoData, error: videoError } = await supabase
      .from('videos')
      .select('*')
      .eq('category_id', categoryData.value.id)
      .order('display_order', { ascending: true })

    if (videoError) {
      console.error('영상 데이터 로딩 에러:', videoError)
      videos.value = []
    } else {
      // YouTube 썸네일 URL 생성 (hqdefault는 대부분의 영상에서 사용 가능)
      videos.value = (videoData || []).map(video => {
        const videoId = extractYouTubeId(video.video_url || '')
        return {
          ...video,
          thumbnail_url: videoId
            ? `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`
            : 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
          completed: false
        }
      })
    }

    // 하드코딩된 퀴즈 데이터 (각 카테고리당 1개 퀴즈)
    const quizMap: Record<string, any[]> = {
      'job': [{ id: 1, title: '일자리 정책 기본 Quiz', description: '일자리 정책의 기본 내용을 확인하는 퀴즈입니다.', completed: false, passed: false }],
      'housing': [{ id: 3, title: '주거 정책 기본 Quiz', description: '주거 정책의 기본 내용을 확인하는 퀴즈입니다.', completed: false, passed: false }],
      'education': [{ id: 4, title: '교육 정책 기본 Quiz', description: '교육 정책의 기본 내용을 확인하는 퀴즈입니다.', completed: false, passed: false }],
      'finance-welfare-culture': [{ id: 5, title: '금융･복지･문화 정책 기본 Quiz', description: '금융･복지･문화 정책의 기본 내용을 확인하는 퀴즈입니다.', completed: false, passed: false }],
      'participation': [{ id: 6, title: '참여 정책 기본 Quiz', description: '참여 정책의 기본 내용을 확인하는 퀴즈입니다.', completed: false, passed: false }]
    }

    quizzes.value = quizMap[category.value] || []

    // Q&A는 빈 배열로 (Q&A 페이지에서 하드코딩된 데이터 사용)
    qnaList.value = []

    // 로그인한 경우 학습 진행 상태 가져오기
    if (user.value) {
      try {
        // 영상 진행 상태 가져오기
        const videoProgress = await fetchVideoProgress(user.value.id, categoryData.value.id)
        if (videoProgress && videoProgress.length > 0) {
          videos.value = videos.value.map(video => {
            const progress = videoProgress.find((p: any) => p.video_id === video.id)
            return {
              ...video,
              completed: progress?.completed || false
            }
          })
        }

        // 퀴즈 진행 상태 가져오기
        const quizProgress = await fetchQuizProgress(user.value.id, categoryData.value.id)
        if (quizProgress && quizProgress.length > 0) {
          quizzes.value = quizzes.value.map(quiz => {
            const progress = quizProgress.find((p: any) => p.quiz_id === quiz.id)
            return {
              ...quiz,
              completed: progress?.completed || false,
              passed: progress?.passed || false
            }
          })
        }

        // 전체 이수율 가져오기
        const learningProgress = await fetchLearningProgress(user.value.id, categoryData.value.id)
        completionRate.value = learningProgress?.completion_percentage || 0
      } catch (error: any) {
        console.error('학습 진행 상태 로딩 에러:', error)
        // 진행 상태 로딩 실패는 치명적 에러가 아니므로 계속 진행
        completionRate.value = 0
      }
    } else {
      // 로그인하지 않은 경우 이수율 0
      completionRate.value = 0
    }
  } catch (error: any) {
    console.error('카테고리 데이터 로딩 에러:', error)
    $q.notify({
      type: 'negative',
      message: '데이터를 불러오는 중 오류가 발생했습니다.',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadCategoryData()
  updateMetaTags()
})

// 영상/퀴즈에서 돌아왔을 때 데이터 재로드
onActivated(() => {
  console.log('카테고리 페이지 활성화 - 데이터 재로드')
  loadCategoryData()
})

// 카테고리별 메타 태그 업데이트 함수
const updateMetaTags = () => {
  const categorySlug = category.value as string
  const meta = categoryMeta[categorySlug]

  if (meta) {
    // 카테고리별 메타 정보 사용
    useMeta({
      ...meta,
      canonicalUrl: `https://youth-policy.vercel.app/category/${categorySlug}`
    })
  }
}

// 카테고리 변경 감지
watch(category, () => {
  loadCategoryData()
  updateMetaTags()
})

const handleBack = () => {
  router.push('/')
}

const viewPolicy = (policyId: number) => {
  router.push({
    name: 'policy-detail',
    params: {
      category: category.value,
      policyId: policyId.toString()
    }
  })
}

const handleQnAClick = () => {
  router.push({
    name: 'qna',
    params: {
      category: category.value
    }
  })
}

const watchVideo = (videoId: number) => {
  router.push({
    name: 'video',
    params: {
      category: category.value,
      videoId: videoId.toString()
    }
  })
}

const startQuiz = (quizId: number) => {
  router.push({
    name: 'quiz',
    params: {
      category: category.value,
      quizId: quizId.toString()
    }
  })
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  const currentSrc = img.src

  // hqdefault 실패 시 mqdefault로 시도
  if (currentSrc.includes('hqdefault.jpg')) {
    img.src = currentSrc.replace('hqdefault.jpg', 'mqdefault.jpg')
  }
  // mqdefault 실패 시 sddefault로 시도
  else if (currentSrc.includes('mqdefault.jpg')) {
    img.src = currentSrc.replace('mqdefault.jpg', 'sddefault.jpg')
  }
  // sddefault 실패 시 기본 이미지로
  else if (currentSrc.includes('sddefault.jpg')) {
    img.src = 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800'
  }
  // 그 외의 경우 기본 이미지로
  else if (!currentSrc.includes('unsplash.com')) {
    img.src = 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800'
  }
}
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 1rem;
  width: 100%;
  overflow-x: hidden;
}

@media (min-width: 640px) {
  .container {
    padding: 0 1.5rem;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 0 2rem;
  }
}

/* 메인 레이아웃 */
.main-layout {
  display: flex;
  gap: 0;
}

@media (min-width: 1024px) {
  .main-layout {
    gap: 4rem;
  }
}

/* 메인 콘텐츠 */
.main-content {
  flex: 1;
  width: 100%;
  min-width: 0;
}

/* 뒤로가기 버튼 */
.back-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: color 0.2s;
}

.back-button:hover {
  color: #F97316 !important;
}

/* 페이지 헤더 */
.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

@media (min-width: 640px) {
  .page-title {
    font-size: 1.875rem;
  }
}

.page-description {
  color: #6B7280;
  margin-top: 0.5rem;
}

/* 카테고리 소개 */
.category-intro-section {
  width: 100%;
  max-width: 100%;
  overflow: hidden;
}

.category-intro-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  line-height: 1.3;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .category-intro-title {
    font-size: 1.875rem;
    margin-bottom: 0.75rem;
  }
}

.category-intro-description {
  font-size: 1rem;
  color: #374151;
  line-height: 1.6;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .category-intro-description {
    font-size: 1.125rem;
  }
}

/* 세부 정책 섹션 */
.policy-section {
  background-color: white;
  border-radius: 1rem;
  border: 1px solid #E5E7EB;
  padding: 1.25rem;
  margin-top: 0;
  width: 100%;
  max-width: 100%;
  overflow: hidden;
}

@media (min-width: 640px) {
  .policy-section {
    padding: 1.75rem;
  }
}

/* 섹션 타이틀 */
.section-title {
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

@media (min-width: 640px) {
  .section-title {
    font-size: 1.25rem;
    margin-bottom: 1.25rem;
  }
}

/* 세부 정책 카드 컨테이너 */
.policy-cards-container {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 640px) {
  .policy-cards-container {
    gap: 1rem;
  }
}

/* 세부 정책 카드 */
.policy-card {
  width: 100%;
  max-width: 100%;
  text-align: left;
  box-sizing: border-box;
  padding: 1rem;
  border-radius: 0.75rem;
  border: 1px solid #E5E7EB;
  background-color: transparent;
  cursor: pointer;
  transition: all 0.2s;
}

@media (min-width: 640px) {
  .policy-card {
    padding: 1.25rem;
  }
}

.policy-card:hover {
  border-color: #F97316;
  background-color: rgba(249, 115, 22, 0.05);
}

.policy-card-content {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  margin-bottom: 0.25rem;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

@media (min-width: 640px) {
  .policy-card-content {
    gap: 1rem;
    margin-bottom: 0.375rem;
  }
}

.policy-number {
  color: #F97316;
  font-weight: 600;
  font-size: 1rem;
  flex-shrink: 0;
}

.policy-card-title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  flex: 1;
  transition: color 0.2s;
  line-height: 1.5;
  word-wrap: break-word;
  overflow-wrap: break-word;
  min-width: 0;
  width: 100%;
}

@media (min-width: 640px) {
  .policy-card-title {
    font-size: 1.125rem;
  }
}

.policy-card:hover .policy-card-title {
  color: #F97316;
}

.policy-card-description {
  font-size: 0.875rem;
  color: #6B7280;
  line-height: 1.6;
  margin: 0;
  padding-left: calc(1rem + 0.75rem);
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .policy-card-description {
    padding-left: calc(1rem + 1rem);
  }
}

/* 학습 현황 섹션 */
.learning-progress-section {
  background: linear-gradient(135deg, #FFF7ED 0%, #FFFFFF 100%);
  border-radius: 1rem;
  border: 1px solid #FED7AA;
  padding: 1.25rem;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  overflow: hidden;
}

@media (min-width: 640px) {
  .learning-progress-section {
    padding: 1.5rem;
  }
}

.learning-progress-header {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

@media (min-width: 640px) {
  .learning-progress-header {
    flex-direction: row;
    align-items: flex-end;
    justify-content: space-between;
    margin-bottom: 1.25rem;
  }
}

.learning-progress-title {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 0;
}

@media (min-width: 640px) {
  .learning-progress-title {
    font-size: 1.5rem;
  }
}

.learning-progress-percentage {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.learning-progress-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: #F97316;
}

@media (min-width: 640px) {
  .learning-progress-number {
    font-size: 3rem;
  }
}

.learning-progress-percent {
  font-size: 1.125rem;
  color: #6B7280;
}

.learning-progress-hint {
  font-size: 0.75rem;
  color: #6B7280;
  margin-top: 0.5rem;
  margin-bottom: 0;
}

/* 정책을 쉽게 이해하기 그리드 */
.learning-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 768px) {
  .learning-grid {
    grid-template-columns: 1.3fr 1fr;
    gap: 1.25rem;
    align-items: start;
  }
}

/* 학습 카드 */
.learning-card {
  background-color: white;
  border-radius: 1rem;
  border: 1px solid #E5E7EB;
  padding: 1.25rem;
  transition: all 0.2s;
  cursor: pointer;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  overflow: hidden;
}

@media (min-width: 640px) {
  .learning-card {
    padding: 1.5rem;
  }
}

.learning-card:hover {
  border-color: #F97316;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

.learning-card-video {
  cursor: default;
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .learning-card-video {
    height: 100%;
  }
}

.learning-card-header {
  margin-bottom: 0.75rem;
}

.learning-card-title {
  font-size: 1.125rem;
  font-weight: 700;
  margin: 0 0 0.375rem 0;
}

@media (min-width: 640px) {
  .learning-card-title {
    font-size: 1.25rem;
  }
}

.learning-card:hover .learning-card-title {
  color: #F97316;
}

.learning-card-video:hover .learning-card-title {
  color: inherit;
}

.learning-card-description {
  font-size: 0.875rem;
  color: #6B7280;
  line-height: 1.6;
  margin: 0;
}

/* 오른쪽 작은 카드들 */
.learning-cards-right {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* 동영상 미리보기 */
.video-preview {
  width: 100%;
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .video-preview {
    flex: 1;
    display: flex;
    flex-direction: column;
  }
}

.video-thumbnail {
  position: relative;
  border-radius: 0.75rem;
  overflow: hidden;
  background-color: #111827;
  width: 100%;
  aspect-ratio: 16/9;
}

@media (min-width: 768px) {
  .video-thumbnail {
    aspect-ratio: 16/9;
    max-height: 200px;
  }
}

/* 버튼 스타일 */
.secondary-button {
  width: 100%;
  margin-top: 1rem;
  background-color: white;
  border: 0;
  color: #374151;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  font-weight: 500;
}

.secondary-button:hover {
  background-color: #F9FAFB;
}

/* 콘텐츠 영역 */
.content-area {
  padding-top: 1.5rem;
  padding-bottom: 2rem;
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
}

@media (min-width: 768px) {
  .content-area {
    padding-top: 2rem;
  }
}

/* 카테고리 소개 섹션 */
.category-intro-section {
  margin-bottom: 1.5rem;
  width: 100%;
  max-width: 100%;
  overflow: hidden;
}

@media (min-width: 768px) {
  .category-intro-section {
    margin-bottom: 2rem;
  }
}

/* 섹션 컨테이너 */
.sections-container {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 768px) {
  .sections-container {
    gap: 1rem;
  }
}

/* 사이드바 */
.sidebar {
  width: 18rem;
  min-height: 100vh;
  position: sticky;
  top: 0;
  margin-left: -1rem;
  padding-left: 1rem;
  padding-top: 1.5rem;
}

@media (min-width: 640px) {
  .sidebar {
    margin-left: -1.5rem;
    padding-left: 1.5rem;
  }
}

@media (min-width: 1024px) {
  .sidebar {
    margin-left: -2rem;
    padding-left: 2rem;
  }
}

.sidebar-button {
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0.75rem;
  border-radius: 0.5rem;
  transition: all 0.2s;
  text-align: left;
  color: #374151;
  background-color: transparent;
  border: none;
  cursor: pointer;
}

.sidebar-button:hover {
  background-color: #F3F4F6;
}

/* 모바일 탭 */
.mobile-tabs {
  background-color: white;
  border-bottom: 1px solid #E5E7EB;
  margin: 0 -1rem;
  padding: 0 1rem;
  margin-bottom: 1.5rem;
  width: calc(100% + 2rem);
}

@media (min-width: 640px) {
  .mobile-tabs {
    margin: 0 -1.5rem;
    padding: 0 1.5rem;
    width: calc(100% + 3rem);
  }
}

.mobile-tab-button {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 0.5rem;
  border-radius: 0.75rem;
  transition: all 0.2s;
  width: 100%;
  background-color: #F3F4F6;
  color: #374151;
  border: none;
  cursor: pointer;
}

.mobile-tab-button:hover {
  background-color: #E5E7EB;
}
</style>
