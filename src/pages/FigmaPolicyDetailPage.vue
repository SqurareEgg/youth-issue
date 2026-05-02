<template>
  <div style="min-height: 100vh; background-color: white; overflow-x: hidden;">
    <FigmaHeader :current-category="categoryData?.name || null" />

    <div style="min-height: 100vh; background-color: white; overflow-x: hidden;">
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
            <h1 class="page-title">{{ categoryData?.name || category }} 정책</h1>
            <p class="page-description">청년을 위한 {{ categoryData?.name || category }} 관련 정책을 학습하고 혜택을 받아보세요</p>
          </div>
        </div>
      </div>

      <!-- 메인 레이아웃 -->
      <div class="container">
        <div class="main-layout">
          <!-- 사이드바 (데스크탑) -->
          <aside class="gt-md sidebar">
            <div style="background-color: white; border: 1px solid #E5E7EB; border-radius: 1rem; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); padding: 1rem;">
              <h3 style="font-size: 1.125rem; font-weight: 700; color: #111827; margin-bottom: 1rem; padding: 0 0.75rem; white-space: nowrap;">세부 정책</h3>
              <nav style="display: flex; flex-direction: column; gap: 0.25rem;">
                <button
                  v-for="subPolicy in subPolicies"
                  :key="subPolicy.id"
                  :class="['sidebar-button', { 'active': subPolicy.id === parseInt(policyId) }]"
                  @click="navigateToPolicy(subPolicy.id)"
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
                  :class="['mobile-tab-button', { 'active': subPolicy.id === parseInt(policyId) }]"
                  @click="navigateToPolicy(subPolicy.id)"
                >
                  <q-icon :name="subPolicy.icon" size="24px" />
                  <span style="font-size: 0.75rem; text-align: center; line-height: 1.25;">정책{{ index + 1 }}</span>
                </button>
              </div>
            </div>

            <!-- 콘텐츠 영역 -->
            <div class="content-area">
              <div class="policy-detail-sections">
                <!-- 정책 헤더 카드 -->
                <div class="policy-header-card">
                  <div class="policy-header-grid">
                    <div class="policy-header-content">
                      <div class="policy-header-row">
                        <div class="policy-icon-wrapper">
                          <q-icon :name="currentPolicy.icon" size="20px" style="color: #374351;" />
                        </div>
                        <div class="policy-header-text">
                          <p style="font-size: 0.75rem; color: #6B7280; margin-bottom: 0.25rem;">정책 {{ currentPolicy.id }}</p>
                          <h2 class="policy-header-title">{{ currentPolicy.title }}</h2>
                        </div>
                      </div>
                      <p class="policy-header-description">{{ currentPolicy.description }}</p>
                    </div>
                    <div class="policy-header-image">
                      <img
                        :src="currentPolicy.image || 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800'"
                        :alt="currentPolicy.title"
                        style="width: 100%; height: 100%; object-fit: cover; border-radius: 0.5rem;"
                      />
                    </div>
                  </div>
                </div>

                <!-- 알림 서비스 안내 -->
                <div class="notification-banner">
                  <div class="notification-text">
                    <div style="display: flex; align-items: center; gap: 0.375rem; margin-bottom: 0.125rem;">
                      <div class="notification-icon-wrapper">
                        <q-icon name="notifications" size="18px" style="color: #F97316;" />
                      </div>
                      <h4 style="font-size: 0.9375rem; font-weight: 600; color: #111827; word-wrap: break-word; overflow-wrap: break-word; margin: 0;">관심 정책 알림 서비스</h4>
                    </div>
                    <p style="font-size: 0.875rem; color: #374151; line-height: 1.4; word-wrap: break-word; overflow-wrap: break-word;">저장 버튼을 클릭하여 관심 있는 세부 정책을 등록하면, 해당 정책의 접수 시작일과 중요한 변경사항을 알림으로 받아보실 수 있습니다.</p>
                  </div>
                </div>

                <!-- 세부 내용 카드들 -->
                <div class="detail-cards-container">
                  <div
                    v-for="detail in currentPolicy.details"
                    :key="detail.id"
                    class="detail-card"
                  >
                    <div class="detail-card-content">
                      <h3 class="detail-card-title">{{ detail.title }}</h3>
                      <p class="detail-card-description">{{ detail.description }}</p>
                    </div>
                    <button
                      class="bookmark-button"
                      :class="{ 'saved': isDetailBookmarked(detail.id) }"
                      @click="toggleBookmark(detail.id)"
                      :aria-label="isDetailBookmarked(detail.id) ? '관심 정책에서 제거' : '관심 정책으로 저장'"
                      :title="isDetailBookmarked(detail.id) ? '관심 정책에서 제거' : '관심 정책으로 저장하고 알림 받기'"
                    >
                      <q-icon :name="isDetailBookmarked(detail.id) ? 'bookmark' : 'bookmark_border'" size="20px" />
                    </button>
                  </div>
                </div>

                <!-- 목록으로 돌아가기 버튼 -->
                <div class="back-button-wrapper">
                  <q-btn
                    outline
                    label="목록으로 돌아가기"
                    @click="handleBackToList"
                    no-caps
                    class="back-to-list-button"
                  />
                </div>
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
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import FigmaHeader from '../components/figma/FigmaHeader.vue'
import FigmaFooter from '../components/figma/FigmaFooter.vue'
import { useAuth } from '../composables/useAuth'
import { useBookmarks } from '../composables/useBookmarks'

const route = useRoute()
const router = useRouter()
const $q = useQuasar()

const { user } = useAuth()
const { addBookmark, removeBookmark, isBookmarked, fetchUserBookmarks } = useBookmarks()

const category = computed(() => route.params.category as string)
const policyId = computed(() => route.params.policyId as string)
const categoryData = ref<any>(null)

// 북마크 상태 관리 (detailId를 키로 사용)
const bookmarkedDetails = ref<Set<number>>(new Set())

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

