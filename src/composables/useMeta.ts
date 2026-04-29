import { onMounted, onUnmounted } from 'vue'

export interface MetaOptions {
  title?: string
  description?: string
  keywords?: string
  ogTitle?: string
  ogDescription?: string
  ogImage?: string
  ogUrl?: string
  canonicalUrl?: string
}

const BASE_URL = 'https://youth-policy.vercel.app' // TODO: 실제 도메인으로 변경
const DEFAULT_TITLE = '청년있슈 - 청년을 위한 6가지 필수 정책 교육'
const DEFAULT_DESCRIPTION = '일자리, 주거, 교육, 복지·문화, 참여 등 청년을 위한 6가지 필수 정책을 쉽고 재미있게 배우는 청년있슈 공식 사이트입니다.'
const DEFAULT_IMAGE = `${BASE_URL}/og-image.jpg`

export function useMeta(options: MetaOptions = {}) {
  const metaTags: HTMLMetaElement[] = []
  const linkTags: HTMLLinkElement[] = []

  const setMeta = () => {
    // 페이지 제목 설정
    const title = options.title ? `${options.title} - 청년있슈` : DEFAULT_TITLE
    document.title = title

    // 메타 태그 생성 헬퍼
    const createMetaTag = (name: string, content: string, isProperty = false) => {
      const existingTag = document.querySelector(
        isProperty ? `meta[property="${name}"]` : `meta[name="${name}"]`
      ) as HTMLMetaElement

      if (existingTag) {
        existingTag.content = content
        return null
      } else {
        const meta = document.createElement('meta')
        if (isProperty) {
          meta.setAttribute('property', name)
        } else {
          meta.setAttribute('name', name)
        }
        meta.content = content
        document.head.appendChild(meta)
        return meta
      }
    }

    // Description
    if (options.description) {
      const descTag = createMetaTag('description', options.description)
      if (descTag) metaTags.push(descTag)
    }

    // Keywords
    if (options.keywords) {
      const keyTag = createMetaTag('keywords', options.keywords)
      if (keyTag) metaTags.push(keyTag)
    }

    // Open Graph 메타 태그
    const ogTitle = options.ogTitle || options.title || DEFAULT_TITLE
    const ogDescription = options.ogDescription || options.description || DEFAULT_DESCRIPTION
    const ogImage = options.ogImage || DEFAULT_IMAGE
    const ogUrl = options.ogUrl || window.location.href

    const ogTitleTag = createMetaTag('og:title', ogTitle, true)
    if (ogTitleTag) metaTags.push(ogTitleTag)

    const ogDescTag = createMetaTag('og:description', ogDescription, true)
    if (ogDescTag) metaTags.push(ogDescTag)

    const ogImageTag = createMetaTag('og:image', ogImage, true)
    if (ogImageTag) metaTags.push(ogImageTag)

    const ogUrlTag = createMetaTag('og:url', ogUrl, true)
    if (ogUrlTag) metaTags.push(ogUrlTag)

    // Twitter Card
    const twitterTitleTag = createMetaTag('twitter:title', ogTitle)
    if (twitterTitleTag) metaTags.push(twitterTitleTag)

    const twitterDescTag = createMetaTag('twitter:description', ogDescription)
    if (twitterDescTag) metaTags.push(twitterDescTag)

    const twitterImageTag = createMetaTag('twitter:image', ogImage)
    if (twitterImageTag) metaTags.push(twitterImageTag)

    // Canonical URL
    const canonicalUrl = options.canonicalUrl || window.location.href
    const existingCanonical = document.querySelector('link[rel="canonical"]') as HTMLLinkElement

    if (existingCanonical) {
      existingCanonical.href = canonicalUrl
    } else {
      const canonical = document.createElement('link')
      canonical.rel = 'canonical'
      canonical.href = canonicalUrl
      document.head.appendChild(canonical)
      linkTags.push(canonical)
    }
  }

  const cleanup = () => {
    // 생성한 메타 태그 제거 (원래 상태로 복원)
    metaTags.forEach(tag => {
      if (tag.parentNode) {
        tag.parentNode.removeChild(tag)
      }
    })
    linkTags.forEach(tag => {
      if (tag.parentNode) {
        tag.parentNode.removeChild(tag)
      }
    })
  }

  onMounted(() => {
    setMeta()
  })

  onUnmounted(() => {
    cleanup()
  })

  return {
    setMeta,
    cleanup
  }
}

// 카테고리별 기본 메타 정보
export const categoryMeta: Record<string, MetaOptions> = {
  'job': {
    title: '일자리 정책',
    description: '청년 일자리 첫걸음 보장제, 실무 역량 강화, 창업 생태계 등 청년 일자리 정책을 알아보세요.',
    keywords: '청년 일자리, 취업 지원, 실무 역량, 창업 지원, 고용 정책',
    ogImage: `${BASE_URL}/images/category-job.jpg`
  },
  'housing': {
    title: '주거 정책',
    description: '청년 공공주택, 월세 지원, 전세자금 대출 등 청년 주거 안정을 위한 정책을 확인하세요.',
    keywords: '청년 주거, 공공주택, 월세 지원, 전세자금, 주거 복지',
    ogImage: `${BASE_URL}/images/category-housing.jpg`
  },
  'education': {
    title: '교육 정책',
    description: 'AI·SW 역량 강화, 국가장학금, 전문인재 양성 등 청년 교육 지원 정책을 알아보세요.',
    keywords: '청년 교육, AI 교육, 국가장학금, 전문인재, 역량 강화',
    ogImage: `${BASE_URL}/images/category-education.jpg`
  },
  'finance-welfare-culture': {
    title: '금융·복지·문화 정책',
    description: '청년미래적금, 건강 관리, 문화 패스 등 청년의 삶의 질을 높이는 정책을 확인하세요.',
    keywords: '청년 금융, 청년 복지, 문화 지원, 자산 형성, 건강 관리',
    ogImage: `${BASE_URL}/images/category-finance.jpg`
  },
  'participation': {
    title: '참여 정책',
    description: '청년 정책 참여, 국정 소통, 지역 생태계 조성 등 청년의 목소리를 반영하는 정책을 알아보세요.',
    keywords: '청년 참여, 정책 참여, 국정 소통, 청년 거버넌스, 지역 생태계',
    ogImage: `${BASE_URL}/images/category-participation.jpg`
  }
}
