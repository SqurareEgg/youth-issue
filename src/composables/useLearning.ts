import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { Database } from '../types/supabase'

type Video = Database['public']['Tables']['videos']['Row']
type VideoProgress = Database['public']['Tables']['user_video_progress']['Row']
type Quiz = Database['public']['Tables']['quizzes']['Row']
type QuizQuestion = Database['public']['Tables']['quiz_questions']['Row']
type QuizResult = Database['public']['Tables']['user_quiz_results']['Row']
type QnA = Database['public']['Tables']['qna']['Row']
type LearningProgress = Database['public']['Views']['user_learning_progress']['Row']

export function useLearning() {
  const videos = ref<Video[]>([])
  const quizzes = ref<Quiz[]>([])
  const qnaList = ref<QnA[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // ============================================
  // 영상 관련
  // ============================================

  // 카테고리별 영상 가져오기
  const fetchVideosByCategory = async (categoryId: number, userId?: string) => {
    loading.value = true
    error.value = null

    try {
      const { data: videoData, error: fetchError } = await supabase
        .from('videos')
        .select('*')
        .eq('category_id', categoryId)
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      // 사용자 진도 정보 가져오기
      if (userId) {
        const { data: progressData } = await supabase
          .from('user_video_progress')
          .select('*')
          .eq('user_id', userId)

        // 영상과 진도 정보 병합
        videos.value = (videoData || []).map((video) => {
          const progress = progressData?.find((p) => p.video_id === video.id)
          return {
            ...video,
            progress,
            completed: progress?.completed || false
          }
        }) as any

        return videos.value
      }

      videos.value = videoData || []
      return videoData
    } catch (err: any) {
      error.value = err.message
      console.error('영상 가져오기 에러:', err.message)
      return []
    } finally {
      loading.value = false
    }
  }

  // 영상 진도 업데이트
  const updateVideoProgress = async (
    userId: string,
    videoId: number,
    lastPosition: number,
    completed: boolean = false
  ) => {
    try {
      const { error: upsertError } = await supabase
        .from('user_video_progress')
        .upsert({
          user_id: userId,
          video_id: videoId,
          last_position: lastPosition,
          completed: completed,
          completed_at: completed ? new Date().toISOString() : null
        }, {
          onConflict: 'user_id,video_id'
        })

      if (upsertError) throw upsertError

      return { success: true }
    } catch (err: any) {
      console.error('영상 진도 업데이트 에러:', err.message)
      return { success: false, error: err.message }
    }
  }

  // 영상 완료 처리
  const completeVideo = async (userId: string, videoId: number) => {
    return updateVideoProgress(userId, videoId, 0, true)
  }

  // ============================================
  // 퀴즈 관련
  // ============================================

  // 카테고리별 퀴즈 가져오기
  const fetchQuizzesByCategory = async (categoryId: number, userId?: string) => {
    loading.value = true
    error.value = null

    try {
      const { data: quizData, error: fetchError } = await supabase
        .from('quizzes')
        .select('*')
        .eq('category_id', categoryId)
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      // 각 퀴즈의 문제 개수 가져오기
      const quizzesWithQuestionCount = await Promise.all(
        (quizData || []).map(async (quiz) => {
          const { count } = await supabase
            .from('quiz_questions')
            .select('*', { count: 'exact', head: true })
            .eq('quiz_id', quiz.id)

          return {
            ...quiz,
            questionCount: count || 0
          }
        })
      )

      // 사용자 최고 점수 가져오기
      if (userId) {
        const { data: resultsData } = await supabase
          .from('user_quiz_results')
          .select('quiz_id, score')
          .eq('user_id', userId)

        // 퀴즈별 최고 점수 계산
        const bestScores = resultsData?.reduce((acc, result) => {
          if (!acc[result.quiz_id] || acc[result.quiz_id] < result.score) {
            acc[result.quiz_id] = result.score
          }
          return acc
        }, {} as Record<number, number>)

        // 퀴즈와 결과 정보 병합
        quizzes.value = quizzesWithQuestionCount.map((quiz) => ({
          ...quiz,
          bestScore: bestScores?.[quiz.id] || null,
          completed: (bestScores?.[quiz.id] || 0) >= 60
        })) as any

        return quizzes.value
      }

      quizzes.value = quizzesWithQuestionCount as any
      return quizzesWithQuestionCount
    } catch (err: any) {
      error.value = err.message
      console.error('퀴즈 가져오기 에러:', err.message)
      return []
    } finally {
      loading.value = false
    }
  }

  // 퀴즈 문제 가져오기
  const fetchQuizQuestions = async (quizId: number) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('quiz_questions')
        .select('*')
        .eq('quiz_id', quizId)
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      return data || []
    } catch (err: any) {
      console.error('퀴즈 문제 가져오기 에러:', err.message)
      return []
    }
  }

  // 퀴즈 제출
  const submitQuiz = async (
    userId: string,
    quizId: number,
    answers: Record<number, number>
  ) => {
    try {
      // 퀴즈 문제 가져오기
      const questions = await fetchQuizQuestions(quizId)

      // 정답 체크
      let correctCount = 0
      questions.forEach((q) => {
        if (answers[q.id] === q.correct_answer) {
          correctCount++
        }
      })

      const totalQuestions = questions.length
      const score = Math.round((correctCount / totalQuestions) * 100)

      // 결과 저장
      const { error: insertError } = await supabase
        .from('user_quiz_results')
        .insert({
          user_id: userId,
          quiz_id: quizId,
          score: score,
          total_questions: totalQuestions,
          correct_answers: correctCount,
          answers: answers as any
        })

      if (insertError) throw insertError

      return {
        success: true,
        score,
        correctCount,
        totalQuestions,
        passed: score >= 60
      }
    } catch (err: any) {
      console.error('퀴즈 제출 에러:', err.message)
      return { success: false, error: err.message }
    }
  }

  // 퀴즈 결과 가져오기
  const fetchQuizResults = async (userId: string, quizId: number) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('user_quiz_results')
        .select('*')
        .eq('user_id', userId)
        .eq('quiz_id', quizId)
        .order('completed_at', { ascending: false })

      if (fetchError) throw fetchError

      return data || []
    } catch (err: any) {
      console.error('퀴즈 결과 가져오기 에러:', err.message)
      return []
    }
  }

  // ============================================
  // Q&A 관련
  // ============================================

  // 카테고리별 Q&A 가져오기
  const fetchQnAByCategory = async (categoryId: number) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('qna')
        .select('*')
        .eq('category_id', categoryId)
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      qnaList.value = data || []
      return data
    } catch (err: any) {
      error.value = err.message
      console.error('Q&A 가져오기 에러:', err.message)
      return []
    } finally {
      loading.value = false
    }
  }

  // ============================================
  // 학습 진도율
  // ============================================

  // 사용자 학습 진도율 가져오기
  const fetchLearningProgress = async (userId: string, categoryId?: number) => {
    try {
      let query = supabase
        .from('user_learning_progress')
        .select('*')
        .eq('user_id', userId)

      if (categoryId) {
        query = query.eq('category_id', categoryId)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      return categoryId ? (data?.[0] || null) : (data || [])
    } catch (err: any) {
      console.error('학습 진도율 가져오기 에러:', err.message)
      return categoryId ? null : []
    }
  }

  // 사용자 영상 진행 상태 가져오기
  const fetchVideoProgress = async (userId: string, categoryId: number) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('user_video_progress')
        .select('*, videos!inner(category_id)')
        .eq('user_id', userId)
        .eq('videos.category_id', categoryId)

      if (fetchError) throw fetchError

      return data || []
    } catch (err: any) {
      console.error('영상 진행 상태 가져오기 에러:', err.message)
      return []
    }
  }

  // 사용자 퀴즈 진행 상태 가져오기
  const fetchQuizProgress = async (userId: string, categoryId: number) => {
    try {
      const { data, error: fetchError } = await supabase
        .from('user_quiz_results')
        .select('quiz_id, score, completed_at, quizzes!inner(category_id)')
        .eq('user_id', userId)
        .eq('quizzes.category_id', categoryId)
        .order('completed_at', { ascending: false })

      if (fetchError) throw fetchError

      // 각 퀴즈별 최고 점수만 추출
      const bestResults = data?.reduce((acc: any[], result: any) => {
        const existing = acc.find(r => r.quiz_id === result.quiz_id)
        if (!existing || existing.score < result.score) {
          const filtered = acc.filter(r => r.quiz_id !== result.quiz_id)
          filtered.push({
            quiz_id: result.quiz_id,
            score: result.score,
            passed: result.score >= 60,
            completed: true
          })
          return filtered
        }
        return acc
      }, [])

      return bestResults || []
    } catch (err: any) {
      console.error('퀴즈 진행 상태 가져오기 에러:', err.message)
      return []
    }
  }

  return {
    videos,
    quizzes,
    qnaList,
    loading,
    error,
    // 영상
    fetchVideosByCategory,
    updateVideoProgress,
    completeVideo,
    // 퀴즈
    fetchQuizzesByCategory,
    fetchQuizQuestions,
    submitQuiz,
    fetchQuizResults,
    // Q&A
    fetchQnAByCategory,
    // 진도율
    fetchLearningProgress,
    fetchVideoProgress,
    fetchQuizProgress
  }
}