// 정책별 상세 내용
const policyDetails = computed(() => {
  const detailsMap: Record<string, Record<number, any>> = {
    'housing': {
      1: {
        details: [
          { id: 1, title: '공공주택 공급 대폭 확대', description: '청년층을 위한 공적 주택을 2030년까지 40만 호 이상 공급하며, 수도 도심 요지의 노후 청사와 유휴 국·공유지 등을 활용한 주택 공급을 추진합니다.', saved: false },
          { id: 2, title: '청년 특별·우선공급 지속 운영', description: '청년들이 내 집 마련의 꿈을 이룰 수 있도록 공공분양 주택에서 청년 대상 특별공급과 우선공급 제도를 지속적으로 운영하여 안정적인 주거 사다리를 제공합니다.', saved: false },
          { id: 3, title: '부담 가능한 수준의 공공분양 주택 확대', description: '청년의 자산 수준에 따라 선택할 수 있는 나눔형, 선택형, 일반형 등 다양한 유형의 공공분양 주택을 공급하여 주거 진입 장벽을 낮춥니다.', saved: false },
          { id: 4, title: '공공임대 시스템 일원화 추진', description: '사업자별로 분산되어 운영되던 공공임대 시스템을 가칭 \'대기자 통합 시스템\'으로 일원화하여 청년들이 임대주택 정보를 한곳에서 확인하고 편리하게 신청할 수 있도록 개선합니다.', saved: false }
        ]
      },
      2: {
        details: [
          { id: 1, title: '청년특화주택 공급 확대', description: '공유 오피스, 피트니스 센터 등 청년들이 선호하는 생활 서비스와 임대주택이 결합된 청년 특화 주택 공급을 늘려 주거와 생활 편의를 동시에 보장합니다.', saved: false },
          { id: 2, title: '기숙사형 청년주택 공급', description: '대학생 수요가 많은 지역의 소형 주택을 정부가 임차하여 청년들에게 시세보다 훨씬 저렴한 보증금과 월세로 재임대하는 기숙사형 주택을 지속적으로 제공합니다.', saved: false }
        ]
      },
      3: {
        details: [
          { id: 1, title: '기숙사 확충(BTL, 연합기숙사)', description: '국립대 BTL 기숙사와 여러 대학의 학생이 공동으로 이용할 수 있는 연합기숙사를 수도권 등 기숙사 수요가 높은 지역을 중심으로 지속적으로 확충합니다.', saved: false },
          { id: 2, title: '청년친화 시설 개선', description: '노후된 기숙사의 개축 및 리모델링을 추진하고, 기존 다인실을 1~2인실로 전환하여 1인당 기준 면적을 확대하는 등 기숙사 내 정주 여건을 대폭 개선합니다.', saved: false }
        ]
      },
      4: {
        details: [
          { id: 1, title: '지역활력타운 조성', description: '지방 이전 청년들의 정착을 돕기 위해 관계부처가 협력하여 주거 공간과 생활 인프라, 생활 서비스가 유기적으로 결합된 복합 주거 단지를 조성합니다.', saved: false },
          { id: 2, title: '주거, 일자리 연계 모델 구축', description: '지방 산업단지 근로자나 지역 전략 산업에 종사하는 청년들을 위해 직장 인근에 주거 시설과 일자리 지원 시설을 복합적으로 제공하는 모델을 확산합니다.', saved: false },
          { id: 3, title: '도심융합특구 조성', description: '지방 광역시에 기업 지원 공간과 청년들이 선호하는 양질의 문화·주거 시설을 도심에 종합적으로 제공하여 지역 발전과 청년 정착을 동시에 도모합니다.', saved: false },
          { id: 4, title: '지역 성장 거점 역할 강화', description: '지방 광역시에 산업, 주거, 문화가 어우러진 도심융합특구를 조성하여 지역의 청년 인들이 정착하고 성장할 수 있는 핵심 거점으로 육성합니다.', saved: false }
        ]
      },
      5: {
        details: [
          { id: 1, title: '청년월세지원', description: '무주택·저소득 청년을 대상으로 한 월세 지원 사업을 계속사업으로 전환하고, 중위소득 60% 이하인 소득 요건을 단계적으로 완화하여 수혜 대상을 확대합니다.', saved: false },
          { id: 2, title: '주거안정 장학금', description: '원거리 대학에 진학한 저소득층 대학생을 대상으로 관리비와 월세 등 주거 비용을 월 최대 20만 원(연간 240만 원)까지 지원하는 장학금을 지급합니다.', saved: false },
          { id: 3, title: '청년주거 금융 지원', description: '우대 금리가 적용되는 청년주택드림 청약통장과 저리 대출을 제공하며, 무주택 청년을 위한 전용 버팀목 전세자금 대출 지원을 통해 자금 마련 부담을 덜어줍니다.', saved: false }
        ]
      },
      6: {
        details: [
          { id: 1, title: '전세사기 예방 및 피해지원', description: '계약 전 권리관계를 분석해주는 안전계약 컨설팅을 제공하고, 전세사기 피해자 구제를 위해 공공임대 지원 대상을 확대하는 등 특별법 개정을 추진합니다.', saved: false },
          { id: 2, title: '불법 주거 감독 강화', description: '부동산 특별사법경찰을 통해 대학 역세권 등의 불법 용도 변경이나 무단 대수선(방 쪼개기) 등에 대한 점검과 관리·감독을 강화합니다.', saved: false },
          { id: 3, title: '취약 청년 주거 환경 개선', description: '반지하, 쪽방 등 열악한 환경에 거주하는 청년에게 공공임대주택 우선 공급과 이주 비용을 지원하며, 최저 주거 기준을 상향 조정하여 정주 여건을 개선합니다.', saved: false },
          { id: 4, title: '주거 상담 및 정보 제공 강화', description: '찾아가는 주거 상담 서비스를 통해 부동산 계약 및 예방 정보를 전달하고, 마이홈 포털을 고도화하여 AI 기반의 맞춤형 주거 정책 정보를 제공합니다.', saved: false }
        ]
      }
    },
    'job': {
      1: {
        details: [
          { id: 1, title: '민·관 협업 채용 확대', description: '청년 일자리 창출을 유도하기 위해 신규 채용 기업에 재정, 세제, 포상 등 전방위적인 인센티브를 제공합니다. 특히 청년의 장기 고용을 유도하기 위해 고용 기간이 길어질수록 세제 혜택이 커지는 \'공제액 점증 구조\'로 제도를 개편합니다.', saved: false },
          { id: 2, title: '국가 R&D 기업 우대', description: '국가 연구개발(R&D) 과제를 수행하는 기업이 청년을 채용할 경우 선정 과정에서 가점을 부여하거나 고용을 우대하는 방안을 검토하여 연구 분야의 청년 일자리 기반을 넓힙니다.', saved: false },
          { id: 3, title: '선제적 패키지 지원', description: '졸업 예정자나 졸업 직후의 미취업 청년이 구직에 어려움을 겪지 않도록 상담부터 교육, 일경험, 최종 취업까지 전 과정을 하나로 묶어 지원하는 통합 패키지를 시행합니다.', saved: false },
          { id: 4, title: 'AI 고용 서비스', description: 'AI가 개인의 역량을 정밀하게 분석하여 성공 확률이 높은 직무를 추천하고, 필요한 훈련 프로그램까지 1:1로 매칭해주는 지능형 취업 지원 서비스를 제공합니다.', saved: false },
          { id: 5, title: '자격증 취득 지원', description: '구직 비용 부담을 덜어주기 위해 국가기술자격 응시료 50% 감면 대상을 기존 488개에서 대한상공회의소 등 10개 기관 소관 540개 종목으로 대폭 확대합니다.', saved: false }
        ]
      },
      2: {
        details: [
          { id: 1, title: '\'쉬는 청년\' 맞춤 케어', description: '\'청년 일자리 첫걸음 플랫폼\'을 구축하여 고용보험 데이터베이스와 연계합니다. 이를 통해 장기 미취업 위험군 약 15만 명을 선제적으로 발굴하고 개인별 위험도에 따른 맞춤형 복귀 프로그램을 제공합니다.', saved: false },
          { id: 2, title: '청년도전지원사업', description: '구직 단념 청년들에게 밀착 상담과 역량 강화 프로그램을 제공하며, 참여 정도에 따라 50만 원에서 최대 250만 원의 참여 수당을 지급하여 사회 진입 의욕을 높입니다.', saved: false },
          { id: 3, title: '구직촉진수당 상향', description: '구직 기간 중의 경제적 부담을 완화하기 위해 국민취업지원제도의 구직촉진수당을 기존 월 50만 원에서 월 60만 원으로 상향하여 최대 6개월간 지원합니다.', saved: false },
          { id: 4, title: '청년 구직급여 추진', description: '자발적으로 이직한 청년이라도 새로운 도전을 준비할 수 있도록 생애 1회에 한해 구직급여를 지급하는 방안을 추진합니다.', saved: false },
          { id: 5, title: '청년 갭이어(Gap-year)', description: '청년들이 학업이나 일을 잠시 멈추고 진로를 진지하게 탐색하거나 회복할 수 있도록 지역 청년센터와 연계한 갭이어 지원 방안을 마련합니다.', saved: false },
          { id: 6, title: '재도전 지원', description: '취업 실패를 경험한 청년들이 다시 일어설 수 있도록 지역청년지원센터에서 상담과 분석을 거쳐 개인 맞춤형 재도전 계획을 수립하고 관련 사업을 연계해 드립니다.', saved: false }
        ]
      },
      3: {
        details: [
          { id: 1, title: '일경험(인턴) 기회 확대', description: '현대차, LG 등 주요 기업 및 스타트업과 협력하여 대규모 민간 인턴십 기회를 제공합니다. 정부 부처와 공공기관에서도 정책 참여형 일경험 제도를 운영하며, 특히 공공기관 블라인드 채용의 전면 도입을 검토하여 공정한 기회를 보장합니다.', saved: false },
          { id: 2, title: '첨단산업 특화 교육', description: 'AI 및 AX(AI 전환) 분야 실무 인재 1만 명을 집중 양성하고, \'이어드림스쿨\'을 통해 혁신 벤처와 스타트업 취업까지 밀착 연계합니다.', saved: false },
          { id: 3, title: '군 복무 중 역량 개발', description: '전체 장병 50만 명을 대상으로 AI 온라인 교육을 시행하며, 복무 중 대학 강좌 수강료 지원과 함께 전자책 구독 지원 서비스를 신설하여 중단 없는 자기계발을 지원합니다.', saved: false }
        ]
      },
      4: {
        details: [
          { id: 1, title: '청년일자리도약장려금 확대', description: '비수도권 중소기업에 취업한 청년들의 장기 근속을 지원하기 위해 2년간 최대 720만 원의 인센티브를 우대 지급합니다.', saved: false },
          { id: 2, title: '지역 맞춤형 지원', description: '지자체와 협업하여 해당 지역의 전략 산업과 연계한 교육, 일자리 제공, 주거 지원을 원스톱 통합 프로그램으로 운영합니다.', saved: false },
          { id: 3, title: '지역 인재 양성(RISE)', description: '지역혁신중심 대학지원체계(RISE)를 가동하여 지역 대학과 지자체, 산업계가 원팀으로 지역 전략 산업에 필요한 전문 인재를 양성하고 취업까지 연계합니다.', saved: false },
          { id: 4, title: '농·어업 도전 지원', description: '청년 농업인에게는 3년간 월 90~110만 원의 영농정착지원금을 지급하고 맞춤형 농지와 농촌 보금자리 주택을 공급합니다. 청년 어업인을 위해서는 \'청년 바다마을\' 조성과 함께 어선 임차료 지원 및 스마트 양식 창업 지원을 대폭 강화합니다.', saved: false }
        ]
      },
      5: {
        details: [
          { id: 1, title: 'AI 노동법 도우미', description: '24시간 언제 어디서나 맞춤형 상담이 가능한 AI 노동법 시스템을 운영하여 임금 체불이나 부당 대우에 대한 권리 구제를 지원합니다. 소규모 사업장도 AI를 통해 노동법 준수 여부를 스스로 점검할 수 있도록 돕습니다.', saved: false },
          { id: 2, title: '플랫폼·프리랜서 보호', description: '플랫폼 종사자와 프리랜서 청년들의 공정 계약과 건강한 작업 환경을 보장하기 위해 「일하는 사람 권리 기본법」 제정을 추진하고, 법적 보호 사각지대를 해소합니다.', saved: false },
          { id: 3, title: '경력 인증 및 복지', description: '단기 근로와 프리랜서 경험도 직무 역량으로 활용할 수 있도록 경력 인증 시스템을 구축합니다. 또한 중소기업 재직 청년을 위한 복지카드 시범 사업과 노후 산단지 내 청년친화 편의시설 확충을 위한 바우처 지원을 실시합니다.', saved: false }
        ]
      },
      6: {
        details: [
          { id: 1, title: '혁신 창업가 육성', description: '청년창업사관학교와 딥테크 창업중심대학을 통해 AI, 바이오헬스 등 신기술 분야의 창업가를 집중 양성합니다. \'모두의 창업 프로젝트\'를 통해 배경 지식이 없어도 혁신적인 아이디어만 있다면 누구나 창업에 도전할 수 있는 환경을 만듭니다.', saved: false },
          { id: 2, title: '분야별 특화 창업', description: '전통문화, 게임, 미디어, 기후·환경, 스마트건설 등 부처별 전문 분야에 특화된 창업 지원 프로그램을 운영하여 산업 전반의 창업 저변을 확대합니다.', saved: false },
          { id: 3, title: '자금 및 투자 지원', description: '7,000억 원 규모의 혁신창업펀드를 추가 조성하고, 기업당 최대 1억 원의 청년전용창업자금을 융자 지원합니다. 또한 청년 창업 제품의 공공기관 우선구매 제도를 신설하여 초기 판로 확보를 돕습니다.', saved: false },
          { id: 4, title: '창업 안전망 및 재도전', description: '실패 경험을 자산으로 삼을 수 있도록 \'청년 재도전 지원 전용 트랙\'을 신설하고 사업화 자금을 패키지로 지원합니다. 폐업 후 재창업을 준비하는 예비 창업자에게는 지원 사업 기회를 추가로 허용하며, 중장년과의 공동 창업 지원도 확대합니다.', saved: false }
        ]
      }
    },
    'education': {
      1: {
        details: [
          { id: 1, title: 'AI·SW 중심 교육체계 전환', description: '학생, 구직자, 재직자의 생애주기별 맞춤형 교육훈련 체계를 AI와 SW 중심으로 전면 개편하여 향후 5년간 200만 명에게 역량 개발을 지원합니다.', saved: false },
          { id: 2, title: 'AI 고등교육 인프라 확충', description: 'AI·SW 중심대학과 AI·AX 대학원을 신설·확대하고 거점 국립대 등에 AI 단과대를 설치하여 전문 교육 및 연구 인프라를 강화합니다.', saved: false },
          { id: 3, title: '산학연계 실전 교육 강화', description: '대학과 기업이 공동으로 첨단산업 부트캠프를 88개교까지 확대 운영하여 산업 현장 수요에 맞춘 실전형 인재를 양성합니다.', saved: false },
          { id: 4, title: 'AI 고급인재 발굴·육성', description: 'AI 활용 루키 대회 신설을 통해 우수 인재를 조기에 발굴하고 전문가 멘토링과 심화 교육을 거쳐 디지털 분야 핵심 리더로 육성합니다.', saved: false },
          { id: 5, title: '군 장병 AI 교육 확대', description: '군 장병 대상 맞춤형 AI·SW 온라인 교육을 50만 명으로 대폭 확대하고 대학 원격강좌 학점 인정 등을 통해 복무 중 자기개발을 지원합니다.', saved: false }
        ]
      },
      2: {
        details: [
          { id: 1, title: '범국민 온라인 AI 교육센터 구축', description: 'STEP 및 국방 AI 교육플랫폼을 연계한 통합 온라인 AI 교육센터 \'우리의 AI 러닝\'을 운영하여 전 국민의 AI 접근성을 제고합니다.', saved: false },
          { id: 2, title: '청년 맞춤 AI 직무교육 강화', description: 'STEP 플랫폼을 활용해 구직·재직 청년의 온라인 AI 직무 역량을 강화하고 이를 오프라인 직업훈련 과정과 긴밀히 연계합니다.', saved: false },
          { id: 3, title: '청년 주도 AX 멘토링 신설', description: 'AI 전공 대학생이 초·중·고 학생을 대상으로 지식을 나누는 멘토링 사업을 추진하여 지역 간 교육 격차를 해소하고 지속 가능한 AI 생태계를 만듭니다.', saved: false },
          { id: 4, title: '온라인 중심 AI 학습 생태계 확산', description: '신분이나 소득, 지역에 관계없이 누구나 AI 교육을 받을 수 있는 온라인 중심의 보편적 학습 환경을 구축하여 디지털 포용을 실현합니다.', saved: false }
        ]
      },
      3: {
        details: [
          { id: 1, title: '프로젝트 기반 AI·데이터 인재 양성', description: '기업 및 대학과 협력하여 프로젝트 기반의 K-디지털 트레이닝 과정을 운영하며 연간 5만 명 규모의 AI·빅데이터 실무 인재를 양성합니다.', saved: false },
          { id: 2, title: '고급 AI 인재 양성 과정 확대', description: '최고 전문가의 멘토링을 제공하는 AI·SW 마에스트로와 혁신적 교육 방식의 AI 이노아카데미 과정을 확대하여 역량 있는 전문 인재를 육성합니다.', saved: false },
          { id: 3, title: '신산업 융합 인재 육성', description: '가상융합기술 아카데미를 통해 XR 및 메타버스 등 신산업 분야의 취·창업 희망 청년들에게 전문적인 개발 및 창작 교육 기회를 제공합니다.', saved: false },
          { id: 4, title: '중소기업 재직자 AI 역량 강화', description: '중소기업 재직자를 위한 AI 특화 교육 과정과 공동훈련센터를 신설하여 5년간 10만 명의 재직자에게 AI 리터러시 및 전문 교육을 지원합니다.', saved: false },
          { id: 5, title: '재직자 AI+X(AID) 집중과정 확대', description: '다양한 산업 및 직무별로 AI 융합 역량을 키울 수 있도록 성인 재직자를 대상으로 하는 맞춤형 AI+X(AID) 집중 교육 과정을 확대 운영합니다.', saved: false }
        ]
      },
      4: {
        details: [
          { id: 1, title: '이공계 장학금 지원 확대', description: '대학원 대통령과학장학금과 이공계 석·박사 우수장학금 규모를 2030년까지 각각 1,000명과 9,000명 수준으로 단계적 확대하여 연구 몰입 환경을 조성합니다.', saved: false },
          { id: 2, title: '대학원생 연구생활 안정 지원', description: '이공계 대학원생의 경제적 안전망 구축을 위해 연구생활장려금 지원 대상을 50개교 이상으로 늘리고 석사 월 80만 원, 박사 월 110만 원의 수준을 보장합니다.', saved: false },
          { id: 3, title: '박사후연구원 제도 개선', description: '고등교육법 개정을 통해 박사후연구원의 법적 지위를 명문화하고 표준지침을 제정·배포하여 안정적인 연구 및 근로 여건을 마련합니다.', saved: false },
          { id: 4, title: '경력개발 지원', description: '신규 박사후연구원을 대상으로 기업과 대학이 함께하는 산학 프로젝트 지원 사업을 신설하여 우수 과학기술 인재의 산업계 안착과 경력 형성을 돕습니다.', saved: false }
        ]
      },
      5: {
        details: [
          { id: 1, title: '전략산업 분야별 인재 양성', description: '에너지, 건축, 의료·의약품, 정보보안 등 각 부처의 전문성을 활용하여 2030년까지 국가 전략산업 맞춤형 전문인재 14만 명 이상을 양성합니다.', saved: false },
          { id: 2, title: '미래 핵심 분야 고급 교육 확대', description: '스마트시티, 에너지 신산업, AI 반도체, 규제과학 등 고부가가치 미래 핵심 분야의 석·박사급 전문 교육 및 연구 지원을 대폭 강화합니다.', saved: false },
          { id: 3, title: '산업 수요 연계 인재 양성 체계', description: '산업계 특성화대학원 확대 및 산학연계 인턴십 등을 통해 현장 중심의 실무형 인재와 석·박사급 고급 인재를 병행하여 육성하는 체계를 구축합니다.', saved: false },
          { id: 4, title: '전문 직무 역량 기반 경력 설계 지원', description: '분야별 전문 직무 역량을 바탕으로 청년들이 해당 산업계에 안정적으로 안착하고 지속 가능한 직업 경로를 형성할 수 있도록 체계적으로 지원합니다.', saved: false }
        ]
      },
      6: {
        details: [
          { id: 1, title: '교육-산업 연계 제도 강화', description: '대학과 기업이 공동으로 운영하고 채용까지 연계하는 계약학과 및 계약정원을 확대하고, 현장실습 제도를 유연하게 개선하여 취업 연계 기능을 강화합니다.', saved: false },
          { id: 2, title: '직업교육 연계 경로 확대', description: '직업계고와 전문대 간 교육과정 연계(3+1 전문학사) 및 산업체 현장 경험을 학점으로 인정하는 \'2+3 마이스터 학사\' 도입을 통해 학위 취득 기간을 단축합니다.', saved: false },
          { id: 3, title: '직업계고 청년 취업 지원 강화', description: '신기술 분야 학과 개편과 채용연계형 직무교육과정 운영을 내실화하고, 고교 취업연계 장려금 지원을 통해 조기 사회 진출을 돕습니다.', saved: false },
          { id: 4, title: '학비·생활비 부담 완화', description: '국가장학금 지원 대상을 9구간까지 확대하고 학자금 대출 신청 대상을 모든 재학생으로 넓혀 배경과 관계없이 공정한 교육 기회를 보장합니다.', saved: false },
          { id: 5, title: '평생학습 기반 강화', description: '고졸 재직자 대상 장학금 지원을 지속하고 평생교육이용권 및 K-MOOC 강좌 확대를 통해 청년들이 언제든 원하는 교육을 받을 수 있는 환경을 조성합니다.', saved: false }
        ]
      }
    },
    'finance-welfare-culture': {
      1: {
        details: [
          { id: 1, title: '청년미래적금 신설 (혜택 강화)', description: '기존 청년도약계좌 대비 납입 기간을 3년으로 단축하고 정부 기여금을 최대 12%까지 확대하여 초기 자산 형성을 지원합니다.', saved: false },
          { id: 2, title: '장병 내일준비적금 (병사)', description: '군 복무 중인 병사가 월 최대 55만 원을 납입할 경우 정부가 100%를 매칭하고 비과세 혜택을 제공하여 전역 시 목돈 마련을 돕습니다.', saved: false },
          { id: 3, title: '장기간부 도약적금 (간부)', description: '초급 군 간부 장기 복무자를 대상으로 3년 동안 월 최대 30만 원 납입액에 대해 정부 기여금을 100% 매칭 지급하여 자립 기반을 강화합니다.', saved: false },
          { id: 4, title: '청년 자산형성 5종 세트 연계', description: '청년미래적금, 내일저축계좌, 주택드림청약통장, 장병내일적금, 서민형 ISA 간의 연계를 강화하여 체계적인 자산 관리가 가능하도록 개선합니다.', saved: false }
        ]
      },
      2: {
        details: [
          { id: 1, title: '햇살론 유스 금리 인하', description: '고졸 취업준비생이나 미취업 청년의 이자 부담을 완화하기 위해 햇살론 유스의 대출 금리를 학자금 대출 수준으로 인하를 추진합니다.', saved: false },
          { id: 2, title: '청년 채무조정 특례 확대', description: '금융 채무 연체로 어려움을 겪는 청년에게 이자율을 70%까지 일괄 인하하고 원금 감면 비율을 확대하는 채무조정 특례를 지속 지원합니다.', saved: false },
          { id: 3, title: '맞춤형 재무 진단 및 상담', description: '재무 상담이 필요한 모든 청년을 대상으로 전문가를 통한 기초 재무 진단 및 일대일 맞춤형 금융 솔루션을 제공합니다.', saved: false },
          { id: 4, title: '체험형 금융 시뮬레이션 도입', description: '저축, 대출, 보험, 투자 등 다양한 금융 활동을 모의로 경험하며 금융 이해력을 높일 수 있는 실전형 교육 프로그램을 운영합니다.', saved: false },
          { id: 5, title: '청년 경제 캠프 및 토크콘서트', description: '대학생과 사회초년생 등을 위해 AI 기반 개인 맞춤형 경제 진단, 전문가 멘토링, 온·오프라인 강좌 등 다양한 교육 기회를 확대합니다.', saved: false }
        ]
      },
      3: {
        details: [
          { id: 1, title: '위기청년 전담 지원 체계 구축', description: '위기 청년 전담 지원 기관인 청년미래센터를 전국으로 단계적 확대하고 학교나 병원 종사자가 위험 사례 발견 시 직권 신청할 수 있는 시스템을 마련합니다.', saved: false },
          { id: 2, title: '고립·은둔 청년 맞춤형 회복 지원', description: '초기 상담을 통해 고립도를 정밀하게 파악하고 공동생활 프로그램이나 가상회사 형태의 일경험 등을 연계하여 단계적인 일상 회복을 돕습니다.', saved: false },
          { id: 3, title: '가족돌봄청년 자기돌봄비 지원', description: '아픈 가족을 돌보는 청년이 본인의 성장에 집중할 수 있도록 연 200만 원의 자기돌봄비를 지급하고 맞춤형 사례 관리를 강화합니다.', saved: false },
          { id: 4, title: '가족 의료·돌봄 서비스 연계', description: '가족 돌봄 부담을 덜어주기 위해 사회서비스 본인 부담 비율을 할인하고 자활 사업 참가 유예 등 가족 돌봄 특화 지원을 실시합니다.', saved: false }
        ]
      },
      4: {
        details: [
          { id: 1, title: '자립준비청년 수당 및 정착금 확대', description: '자립수당(월 50만원)과 자립정착금(1,000만원 이상) 지원을 강화하고 맞춤형 사례관리를 통해 경제적·정서적 자립을 돕습니다.', saved: false },
          { id: 2, title: '디지털 진로 체험', description: '자립준비청년에게 디지털 분야 창업 교육, 미디어 창작 교육, 기업 인턴십 등 다양한 직업 체험 기회를 제공하여 미래 진로 설계를 지원합니다.', saved: false },
          { id: 3, title: '임대주택 지원', description: '자립준비청년의 안정적인 주거 정착을 위해 연간 2,000호 규모의 공공임대주택을 우선 공급하고 입주 및 재무 관리 교육을 병행합니다.', saved: false },
          { id: 4, title: '저소득 한부모 양육비 인상', description: '저소득 청년 한부모(25~34세)의 자녀 양육 부담을 덜어주기 위해 아동양육비 추가 지원금을 인상하여 월 최대 33만원까지 지원합니다.', saved: false },
          { id: 5, title: '경계선 지능 청년 취업 지원', description: '지원의 사각지대에 있던 경계선 지능 청년들을 위해 기초 소양 교육부터 구직 기술 습득까지 이어지는 전용 프로그램을 신설하고 참여 수당을 지급합니다.', saved: false },
          { id: 6, title: '장애·이주 청년 맞춤 지원', description: '장애 대학생의 원격교육 및 보조기기 지원을 강화하고, 이주배경 청년의 한국 사회 초기 적응과 진로 상담을 위한 사례 관리를 지원합니다.', saved: false }
        ]
      },
      5: {
        details: [
          { id: 1, title: '청년 정신건강 검진·관리 강화', description: '정신건강 검진 주기를 2년으로 단축하고 우울증과 조기정신증 등 검사 항목을 확대하여 마음 건강 문제를 조기에 발견하고 치료를 지원합니다.', saved: false },
          { id: 2, title: '청년 마음건강 AI 시스템 도입', description: 'AI 키오스크와 비대면 상담 앱을 통해 정신건강 상담의 문턱을 낮추고, 검진 결과 위험군에게는 전문 심리상담 바우처를 즉시 연계합니다.', saved: false },
          { id: 3, title: '청년 자살예방 및 중독 관리 강화', description: '고위험군 청년 대상 SNS 상담과 AI 모니터링을 통해 자살 위기 신호를 조기에 발견하고, 마약 및 알코올 중독 치료를 위한 의료 지원을 강화합니다.', saved: false },
          { id: 4, title: '맞춤형 신체건강 서비스 제공', description: '청년사회서비스 식단을 통해 맞춤형 운동 및 식단 관리 서비스를 제공하고, 생활밀착형 체육시설 확충으로 신체 건강 증진 환경을 조성합니다.', saved: false },
          { id: 5, title: '청년 식생활 지원(천원의 아침밥 등)', description: '대학생 \'천원의 아침밥\' 지원 대상을 540만 명까지 확대하고, 중소기업 근로자 식비 보조 시범사업과 농식품 바우처 지원을 통해 건강한 식습관을 돕습니다.', saved: false }
        ]
      },
      6: {
        details: [
          { id: 1, title: '청년 문화예술 패스 확대', description: '지원 대상을 19~20세로 확대하고 비수도권 지원금을 최대 20만원으로 상향하며 영화와 도서 분야까지 사용 범위를 넓힙니다.', saved: false },
          { id: 2, title: 'K-패스 \'모두의 카드\' 도입', description: '월 5.5만원으로 지하철과 버스를 무제한 이용할 수 있는 패스를 신설하여 청년들의 교통비 부담을 획기적으로 절감합니다.', saved: false },
          { id: 3, title: '문화 콘텐츠 창작 및 인재 양성', description: '게임, 웹툰, OTT 등 유망 콘텐츠 분야 인재를 육성하고, 순수예술 청년 창작자에게 창작 활동에 전념할 수 있도록 연 900만원을 지원합니다.', saved: false },
          { id: 4, title: '국민연금 생애 첫 보험료 지원', description: '18~26세 청년이 국민연금에 가입할 때 첫 보험료 지원을 추진하여 연금 가입 기간 확보를 통한 미래 노후 소득 보장을 강화합니다.', saved: false },
          { id: 5, title: '군 장병 통신 및 연금 혜택', description: '군 장병 통신 요금 할인율을 높이고 군 복무 크레딧 인정 기간을 최대 12개월 이상으로 확대하여 국방 의무 이행에 대한 보상을 실질화합니다.', saved: false }
        ]
      }
    },
    'participation': {
      1: {
        details: [
          { id: 1, title: '대통령 주재 소통·공감 토크콘서트', description: '대통령이 청년농업인, 창업가 등 다양한 청년들과 정례적으로 직접 만나 주요 국정 이슈를 토론하고 정책 방향을 함께 고민하는 소통 채널을 운영합니다.', saved: false },
          { id: 2, title: '국무총리 주재 미래대화 1·2·3(K-토론나라)', description: '교육, 일자리, 문화 등 청년 삶과 밀접한 주제를 바탕으로 국무총리와 청년들이 격의 없이 소통하고 의견을 수렴하는 사회적 대화 플랫폼을 활성화합니다.', saved: false },
          { id: 3, title: '대통령비서실장 주재 청년미래자문단', description: '중장기적 사회 이슈를 청년의 시각에서 심도 있게 숙의하고 국정에 직접 자문 및 정책안을 건의할 수 있는 전담 기구를 운영합니다.', saved: false },
          { id: 4, title: '온·오프라인 통합 청년 토론회', description: '핵심 국가 의제에 대해 청년들이 온·오프라인으로 참여하여 직접 투표하고 해결 방안을 모색하는 새로운 소통의 장을 신설합니다.', saved: false },
          { id: 5, title: '청년정책 관계장관회의', description: '국무총리 주재로 부처 간 이견을 조정하고 청년 제안을 실제 정책에 신속히 반영하는 의사결정 체계를 구축하여 정책의 실행력을 높입니다.', saved: false }
        ]
      },
      2: {
        details: [
          { id: 1, title: '정부위원회 청년 위원 20% 상향', description: '정부의 주요 정책 결정 과정에 청년 참여를 제도적으로 보장하기 위해 정부위원회 내 청년 위원 위촉 비율을 기존 10%에서 20% 이상으로 확대합니다.', saved: false },
          { id: 2, title: '청년정책조정위원회 전문위 설치', description: '일자리, 교육, 주거 등 6개 분과의 청년 60명이 직접 사업을 제안하고 수립 과정에 주도적으로 참여하는 실질적인 거버넌스를 확립합니다.', saved: false },
          { id: 3, title: '청년보좌역 제도 내실화', description: '정책 수립 과정에서 청년의 목소리를 대변할 수 있도록 선발 방식에 정책 제안서 평가를 추가하고 부처별 실무 역할을 부여하여 제도를 강화합니다.', saved: false }
        ]
      },
      3: {
        details: [
          { id: 1, title: 'AI·빅데이터 기반 \'온통청년\' 고도화', description: '개인별 이력과 관심사를 AI로 정밀 분석하여 청년에게 꼭 필요한 맞춤형 정책 정보를 자동으로 추천해주는 지능형 시스템을 구축합니다.', saved: false },
          { id: 2, title: '온라인 정책 투표 및 피드백 기능', description: '온라인 통합 플랫폼 내에 투표 기능을 신설하여 청년들이 정부 정책에 대해 상시적으로 선호도를 표현하고 즉각적으로 의견을 전달할 수 있게 합니다.', saved: false },
          { id: 3, title: '청년신문고 및 정책 공모전 확대', description: '청년들이 일상에서 느끼는 창의적인 정책 아이디어를 언제든 자유롭게 제안하고 실제 정책으로 수용될 수 있는 온라인 소통 창구를 넓힙니다.', saved: false },
          { id: 4, title: '청년 참여 포인트제 도입 검토', description: '정책 참여 활동 이력을 마일리지로 적립하고, 이를 지원 사업 참여 시 우대 혜택이나 인센티브로 활용할 수 있는 보상 체계를 마련합니다.', saved: false }
        ]
      },
      4: {
        details: [
          { id: 1, title: '지역 청년지원센터 허브 기능 강화', description: '지역 청년지원센터를 청년정책 사업의 거점 기관으로 개편하고 고용·복지 센터 등 유관 기관과의 협업 체계를 구축합니다.', saved: false },
          { id: 2, title: '지역청년정책실험실 운영', description: '지역 청년의 수요를 반영한 혁신적인 사업 모델을 발굴하고 실험하여 우수 사례를 전국으로 확산시킵니다.', saved: false },
          { id: 3, title: '상향식 제안 체계(기초 → 광역 → 중앙)', description: '기초 지자체 청년센터에서 수렴된 청년들의 목소리가 중앙 정부 정책에 실질적으로 반영되는 파이프라인을 구축합니다.', saved: false },
          { id: 4, title: '청년친화도시 지정 및 지원', description: '매년 3개 도시를 청년친화도시로 지정하여 지역별 맞춤형 정책 수립과 재정 지원을 통해 청년의 지역 정주 여건을 개선합니다.', saved: false },
          { id: 5, title: '청년마을 모델 발전', description: '청년 주도의 지역 탐색과 일거리 실험 프로그램을 통해 청년의 지역 유입을 돕고 공동체 회복을 지원합니다.', saved: false },
          { id: 6, title: '청년두레(지역공동체) 창업 지원', description: '지역 청년공동체가 주도하는 관광 활성화를 위해 창업 및 경영 지원을 제공하여 지역 경제 활력을 제고합니다.', saved: false }
        ]
      },
      5: {
        details: [
          { id: 1, title: '청년 연령 기준 34세 상향 추진', description: '사회진출 지연 추세를 반영하여 법령상 청년 연령 기준을 상향 조정하고 지원 정책의 사각지대를 해소합니다.', saved: false },
          { id: 2, title: '청년인재 데이터베이스 구축', description: 'AI 기술을 활용해 분야별 우수 청년 인재를 발굴하고 정부 위원회 등 정책 결정 과정에 맞춤형 매칭을 지원합니다.', saved: false },
          { id: 3, title: '한국청년정책진흥원 신설 추진', description: '청년 정책을 통합적으로 전달하고 청년 참여 활동을 전문적으로 육성·지원하는 지속 가능한 전담 기구를 설립합니다.', saved: false },
          { id: 4, title: '사회보장제도 협의 절차 간소화', description: '지자체 자체 청년 사업 추진의 자율성을 높이기 위해 국조실에서 사전 스크린을 통한 신속 협의 체계를 마련합니다.', saved: false },
          { id: 5, title: '청년발전지표 개발', description: '청년의 삶의 질과 정책 참여 수준을 전국 및 지자체 단위로 정밀하게 측정할 수 있는 객관적인 지표를 개발하여 보급합니다.', saved: false },
          { id: 6, title: '청년 특화 연구 역량 강화', description: '청년의 관점에서 정책 효과성을 분석하고 현안에 맞는 대안을 제시할 수 있는 전문적인 연구 추진 체계를 구축합니다.', saved: false }
        ]
      },
      6: {
        details: [
          { id: 1, title: '(가칭)아태 청년교류단 설치', description: '한·미·중·일 4개국 청년들이 상호 파견 및 체류하며 네트워크를 형성하고 상호 이해를 높이는 문화 교류 플랫폼을 운영합니다.', saved: false },
          { id: 2, title: 'CAMPUS Asia 공동 학위 운영', description: '한·중·일 및 아세안 국가 간 대학 학생 교류와 공동·복수 학위 취득 지원 프로그램을 대폭 확대합니다.', saved: false },
          { id: 3, title: '분야별 국제 교류 확대', description: '첨단 기술, 역사, 문화 등 다양한 테마를 기반으로 청년들에게 글로벌 현장 경험과 전문 지식 습득의 기회를 제공합니다.', saved: false },
          { id: 4, title: '젠더 갈등 해소 공론장 운영', description: '성별 불균형 의제에 대해 청년들이 직접 참여하여 숙의하고 주도적으로 정책 대안을 도출하는 기회를 마련합니다.', saved: false },
          { id: 5, title: '성별 고정관념 해소 캠페인', description: '인식 개선 공모전 등을 통해 양성평등에 대한 사회적 이해를 넓히고 상호 존중하는 문화를 정착시킵니다.', saved: false }
        ]
      }
    }
  }

  return detailsMap[category.value]?.[parseInt(policyId.value)] || { details: [] }
})

