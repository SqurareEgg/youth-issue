<template>
  <section class="bg-white py-6 sm:py-16 lg:py-20 border-b border-gray-100">
    <div class="container mx-auto px-4 sm:px-6">
      <div class="hero-grid">
        <!-- 텍스트 콘텐츠 (데스크탑: 왼쪽, 모바일: 위) -->
        <div class="order-first">
          <h1>
            대전 청년에게 꼭 필요한<br>모든 혜택, 청년있슈
          </h1>

          <div class="hero-content">
            <div class="info-card">
              <p class="hero-description">
                19세부터 39세까지, 대전에 거주하는 청년이라면 누구나 신청할 수 있는 중앙정부와 지자체 정책을 한곳에 모았습니다.
              </p>

              <div class="card-divider"></div>

              <div class="hero-bullets">
                <div class="bullet-item">
                  <span class="text-primary bullet-dot">•</span>
                  <span class="bullet-text">일자리, 주거, 교육, 복지, 참여까지 분야별 정책 안내</span>
                </div>
                <div class="bullet-item">
                  <span class="text-primary bullet-dot">•</span>
                  <span class="bullet-text">본인에게 맞는 정책을 쉽게 찾고 학습할 수 있는 시스템</span>
                </div>
                <div class="bullet-item">
                  <span class="text-primary bullet-dot">•</span>
                  <span class="bullet-text">정책 변경사항과 신규 혜택 실시간 업데이트</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 캐러셀 (데스크탑: 오른쪽, 모바일: 아래) -->
        <div class="order-last">
          <q-carousel
            v-model="slide"
            animated
            arrows
            navigation
            infinite
            autoplay
            :autoplay-interval="4000"
            transition-prev="slide-right"
            transition-next="slide-left"
            class="hero-carousel"
          >
            <q-carousel-slide
              v-for="(news, index) in newsSlides"
              :key="index"
              :name="index"
              style="padding: 1.5rem; background-color: white; border-radius: 1.5rem;"
            >
              <div style="height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <img
                  :src="news.image"
                  :alt="news.title"
                  style="width: 100%; height: 100%; object-fit: contain; border-radius: 0.75rem;"
                />
              </div>
            </q-carousel-slide>
          </q-carousel>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import cardNewsImage from '../../assets/images/08c6d18da65336d7d8948b092b853e4fa233a8cf.png'

const slide = ref(0)

const newsSlides = [
  {
    title: '2026 꼭 알아야 할 청년정책',
    image: cardNewsImage
  },
  {
    title: '청년 일자리 지원 확대',
    image: cardNewsImage
  },
  {
    title: '주거 안정 지원 정책',
    image: cardNewsImage
  }
]
</script>

<style scoped>
.text-primary {
  color: #F97316;
}

.hero-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
  align-items: center;
}

@media (min-width: 768px) {
  .hero-grid {
    grid-template-columns: 1.2fr 1fr;
    gap: 3rem;
    align-items: stretch;
  }
}

@media (min-width: 1024px) {
  .hero-grid {
    gap: 4rem;
  }
}

.order-first {
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .order-first {
    justify-content: center;
  }
}

.order-last {
  display: flex;
}

@media (min-width: 768px) {
  .order-last {
    align-items: center;
  }
}

h1 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 1.25rem;
  line-height: 1.25;
  letter-spacing: -0.02em;
}

@media (min-width: 640px) {
  h1 {
    font-size: 2.25rem;
    letter-spacing: normal;
  }
}

@media (min-width: 768px) {
  h1 {
    font-size: 2.5rem;
    margin-bottom: 2.5rem;
  }
}

.hero-content {
  margin-bottom: 0;
}

@media (min-width: 768px) {
  .hero-content {
    margin-bottom: 2rem;
  }
}

.info-card {
  background-color: #F9FAFB;
  border: 1px solid #E5E7EB;
  border-radius: 1rem;
  padding: 1.125rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
}

@media (min-width: 640px) {
  .info-card {
    padding: 2rem;
  }
}

.card-divider {
  height: 1px;
  background-color: #E5E7EB;
  margin: 0.875rem 0;
}

@media (min-width: 640px) {
  .card-divider {
    margin: 1.5rem 0;
  }
}

.hero-description {
  font-size: 1rem;
  color: #374151;
  line-height: 1.75;
  margin-bottom: 0;
}

@media (min-width: 640px) {
  .hero-description {
    font-size: 1.125rem;
  }
}

.hero-bullets {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

@media (min-width: 640px) {
  .hero-bullets {
    gap: 0.75rem;
  }
}

.bullet-item {
  display: flex;
  align-items: start;
  gap: 0.75rem;
}

.bullet-dot {
  margin-top: 0.25rem;
  font-size: 1.125rem;
  font-weight: 600;
  flex-shrink: 0;
}

.bullet-text {
  line-height: 1.75;
  color: #4B5563;
  font-size: 0.875rem;
}

@media (min-width: 640px) {
  .bullet-text {
    font-size: 1rem;
  }
}

.hero-carousel {
  background-color: transparent;
  border-radius: 1.5rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  height: 280px;
  width: 100%;
}

@media (min-width: 640px) {
  .hero-carousel {
    height: 350px;
  }
}

@media (min-width: 768px) {
  .hero-carousel {
    height: 100%;
    min-height: 400px;
  }
}
</style>
