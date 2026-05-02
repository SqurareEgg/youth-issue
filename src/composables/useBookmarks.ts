import { ref } from 'vue'
import { supabase } from '../lib/supabase'

export function useBookmarks() {
  const loading = ref(false)
  const error = ref<string | null>(null)

  // 북마크 키 생성 (예: "job-1-2" = 일자리 정책 1번의 상세 2번)
  const createBookmarkKey = (category: string, policyId: number, detailId: number) => {
    return `${category}-${policyId}-${detailId}`
  }

  // 로컬스토리지에서 북마크 목록 가져오기
  const getLocalBookmarks = (): Set<string> => {
    try {
      const saved = localStorage.getItem('policy-bookmarks')
      return saved ? new Set(JSON.parse(saved)) : new Set()
    } catch {
      return new Set()
    }
  }

  // 로컬스토리지에 북마크 저장
  const saveLocalBookmarks = (bookmarks: Set<string>) => {
    try {
      localStorage.setItem('policy-bookmarks', JSON.stringify([...bookmarks]))
    } catch (err) {
      console.error('로컬 북마크 저장 실패:', err)
    }
  }

  // 북마크 추가
  const addBookmark = async (
    category: string,
    policyId: number,
    detailId: number,
    userId?: string
  ) => {
    const key = createBookmarkKey(category, policyId, detailId)

    // 로컬스토리지에 저장
    const bookmarks = getLocalBookmarks()
    bookmarks.add(key)
    saveLocalBookmarks(bookmarks)

    // 로그인한 사용자는 DB에도 저장
    if (userId) {
      try {
        const { error: insertError } = await supabase
          .from('user_policy_bookmarks')
          .insert({
            user_id: userId,
            bookmark_key: key,
            category: category,
            policy_id: policyId,
            detail_id: detailId
          })

        if (insertError && insertError.code !== '23505') { // 중복 에러 무시
          throw insertError
        }

        return { success: true }
      } catch (err: any) {
        console.error('DB 북마크 저장 에러:', err.message)
        return { success: false, error: err.message }
      }
    }

    return { success: true }
  }

  // 북마크 제거
  const removeBookmark = async (
    category: string,
    policyId: number,
    detailId: number,
    userId?: string
  ) => {
    const key = createBookmarkKey(category, policyId, detailId)

    // 로컬스토리지에서 제거
    const bookmarks = getLocalBookmarks()
    bookmarks.delete(key)
    saveLocalBookmarks(bookmarks)

    // 로그인한 사용자는 DB에서도 제거
    if (userId) {
      try {
        const { error: deleteError } = await supabase
          .from('user_policy_bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('bookmark_key', key)

        if (deleteError) throw deleteError

        return { success: true }
      } catch (err: any) {
        console.error('DB 북마크 제거 에러:', err.message)
        return { success: false, error: err.message }
      }
    }

    return { success: true }
  }

  // 북마크 여부 확인
  const isBookmarked = (category: string, policyId: number, detailId: number): boolean => {
    const key = createBookmarkKey(category, policyId, detailId)
    const bookmarks = getLocalBookmarks()
    return bookmarks.has(key)
  }

  // 사용자 북마크 목록 가져오기 (DB)
  const fetchUserBookmarks = async (userId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('user_policy_bookmarks')
        .select('*')
        .eq('user_id', userId)

      if (fetchError) throw fetchError

      // DB 데이터를 로컬스토리지와 동기화
      const bookmarks = getLocalBookmarks()
      data?.forEach(bookmark => {
        bookmarks.add(bookmark.bookmark_key)
      })
      saveLocalBookmarks(bookmarks)

      return data || []
    } catch (err: any) {
      error.value = err.message
      console.error('북마크 목록 가져오기 에러:', err.message)
      return []
    } finally {
      loading.value = false
    }
  }

  return {
    loading,
    error,
    addBookmark,
    removeBookmark,
    isBookmarked,
    fetchUserBookmarks,
    getLocalBookmarks
  }
}