// 현재 선택된 정책
const currentPolicy = computed(() => {
  const policy = subPolicies.value.find(p => p.id === parseInt(policyId.value))

  // 카테고리별 이미지 경로 매핑
  const imageMap: Record<string, Record<number, string>> = {
    'job': {
      1: '/images/policies/job/policy-1.png',
      2: '/images/policies/job/policy-2.png',
      3: '/images/policies/job/policy-3.png',
      4: '/images/policies/job/policy-4.png',
      5: '/images/policies/job/policy-5.png',
      6: '/images/policies/job/policy-6.png'
    },
    'housing': {
      1: '/images/policies/housing/policy-1.png',
      2: '/images/policies/housing/policy-2.png',
      3: '/images/policies/housing/policy-3.png',
      4: '/images/policies/housing/policy-4.png',
      5: '/images/policies/housing/policy-5.png',
      6: '/images/policies/housing/policy-6.png'
    },
    'education': {
      1: '/images/policies/education/policy-1.png',
      2: '/images/policies/education/policy-2.png',
      3: '/images/policies/education/policy-3.png',
      4: '/images/policies/education/policy-4.png',
      5: '/images/policies/education/policy-5.png',
      6: '/images/policies/education/policy-6.png'
    },
    'finance-welfare-culture': {
      1: '/images/policies/finance-welfare-culture/policy-1.png',
      2: '/images/policies/finance-welfare-culture/policy-2.png',
      3: '/images/policies/finance-welfare-culture/policy-3.png',
      4: '/images/policies/finance-welfare-culture/policy-4.png',
      5: '/images/policies/finance-welfare-culture/policy-5.png',
      6: '/images/policies/finance-welfare-culture/policy-6.png'
    },
    'participation': {
      1: '/images/policies/participation/policy-1.png',
      2: '/images/policies/participation/policy-2.png',
      3: '/images/policies/participation/policy-3.png',
      4: '/images/policies/participation/policy-4.png',
      5: '/images/policies/participation/policy-5.png',
      6: '/images/policies/participation/policy-6.png'
    }
  }

  const image = imageMap[category.value]?.[parseInt(policyId.value)] || 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800'

  return {
    ...policy,
    ...policyDetails.value,
    image
  }
})

