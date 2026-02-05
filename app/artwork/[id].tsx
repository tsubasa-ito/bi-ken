import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Image,
  TouchableOpacity,
  Dimensions,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { useArtwork } from '../../src/hooks/useArtworks';

const { height } = Dimensions.get('window');

export default function ArtworkDetailScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const { artwork, loading, error } = useArtwork(id || '');

  // ローディング表示
  if (loading) {
    return (
      <LinearGradient colors={['#1a1a2e', '#16213e']} style={styles.container}>
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.header}>
            <TouchableOpacity onPress={() => router.back()} style={styles.headerButton}>
              <Ionicons name="close" size={24} color="#FF6B6B" />
            </TouchableOpacity>
            <View style={{ width: 24 }} />
            <View style={{ width: 24 }} />
          </View>
          <View style={styles.loading}>
            <ActivityIndicator size="large" color={Colors.primary} />
            <Text style={styles.loadingText}>作品を読み込み中...</Text>
          </View>
        </SafeAreaView>
      </LinearGradient>
    );
  }

  // エラーまたは作品が見つからない
  if (error || !artwork) {
    return (
      <LinearGradient colors={['#1a1a2e', '#16213e']} style={styles.container}>
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.notFound}>
            <Ionicons name="alert-circle-outline" size={48} color={Colors.error} />
            <Text style={styles.notFoundText}>
              {error ? '読み込みに失敗しました' : '作品が見つかりません'}
            </Text>
            <TouchableOpacity onPress={() => router.back()}>
              <Text style={styles.backLink}>戻る</Text>
            </TouchableOpacity>
          </View>
        </SafeAreaView>
      </LinearGradient>
    );
  }

  const difficultyMap: Record<string, string> = {
    Easy: '易',
    Medium: '普通',
    Hard: '難',
  };

  return (
    <LinearGradient colors={['#1a1a2e', '#16213e']} style={styles.container}>
      <SafeAreaView style={styles.safeArea} edges={['top']}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.headerButton}>
            <Ionicons name="close" size={24} color="#FF6B6B" />
            <Text style={styles.reviewModeText}>復習モード</Text>
          </TouchableOpacity>
          <View style={styles.correctBadge}>
            <Ionicons name="checkmark-circle" size={16} color={Colors.accent} />
            <Text style={styles.correctText}>正解</Text>
          </View>
          <TouchableOpacity>
            <Ionicons name="bookmark-outline" size={24} color="#fff" />
          </TouchableOpacity>
        </View>

        {/* Progress indicator */}
        <View style={styles.examProgress}>
          <Text style={styles.examProgressLabel}>検定進捗</Text>
          <Text style={styles.examProgressValue}>14 / 20</Text>
        </View>

        <ScrollView showsVerticalScrollIndicator={false}>
          {/* Artwork Image */}
          <View style={styles.imageContainer}>
            <Image
              source={{ uri: artwork.imageUrl }}
              style={styles.artworkImage}
              resizeMode="cover"
            />
            <TouchableOpacity style={styles.zoomButton}>
              <Ionicons name="search" size={20} color="#fff" />
            </TouchableOpacity>
          </View>

          {/* Artwork Info */}
          <View style={styles.infoSection}>
            <Text style={styles.title}>{artwork.title}</Text>
            <Text style={styles.artist}>{artwork.artist}</Text>

            {/* Metadata */}
            <View style={styles.metadataRow}>
              <View style={styles.metadataItem}>
                <Text style={styles.metadataLabel}>制作年</Text>
                <Text style={styles.metadataValue}>{artwork.year}年</Text>
              </View>
              <View style={styles.metadataItem}>
                <Text style={styles.metadataLabel}>技法</Text>
                <Text style={styles.metadataValue}>{artwork.medium}</Text>
              </View>
              <View style={styles.metadataItem}>
                <Text style={styles.metadataLabel}>様式</Text>
                <Text style={styles.metadataValue}>{artwork.movement}</Text>
              </View>
            </View>

            {/* Divider */}
            <View style={styles.divider} />

            {/* Artwork Insight */}
            <View style={styles.insightSection}>
              <View style={styles.insightHeader}>
                <View style={styles.insightIndicator} />
                <Text style={styles.insightTitle}>作品解説</Text>
              </View>
              <Text style={styles.insightText}>{artwork.description}</Text>
            </View>

            {/* Artist Quote */}
            {artwork.artistQuote && (
              <View style={styles.quoteCard}>
                <View style={styles.quoteHeader}>
                  <View style={styles.artistAvatar}>
                    <Ionicons name="person" size={16} color="#fff" />
                  </View>
                  <View>
                    <Text style={styles.quoteName}>{artwork.artist}</Text>
                    <Text style={styles.quoteInfo}>{artwork.artistBio}</Text>
                  </View>
                </View>
                <Text style={styles.quoteText}>{artwork.artistQuote}</Text>
              </View>
            )}

            {/* Exam Key Point */}
            {artwork.examKeyPoint && (
              <View style={styles.keyPointSection}>
                <Text style={styles.keyPointTitle}>検定のポイント</Text>
                <Text style={styles.keyPointText}>{artwork.examKeyPoint}</Text>
              </View>
            )}

            {/* Stats */}
            <View style={styles.statsRow}>
              <Text style={styles.statsText}>
                👥 受験者の{artwork.correctRate}%が正解
              </Text>
              <Text style={styles.difficultyText}>
                難易度：{difficultyMap[artwork.difficulty]}
              </Text>
            </View>
          </View>

          <View style={{ height: 100 }} />
        </ScrollView>

        {/* Next Question Button */}
        <View style={styles.bottomBar}>
          <TouchableOpacity
            style={styles.nextButton}
            onPress={() => router.back()}
          >
            <Text style={styles.nextButtonText}>次の問題へ</Text>
            <Ionicons name="chevron-forward" size={20} color="#fff" />
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  notFound: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  notFoundText: {
    fontFamily: Fonts.sansRegular,
    color: '#fff',
    fontSize: FontSize.lg,
    marginTop: Spacing.md,
    textAlign: 'center',
  },
  loading: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: Spacing.md,
  },
  loadingText: {
    fontFamily: Fonts.sansMedium,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.md,
  },
  backLink: {
    fontFamily: Fonts.sansMedium,
    color: Colors.primary,
    fontSize: FontSize.md,
    marginTop: Spacing.md,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.sm,
  },
  headerButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
  },
  reviewModeText: {
    fontFamily: Fonts.sansRegular,
    color: '#fff',
    fontSize: FontSize.sm,
  },
  correctBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    backgroundColor: 'rgba(0, 212, 170, 0.2)',
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.full,
  },
  correctText: {
    fontFamily: Fonts.sansMedium,
    color: Colors.accent,
    fontSize: FontSize.xs,
  },
  examProgress: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.sm,
  },
  examProgressLabel: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.xs,
  },
  examProgressValue: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.sm,
  },
  imageContainer: {
    position: 'relative',
    marginHorizontal: Spacing.lg,
    height: height * 0.35,
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
  },
  artworkImage: {
    width: '100%',
    height: '100%',
  },
  zoomButton: {
    position: 'absolute',
    bottom: Spacing.md,
    right: Spacing.md,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    borderRadius: BorderRadius.full,
    padding: Spacing.sm,
  },
  infoSection: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.lg,
  },
  title: {
    fontFamily: Fonts.serifBold,
    color: '#fff',
    fontSize: FontSize.xxxl,
  },
  artist: {
    fontFamily: Fonts.serifRegular,
    color: Colors.primary,
    fontSize: FontSize.lg,
    marginTop: Spacing.xs,
    textDecorationLine: 'underline',
  },
  metadataRow: {
    flexDirection: 'row',
    marginTop: Spacing.lg,
    gap: Spacing.lg,
  },
  metadataItem: {
    flex: 1,
  },
  metadataLabel: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textTertiary,
    fontSize: FontSize.xs,
  },
  metadataValue: {
    fontFamily: Fonts.sansMedium,
    color: '#fff',
    fontSize: FontSize.sm,
    marginTop: 4,
  },
  divider: {
    height: 1,
    backgroundColor: Colors.dark.border,
    marginVertical: Spacing.lg,
  },
  insightSection: {
    marginBottom: Spacing.lg,
  },
  insightHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
    marginBottom: Spacing.sm,
  },
  insightIndicator: {
    width: 4,
    height: 20,
    backgroundColor: Colors.primary,
    borderRadius: 2,
  },
  insightTitle: {
    fontFamily: Fonts.serifSemiBold,
    color: '#fff',
    fontSize: FontSize.lg,
  },
  insightText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.md,
    lineHeight: 26,
  },
  quoteCard: {
    backgroundColor: Colors.dark.surfaceSecondary,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    marginBottom: Spacing.lg,
  },
  quoteHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
  },
  artistAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.dark.border,
    justifyContent: 'center',
    alignItems: 'center',
  },
  quoteName: {
    fontFamily: Fonts.sansMedium,
    color: '#fff',
    fontSize: FontSize.md,
  },
  quoteInfo: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.xs,
  },
  quoteText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
    marginTop: Spacing.md,
    lineHeight: 22,
  },
  keyPointSection: {
    marginBottom: Spacing.lg,
  },
  keyPointTitle: {
    fontFamily: Fonts.sansBold,
    color: Colors.primary,
    fontSize: FontSize.xs,
    letterSpacing: 1,
    marginBottom: Spacing.sm,
  },
  keyPointText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
    lineHeight: 22,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  statsText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
  },
  difficultyText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
  },
  bottomBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: Spacing.lg,
    paddingBottom: Spacing.xl,
  },
  nextButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.sm,
    backgroundColor: Colors.primary,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.full,
  },
  nextButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
});
