import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  ActivityIndicator,
  ScrollView,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { useQuiz } from '../../src/hooks/useArtworks';

const { width } = Dimensions.get('window');
const IMAGE_WIDTH = width - Spacing.lg * 2;

type EraType = 'renaissance' | 'baroque' | 'impressionism' | 'modern' | 'japanese' | 'all';

export default function QuizScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();

  // IDから時代を判定
  const getEraFromId = (quizId: string): EraType => {
    const eraMap: Record<string, EraType> = {
      daily: 'all',
      renaissance: 'renaissance',
      baroque: 'baroque',
      impressionism: 'impressionism',
      modern: 'modern',
      japanese: 'japanese',
    };
    return eraMap[quizId] || 'all';
  };

  const era = getEraFromId(id || 'daily');
  const { questions, loading, error, refetch } = useQuiz(era, 10);

  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [showResult, setShowResult] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);

  const currentQuestion = questions[currentIndex];
  const totalQuestions = questions.length;
  const progress = totalQuestions > 0 ? ((currentIndex + 1) / totalQuestions) * 100 : 0;

  const handleSelectAnswer = (answer: string) => {
    if (showResult) return;
    setSelectedAnswer(answer);
    setShowResult(true);

    if (answer === currentQuestion?.correctAnswer) {
      setCorrectCount((prev) => prev + 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < totalQuestions - 1) {
      setCurrentIndex((prev) => prev + 1);
      setSelectedAnswer(null);
      setShowResult(false);
    } else {
      // Quiz complete - navigate to artwork detail of last question
      router.replace(`/artwork/${currentQuestion?.artwork.id}`);
    }
  };

  const handleClose = () => {
    router.back();
  };

  const getOptionStyle = (option: string) => {
    if (!showResult) {
      return selectedAnswer === option
        ? { borderColor: Colors.primary, backgroundColor: 'rgba(74, 123, 247, 0.08)' }
        : { borderColor: '#E5E7EB' };
    }

    if (option === currentQuestion?.correctAnswer) {
      return { borderColor: Colors.success, backgroundColor: 'rgba(76, 175, 80, 0.08)' };
    }

    if (selectedAnswer === option && option !== currentQuestion?.correctAnswer) {
      return { borderColor: Colors.error, backgroundColor: 'rgba(255, 107, 107, 0.08)' };
    }

    return { borderColor: '#E5E7EB' };
  };

  const getOptionTextColor = (option: string) => {
    if (!showResult) {
      return selectedAnswer === option ? Colors.primary : '#374151';
    }
    if (option === currentQuestion?.correctAnswer) {
      return Colors.success;
    }
    if (selectedAnswer === option && option !== currentQuestion?.correctAnswer) {
      return Colors.error;
    }
    return '#374151';
  };

  // ローディング表示
  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={handleClose} style={styles.headerButton}>
            <Ionicons name="close" size={24} color="#374151" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>美術検定</Text>
          <View style={styles.headerButton} />
        </View>
        <View style={styles.loading}>
          <ActivityIndicator size="large" color={Colors.primary} />
          <Text style={styles.loadingText}>作品を読み込み中...</Text>
          <Text style={styles.loadingSubtext}>メトロポリタン美術館から取得しています</Text>
        </View>
      </SafeAreaView>
    );
  }

  // エラー表示
  if (error || !currentQuestion) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={handleClose} style={styles.headerButton}>
            <Ionicons name="close" size={24} color="#374151" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>美術検定</Text>
          <View style={styles.headerButton} />
        </View>
        <View style={styles.loading}>
          <Ionicons name="alert-circle-outline" size={48} color={Colors.error} />
          <Text style={styles.loadingText}>読み込みに失敗しました</Text>
          <TouchableOpacity style={styles.retryButton} onPress={refetch}>
            <Text style={styles.retryButtonText}>再試行</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleClose} style={styles.headerButton}>
          <Ionicons name="close" size={24} color="#374151" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>美術検定</Text>
        <TouchableOpacity style={styles.headerButton}>
          <Ionicons name="information-circle-outline" size={24} color="#374151" />
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Progress */}
        <View style={styles.progressSection}>
          <View style={styles.progressHeader}>
            <Text style={styles.progressLabel}>進捗</Text>
            <Text style={styles.progressCount}>
              {currentIndex + 1} / {totalQuestions}
            </Text>
          </View>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>
        </View>

        {/* Artwork Image with Frame */}
        <View style={styles.frameContainer}>
          <View style={styles.frame}>
            <Image
              source={{ uri: currentQuestion.artwork.imageUrl }}
              style={styles.artworkImage}
              resizeMode="contain"
            />
          </View>
        </View>

        {/* Question */}
        <View style={styles.questionSection}>
          {showResult ? (
            <>
              <Text style={styles.artworkTitle}>
                『{currentQuestion.artwork.title}』
              </Text>
              <Text style={styles.correctAnswerLabel}>
                作者: {currentQuestion.correctAnswer}
              </Text>
            </>
          ) : (
            <>
              <Text style={styles.questionText}>
                {currentQuestion.question}
              </Text>
              <Text style={styles.questionHint}>
                下の選択肢から正しい作者を選んでください
              </Text>
            </>
          )}
        </View>

        {/* Options */}
        <View style={styles.optionsContainer}>
          {currentQuestion.options.map((option, index) => (
            <TouchableOpacity
              key={index}
              style={[styles.optionButton, getOptionStyle(option)]}
              onPress={() => handleSelectAnswer(option)}
              disabled={showResult}
            >
              <Text style={[styles.optionText, { color: getOptionTextColor(option) }]}>
                {option}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Next Button */}
        {showResult && (
          <TouchableOpacity style={styles.nextButton} onPress={handleNext}>
            <Text style={styles.nextButtonText}>
              {currentIndex < totalQuestions - 1 ? '次の問題へ' : '結果を見る'}
            </Text>
            <Ionicons name="arrow-forward" size={20} color="#fff" />
          </TouchableOpacity>
        )}

        <View style={{ height: Spacing.xl }} />
      </ScrollView>

      {/* Footer */}
      <View style={styles.footer}>
        <TouchableOpacity style={styles.footerIcon}>
          <Ionicons name="bookmark-outline" size={24} color="#9CA3AF" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.footerIcon}>
          <Ionicons name="share-outline" size={24} color="#9CA3AF" />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  loading: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: Spacing.md,
  },
  loadingText: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.lg,
    color: '#374151',
    marginTop: Spacing.md,
  },
  loadingSubtext: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    color: '#9CA3AF',
  },
  retryButton: {
    marginTop: Spacing.lg,
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.xl,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.full,
  },
  retryButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },
  headerButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.sm,
    color: '#374151',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
  progressSection: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.md,
    paddingBottom: Spacing.sm,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.xs,
  },
  progressLabel: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.xs,
    color: '#6B7280',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
  progressCount: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.sm,
    color: Colors.primary,
  },
  progressBar: {
    height: 6,
    borderRadius: 3,
    backgroundColor: '#E5E7EB',
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: 3,
  },
  frameContainer: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    alignItems: 'center',
  },
  frame: {
    width: IMAGE_WIDTH,
    backgroundColor: '#F9FAFB',
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
  },
  artworkImage: {
    width: '100%',
    height: 280,
    borderRadius: BorderRadius.md,
  },
  questionSection: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    alignItems: 'center',
  },
  questionText: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.xl,
    color: '#111827',
    textAlign: 'center',
  },
  questionHint: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    color: '#6B7280',
    textAlign: 'center',
    marginTop: Spacing.xs,
    fontStyle: 'italic',
  },
  artworkTitle: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.xl,
    color: '#111827',
    textAlign: 'center',
  },
  correctAnswerLabel: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.md,
    color: Colors.primary,
    textAlign: 'center',
    marginTop: Spacing.sm,
  },
  optionsContainer: {
    paddingHorizontal: Spacing.lg,
    gap: Spacing.sm,
  },
  optionButton: {
    borderWidth: 2,
    borderRadius: BorderRadius.full,
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.lg,
    backgroundColor: '#FFFFFF',
  },
  optionText: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.md,
    textAlign: 'center',
  },
  nextButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.sm,
    backgroundColor: Colors.primary,
    marginHorizontal: Spacing.lg,
    marginTop: Spacing.lg,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.full,
  },
  nextButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
    gap: Spacing.md,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
    backgroundColor: '#FFFFFF',
  },
  footerIcon: {
    padding: Spacing.xs,
  },
});