// 카테고리 데이터 가져오기 (하드코딩)
const loadCategoryData = () => {
  try {
    // 카테고리 정보 매핑
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
  } catch (error: any) {
    console.error('카테고리 데이터 로딩 에러:', error)
    $q.notify({
      type: 'negative',
      message: '데이터를 불러오는 중 오류가 발생했습니다.',
      position: 'top'
    })
  }
}

onMounted(() => {
  loadCategoryData()
})

const handleBack = () => {
  router.push('/')
}

const handleBackToList = () => {
  router.push({
    name: 'category',
    params: {
      category: category.value
    }
  })
}

const navigateToPolicy = (id: number) => {
  router.push({
    name: 'policy-detail',
    params: {
      category: category.value,
      policyId: id.toString()
    }
  })
}

// 북마크 상태 확인
const isDetailBookmarked = (detailId: number): boolean => {
  return bookmarkedDetails.value.has(detailId)
}

const toggleBookmark = async (detailId: number) => {
  const policyIdNum = parseInt(policyId.value)
  const currentlySaved = bookmarkedDetails.value.has(detailId)

  try {
    if (currentlySaved) {
      // 북마크 제거
      await removeBookmark(category.value, policyIdNum, detailId, user.value?.id)
      bookmarkedDetails.value.delete(detailId)
      $q.notify({
        type: 'info',
        message: '관심 정책에서 제거되었습니다.',
        position: 'top'
      })
    } else {
      // 북마크 추가
      await addBookmark(category.value, policyIdNum, detailId, user.value?.id)
      bookmarkedDetails.value.add(detailId)
      $q.notify({
        type: 'positive',
        message: '관심 정책으로 저장되었습니다.',
        position: 'top'
      })
    }
  } catch (err: any) {
    console.error('북마크 토글 에러:', err)
    $q.notify({
      type: 'negative',
      message: '북마크 저장 중 오류가 발생했습니다.',
      position: 'top'
    })
  }
}

