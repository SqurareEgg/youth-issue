<template>
  <div class="min-h-screen bg-white">
    <FigmaHeader />
    <FigmaHeroSection />
    <FigmaServiceCards />
    <FigmaFooter />
  </div>
</template>

<script setup lang="ts">
import FigmaHeader from '../components/figma/FigmaHeader.vue'
import FigmaHeroSection from '../components/figma/FigmaHeroSection.vue'
import FigmaServiceCards from '../components/figma/FigmaServiceCards.vue'
import FigmaFooter from '../components/figma/FigmaFooter.vue'
import { useMeta } from '../composables/useMeta'

// SEO 메타 태그 설정
useMeta({
  title: '청년을 위한 6가지 필수 정책 교육',
  description: '일자리, 주거, 교육, 금융·복지·문화, 참여 등 청년을 위한 6가지 필수 정책을 영상과 퀴즈로 쉽고 재미있게 배우세요.',
  keywords: '청년정책, 청년복지, 일자리지원, 주거지원, 교육지원, 청년있슈, 청년정책교육',
  canonicalUrl: 'https://youth-policy.vercel.app/'
})
</script>
