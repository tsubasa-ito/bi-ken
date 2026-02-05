import { useState, useEffect } from 'react';
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
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { userProgress, eras } from '../../src/data/artworks';
import { useArtworksByEra } from '../../src/hooks/useArtworks';
import { Artwork } from '../../src/types';

const { width } = Dimensions.get('window');
const ERA_CARD_WIDTH = (width - Spacing.lg * 2 - Spacing.md) / 2;

export default function HomeScreen() {
  const router = useRouter();
  const colors = Colors.dark;

  // APIから今日の作品を取得
  const { artworks: featuredArtworks, loading, error } = useArtworksByEra('all', 5);
  const [dailyArtwork, setDailyArtwork] = useState<Artwork | null>(null);

  useEffect(() => {
    if (featuredArtworks.length > 0) {
      // 日付をシードにして毎日同じ作品を表示
      const today = new Date();
      const dayIndex = (today.getFullYear() * 366 + today.getMonth() * 31 + today.getDate()) % featuredArtworks.length;
      setDailyArtwork(featuredArtworks[dayIndex]);
    }
  }, [featuredArtworks]);

  const handleStartQuiz = (eraId?: string) => {
    router.push(`/quiz/${eraId || 'daily'}`);
  };

  return (
    <LinearGradient colors={['#0D1117', '#161B22']} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView showsVerticalScrollIndicator={false}>
          {/* Header */}
          <View style={styles.header}>
            <View style={styles.headerLeft}>
              <View style={[styles.avatar, { backgroundColor: colors.surfaceSecondary }]}>
                <Ionicons name="person" size={20} color="#fff" />
              </View>
              <View>
                <Text style={styles.appTitle}>美術検定</Text>
                <Text style={[styles.levelText, { color: Colors.primary }]}>
                  レベル {userProgress.level}　{userProgress.levelTitle}
                </Text>
              </View>
            </View>
            <TouchableOpacity>
              <Ionicons name="search" size={24} color="#fff" />
            </TouchableOpacity>
          </View>

          {/* Daily Challenge */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>今日の一問</Text>
            <View style={[styles.dailyCard, { backgroundColor: colors.surface }]}>
              {loading ? (
                <View style={styles.dailyLoading}>
                  <ActivityIndicator size="large" color={Colors.primary} />
                  <Text style={styles.loadingText}>
                    作品を読み込み中...
                  </Text>
                </View>
              ) : error || !dailyArtwork ? (
                <View style={styles.dailyLoading}>
                  <Ionicons name="alert-circle-outline" size={32} color={Colors.error} />
                  <Text style={styles.loadingText}>
                    読み込みに失敗しました
                  </Text>
                </View>
              ) : (
                <>
                  <Image
                    source={{ uri: dailyArtwork.imageUrl }}
                    style={styles.dailyImage}
                    resizeMode="cover"
                  />
                  <View style={styles.dailyContent}>
                    <View style={styles.dailyHeader}>
                      <View style={styles.dailyTitleContainer}>
                        <Text style={styles.dailyTitle} numberOfLines={1}>
                          {dailyArtwork.title}
                        </Text>
                        <Text style={[styles.dailyArtist, { color: Colors.primary }]}>
                          {dailyArtwork.artist}{dailyArtwork.year ? `、${dailyArtwork.year}年` : ''}
                        </Text>
                      </View>
                      <View style={[styles.xpBadge, { backgroundColor: colors.surfaceSecondary }]}>
                        <Text style={styles.xpText}>50 XP</Text>
                      </View>
                    </View>
                    <Text style={styles.dailyDescription} numberOfLines={2}>
                      この作品の作者を当ててみましょう。美術検定の基礎問題です。
                    </Text>
                    <View style={styles.dailyFooter}>
                      <View style={styles.participants}>
                        <View style={styles.participantDots}>
                          {[0, 1, 2].map((i) => (
                            <View
                              key={i}
                              style={[
                                styles.participantDot,
                                { backgroundColor: Colors.primary, marginLeft: i > 0 ? -8 : 0 },
                              ]}
                            />
                          ))}
                        </View>
                        <Text style={styles.participantText}>
                          本日 1.2千人が挑戦中
                        </Text>
                      </View>
                      <TouchableOpacity
                        style={styles.startButton}
                        onPress={() => handleStartQuiz('daily')}
                      >
                        <Text style={styles.startButtonText}>挑戦する</Text>
                      </TouchableOpacity>
                    </View>
                  </View>
                </>
              )}
            </View>
          </View>

          {/* Study by Era */}
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>時代から学ぶ</Text>
              <TouchableOpacity>
                <Text style={[styles.viewAll, { color: Colors.primary }]}>すべて見る</Text>
              </TouchableOpacity>
            </View>
            <View style={styles.eraGrid}>
              {eras.map((era) => (
                <TouchableOpacity
                  key={era.id}
                  style={styles.eraCard}
                  onPress={() => handleStartQuiz(era.id)}
                >
                  <Image source={{ uri: era.imageUrl }} style={styles.eraImage} />
                  <LinearGradient
                    colors={['transparent', 'rgba(0,0,0,0.8)']}
                    style={styles.eraGradient}
                  >
                    <Text style={styles.eraName}>{era.name}</Text>
                    <Text style={styles.eraPeriod}>{era.period}</Text>
                  </LinearGradient>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Your Progress */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>学習の記録</Text>
            <View style={[styles.progressCard, { backgroundColor: colors.surface }]}>
              <View style={styles.progressHeader}>
                <Text style={styles.progressLabel}>
                  検定合格に向けて
                </Text>
                <Text style={[styles.progressPercent, { color: Colors.primary }]}>
                  {userProgress.masteryPercentage - 6}%
                </Text>
              </View>
              <View style={[styles.progressBar, { backgroundColor: colors.surfaceSecondary }]}>
                <View
                  style={[
                    styles.progressFill,
                    { width: `${userProgress.masteryPercentage - 6}%` },
                  ]}
                />
              </View>
              <View style={styles.statsRow}>
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>
                    {userProgress.currentStreak}
                  </Text>
                  <Text style={styles.statLabel}>
                    日連続
                  </Text>
                </View>
                <View style={[styles.statDivider, { backgroundColor: colors.border }]} />
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>
                    {userProgress.totalArtworksMet}
                  </Text>
                  <Text style={styles.statLabel}>
                    作品
                  </Text>
                </View>
                <View style={[styles.statDivider, { backgroundColor: colors.border }]} />
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>
                    {userProgress.totalCertificates}
                  </Text>
                  <Text style={styles.statLabel}>
                    認定証
                  </Text>
                </View>
              </View>
            </View>
          </View>

          <View style={{ height: Spacing.xl }} />
        </ScrollView>
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
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.md,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  appTitle: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.xl,
    color: '#fff',
  },
  levelText: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.xs,
  },
  section: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.lg,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  sectionTitle: {
    fontFamily: Fonts.serifSemiBold,
    fontSize: FontSize.xl,
    marginBottom: Spacing.md,
    color: '#fff',
  },
  viewAll: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.sm,
  },
  dailyCard: {
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
    minHeight: 280,
  },
  dailyLoading: {
    flex: 1,
    minHeight: 280,
    justifyContent: 'center',
    alignItems: 'center',
    gap: Spacing.md,
  },
  loadingText: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    color: Colors.dark.textSecondary,
  },
  dailyImage: {
    width: '100%',
    height: 180,
  },
  dailyTitleContainer: {
    flex: 1,
    marginRight: Spacing.sm,
  },
  dailyContent: {
    padding: Spacing.md,
  },
  dailyHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  dailyTitle: {
    fontFamily: Fonts.serifBold,
    fontSize: FontSize.lg,
    color: '#fff',
  },
  dailyArtist: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    marginTop: 2,
  },
  xpBadge: {
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.sm,
  },
  xpText: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.xs,
    color: '#fff',
  },
  dailyDescription: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    lineHeight: 20,
    marginTop: Spacing.sm,
    color: Colors.dark.textSecondary,
  },
  dailyFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: Spacing.md,
  },
  participants: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
  },
  participantDots: {
    flexDirection: 'row',
  },
  participantDot: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#fff',
  },
  participantText: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.xs,
    color: Colors.dark.textSecondary,
  },
  startButton: {
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.full,
  },
  startButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.sm,
  },
  eraGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.md,
  },
  eraCard: {
    width: ERA_CARD_WIDTH,
    height: 140,
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
  },
  eraImage: {
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  eraGradient: {
    flex: 1,
    justifyContent: 'flex-end',
    padding: Spacing.md,
  },
  eraName: {
    fontFamily: Fonts.serifBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
  eraPeriod: {
    fontFamily: Fonts.sansRegular,
    color: 'rgba(255,255,255,0.7)',
    fontSize: FontSize.xs,
    marginTop: 2,
  },
  progressCard: {
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  progressLabel: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    color: Colors.dark.textSecondary,
  },
  progressPercent: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.sm,
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    marginTop: Spacing.sm,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: 4,
  },
  statsRow: {
    flexDirection: 'row',
    marginTop: Spacing.lg,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statValue: {
    fontFamily: Fonts.sansBold,
    fontSize: FontSize.xxl,
    color: '#fff',
  },
  statLabel: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.xs,
    marginTop: 4,
    color: Colors.dark.textSecondary,
  },
  statDivider: {
    width: 1,
    height: '100%',
  },
});