// 북마크 상태 초기화
const initializeBookmarks = async () => {
  // 로그인한 사용자는 DB에서 북마크 동기화
  if (user.value) {
    await fetchUserBookmarks(user.value.id)
  }

  // 현재 정책의 상세 항목들의 북마크 상태 설정
  if (currentPolicy.value.details) {
    const policyIdNum = parseInt(policyId.value)
    bookmarkedDetails.value.clear()
    currentPolicy.value.details.forEach((detail: any) => {
      if (isBookmarked(category.value, policyIdNum, detail.id)) {
        bookmarkedDetails.value.add(detail.id)
      }
    })
  }
}

// 페이지 로드 시 북마크 초기화
onMounted(() => {
  initializeBookmarks()
})
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

/* 콘텐츠 영역 */
.content-area {
  padding-top: 1.5rem;
  padding-bottom: 1.5rem;
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
}

@media (min-width: 768px) {
  .content-area {
    padding-top: 2rem;
    padding-bottom: 2rem;
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
  padding-top: 2rem;
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

.sidebar-button.active {
  background-color: #F97316;
  color: white;
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
    margin-bottom: 2rem;
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

.mobile-tab-button.active {
  background-color: #F97316;
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

/* 정책 상세 섹션 */
.policy-detail-sections {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
  max-width: 100%;
}

/* 정책 헤더 카드 */
.policy-header-card {
  background-color: white;
  border-radius: 1rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  border: 1px solid #F3F4F6;
  overflow: hidden;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 768px) {
  .policy-header-card {
    border-radius: 1.5rem;
  }
}

.policy-header-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 640px) {
  .policy-header-grid {
    gap: 1.5rem;
  }
}

@media (min-width: 768px) {
  .policy-header-grid {
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }
}

.policy-header-content {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

@media (min-width: 768px) {
  .policy-header-content {
    padding: 2rem;
  }
}

.policy-header-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

@media (min-width: 640px) {
  .policy-header-row {
    gap: 0.75rem;
  }
}

.policy-icon-wrapper {
  background-color: white;
  border: 1px solid #E5E7EB;
  padding: 0.5rem;
  border-radius: 0.5rem;
  flex-shrink: 0;
}

.policy-header-text {
  flex: 1;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

.policy-header-title {
  font-size: 1.125rem;
  font-weight: 700;
  line-height: 1.3;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 768px) {
  .policy-header-title {
    font-size: 1.25rem;
  }
}

@media (min-width: 1024px) {
  .policy-header-title {
    font-size: 1.5rem;
  }
}

.policy-header-description {
  font-size: 0.875rem;
  line-height: 1.6;
  color: #374151;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .policy-header-description {
    font-size: 1rem;
  }
}

@media (min-width: 768px) {
  .policy-header-description {
    font-size: 1.125rem;
  }
}

.policy-header-image {
  position: relative;
  height: 12rem;
  width: 100%;
}

@media (min-width: 640px) {
  .policy-header-image {
    height: 16rem;
  }
}

@media (min-width: 768px) {
  .policy-header-image {
    height: 20rem;
  }
}

/* 알림 배너 */
.notification-banner {
  background: linear-gradient(to right, #FFF7ED, rgba(167, 232, 189, 0.2));
  border: 1px solid #FED7AA;
  border-radius: 0.75rem;
  padding: 0.875rem 0.75rem;
  font-size: 0.875rem;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

@media (min-width: 640px) {
  .notification-banner {
    border-radius: 1rem;
    padding: 1.25rem 1rem;
    font-size: 1rem;
  }
}

.notification-icon-wrapper {
  background-color: white;
  border-radius: 9999px;
  padding: 0.375rem;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-text {
  flex: 1;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

/* 상세 내용 카드 */
.detail-cards-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
  max-width: 100%;
}

.detail-card {
  background-color: white;
  border: 1px solid #E5E7EB;
  border-radius: 0.5rem;
  padding: 1rem;
  transition: box-shadow 0.2s;
  position: relative;
  display: block;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

@media (min-width: 640px) {
  .detail-card {
    padding: 1.25rem;
  }
}

.detail-card:hover {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.detail-card-content {
  padding-right: 2.5rem;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

@media (min-width: 640px) {
  .detail-card-content {
    padding-right: 3rem;
  }
}

.detail-card-title {
  font-weight: 700;
  font-size: 1rem;
  color: #111827;
  margin-bottom: 0.5rem;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .detail-card-title {
    font-size: 1.125rem;
    margin-bottom: 0.75rem;
  }
}

.detail-card-description {
  color: #374151;
  line-height: 1.6;
  margin: 0;
  font-size: 0.875rem;
  word-wrap: break-word;
  overflow-wrap: break-word;
  width: 100%;
}

@media (min-width: 640px) {
  .detail-card-description {
    font-size: 1rem;
  }
}

.bookmark-button {
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.5rem;
  border-radius: 0.5rem;
  transition: all 0.2s;
  background-color: transparent;
  border: none;
  cursor: pointer;
  color: #9CA3AF;
  display: flex;
  align-items: center;
  justify-content: center;
}

@media (min-width: 640px) {
  .bookmark-button {
    top: 1.25rem;
    right: 1.25rem;
    padding: 0.625rem;
  }
}

.bookmark-button:hover {
  background-color: #F3F4F6;
}

.bookmark-button.saved {
  color: #F97316;
}

/* 목록으로 돌아가기 버튼 */
.back-button-wrapper {
  background-color: white;
  border-radius: 1rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  border: 1px solid #F3F4F6;
  padding: 1rem;
}

@media (min-width: 640px) {
  .back-button-wrapper {
    border-radius: 1.5rem;
    padding: 1.5rem;
  }
}

.back-to-list-button {
  width: 100%;
  border: 1px solid #E5E7EB;
  color: #374151;
  font-weight: 500;
  background-color: white;
}

.back-to-list-button:hover {
  background-color: #F9FAFB;
}
</style>
