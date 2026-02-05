import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  useColorScheme,
  ActivityIndicator,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { useQuiz } from '../../src/hooks/useArtworks';

type EraType = 'renaissance' | 'baroque' | 'impressionism' | 'modern' | 'japanese' | 'all';

export default function QuizScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const colors = isDark ? Colors.dark : Colors.light;

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
        ? { borderColor: Colors.primary, backgroundColor: 'rgba(74, 123, 247, 0.1)' }
        : { borderColor: colors.border };
    }

    if (option === currentQuestion?.correctAnswer) {
      return { borderColor: Colors.success, backgroundColor: 'rgba(76, 175, 80, 0.1)' };
    }

    if (selectedAnswer === option && option !== currentQuestion?.correctAnswer) {
      return { borderColor: Colors.error, backgroundColor: 'rgba(255, 107, 107, 0.1)' };
    }

    return { borderColor: colors.border };
  };

  // ローディング表示
  if (loading) {
    return (
      <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
        <View style={styles.header}>
          <TouchableOpacity onPress={handleClose}>
            <Ionicons name="close" size={28} color={colors.text} />
          </TouchableOpacity>
          <Text style={[styles.headerTitle, { color: colors.text }]}>美術検定</Text>
          <View style={{ width: 28 }} />
        </View>
        <View style={styles.loading}>
          <ActivityIndicator size="large" color={Colors.primary} />
          <Text style={[styles.loadingText, { color: colors.textSecondary }]}>
            作品を読み込み中...
          </Text>
          <Text style={[styles.loadingSubtext, { color: colors.textTertiary }]}>
            メトロポリタン美術館から取得しています
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  // エラー表示
  if (error || !currentQuestion) {
    return (
      <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
        <View style={styles.header}>
          <TouchableOpacity onPress={handleClose}>
            <Ionicons name="close" size={28} color={colors.text} />
          </TouchableOpacity>
          <Text style={[styles.headerTitle, { color: colors.text }]}>美術検定</Text>
          <View style={{ width: 28 }} />
        </View>
        <View style={styles.loading}>
          <Ionicons name="alert-circle-outline" size={48} color={Colors.error} />
          <Text style={[styles.loadingText, { color: colors.text }]}>
            読み込みに失敗しました
          </Text>
          <TouchableOpacity style={styles.retryButton} onPress={refetch}>
            <Text style={styles.retryButtonText}>再試行</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleClose}>
          <Ionicons name="close" size={28} color={colors.text} />
        </TouchableOpacity>
        <Text style={[styles.headerTitle, { color: colors.text }]}>美術検定</Text>
        <TouchableOpacity>
          <Ionicons name="information-circle-outline" size={28} color={colors.text} />
        </TouchableOpacity>
      </View>

      {/* Scrollable Content */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Progress */}
        <View style={styles.progressSection}>
          <View style={styles.progressHeader}>
            <Text style={[styles.progressLabel, { color: colors.text }]}>進捗</Text>
            <Text style={[styles.progressCount, { color: Colors.primary }]}>
              {currentIndex + 1} / {totalQuestions}
            </Text>
          </View>
          <View style={[styles.progressBar, { backgroundColor: colors.surfaceSecondary }]}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>
        </View>

        {/* Artwork Image */}
        <View style={styles.imageWrapper}>
          <View style={[styles.imageContainer, { backgroundColor: colors.surfaceSecondary }]}>
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
              <Text style={[styles.artworkTitle, { color: colors.text }]}>
                『{currentQuestion.artwork.title}』
              </Text>
              <Text style={[styles.correctAnswerLabel, { color: Colors.primary }]}>
                作者: {currentQuestion.correctAnswer}
              </Text>
            </>
          ) : (
            <>
              <Text style={[styles.questionText, { color: colors.text }]}>
                {currentQuestion.question}
              </Text>
              <Text style={[styles.questionHint, { color: colors.textSecondary }]}>
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
              style={[
                styles.optionButton,
                { backgroundColor: colors.surface },
                getOptionStyle(option),
              ]}
              onPress={() => handleSelectAnswer(option)}
              disabled={showResult}
            >
              <Text style={[styles.optionText, { color: colors.text }]}>{option}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Spacer for bottom content */}
        <View style={{ height: Spacing.xl }} />
      </ScrollView>

      {/* Fixed Bottom Area */}
      <View style={[styles.bottomArea, { backgroundColor: colors.background }]}>
        {/* Next Button (shows after answering) */}
        {showResult && (
          <TouchableOpacity style={styles.nextButton} onPress={handleNext}>
            <Text style={styles.nextButtonText}>
              {currentIndex < totalQuestions - 1 ? '次の問題へ' : '結果を見る'}
            </Text>
            <Ionicons name="arrow-forward" size={20} color="#fff" />
          </TouchableOpacity>
        )}

        {/* Footer */}
        <View style={[styles.footer, { borderTopColor: colors.border }]}>
          <TouchableOpacity style={styles.footerButton}>
            <Ionicons name="bulb-outline" size={20} color={Colors.primary} />
            <Text style={[styles.footerButtonText, { color: Colors.primary }]}>ヒント</Text>
          </TouchableOpacity>
          <View style={styles.footerRight}>
            <TouchableOpacity style={styles.footerIcon}>
              <Ionicons name="bookmark-outline" size={24} color={colors.textSecondary} />
            </TouchableOpacity>
            <TouchableOpacity style={styles.footerIcon}>
              <Ionicons name="share-outline" size={24} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  bottomArea: {
    paddingBottom: Spacing.sm,
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
    marginTop: Spacing.md,
  },
  loadingSubtext: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
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
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
  },
  headerTitle: {
    fontFamily: Fonts.serifSemiBold,
    fontSize: FontSize.md,
  },
  progressSection: {
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.md,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  progressLabel: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.xs,
    letterSpacing: 1,
  },
  progressCount: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.sm,
  },
  progressBar: {
    height: 6,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: 3,
  },
  imageWrapper: {
    paddingHorizontal: Spacing.lg,
    alignItems: 'center',
  },
  imageContainer: {
    width: '100%',
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
    height: 220,
    justifyContent: 'center',
    alignItems: 'center',
  },
  artworkImage: {
    width: '100%',
    height: '100%',
  },
  questionSection: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.md,
  },
  questionText: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.xl,
    textAlign: 'center',
  },
  questionHint: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    textAlign: 'center',
    marginTop: Spacing.sm,
  },
  artworkTitle: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.xl,
    textAlign: 'center',
  },
  correctAnswerLabel: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.md,
    textAlign: 'center',
    marginTop: Spacing.sm,
  },
  optionsContainer: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.md,
    gap: Spacing.xs,
  },
  optionButton: {
    borderWidth: 2,
    borderRadius: BorderRadius.lg,
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
  },
  optionText: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.sm,
    textAlign: 'center',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    borderTopWidth: 1,
  },
  footerButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
  },
  footerButtonText: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.sm,
  },
  footerRight: {
    flexDirection: 'row',
    gap: Spacing.md,
  },
  footerIcon: {
    padding: Spacing.xs,
  },
  nextButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.sm,
    backgroundColor: Colors.primary,
    marginHorizontal: Spacing.lg,
    marginTop: Spacing.sm,
    marginBottom: Spacing.sm,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.full,
  },
  nextButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
});
