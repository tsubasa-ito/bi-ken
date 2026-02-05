import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Circle } from 'react-native-svg';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { userProgress } from '../../src/data/artworks';

const CIRCLE_SIZE = 200;
const STROKE_WIDTH = 12;

export default function ProgressScreen() {
  const router = useRouter();

  const radius = (CIRCLE_SIZE - STROKE_WIDTH) / 2;
  const circumference = radius * 2 * Math.PI;
  const strokeDashoffset = circumference - (userProgress.masteryPercentage / 100) * circumference;

  const eraProgressData = [
    { name: 'ルネサンス', progress: userProgress.eraProgress.Renaissance },
    { name: '19世紀写実主義', progress: 45 },
    { name: '近現代美術', progress: 30 },
  ];

  return (
    <LinearGradient colors={['#0D1117', '#161B22']} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()}>
            <Ionicons name="chevron-back" size={28} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>学習記録</Text>
          <View style={{ width: 28 }} />
        </View>

        <ScrollView showsVerticalScrollIndicator={false}>
          {/* Level Info */}
          <View style={styles.levelSection}>
            <Text style={styles.levelTitle}>
              美術検定 {userProgress.level}級
            </Text>
            <Text style={styles.levelSubtitle}>
              アート・エキスパート認定コース
            </Text>
          </View>

          {/* Mastery Circle */}
          <View style={styles.circleContainer}>
            <Svg width={CIRCLE_SIZE} height={CIRCLE_SIZE}>
              {/* Background circle */}
              <Circle
                cx={CIRCLE_SIZE / 2}
                cy={CIRCLE_SIZE / 2}
                r={radius}
                stroke={Colors.dark.surfaceSecondary}
                strokeWidth={STROKE_WIDTH}
                fill="none"
              />
              {/* Progress circle */}
              <Circle
                cx={CIRCLE_SIZE / 2}
                cy={CIRCLE_SIZE / 2}
                r={radius}
                stroke={Colors.primary}
                strokeWidth={STROKE_WIDTH}
                fill="none"
                strokeDasharray={circumference}
                strokeDashoffset={strokeDashoffset}
                strokeLinecap="round"
                rotation="-90"
                origin={`${CIRCLE_SIZE / 2}, ${CIRCLE_SIZE / 2}`}
              />
            </Svg>
            <View style={styles.circleContent}>
              <Text style={styles.masteryPercent}>{userProgress.masteryPercentage}%</Text>
              <Text style={styles.masteryLabel}>習熟度</Text>
            </View>
          </View>

          {/* Overall Progress Card */}
          <View style={styles.overallCard}>
            <View style={styles.overallHeader}>
              <Text style={styles.overallTitle}>総合進捗</Text>
              <Text style={styles.readyText}>あと2週間で合格圏</Text>
            </View>
            <View style={styles.overallProgressBar}>
              <View
                style={[
                  styles.overallProgressFill,
                  { width: `${userProgress.masteryPercentage}%` },
                ]}
              />
            </View>
            <Text style={styles.overallQuote}>
              「ルネサンス美術の理解が着実に深まっています」
            </Text>
          </View>

          {/* Stats Row */}
          <View style={styles.statsRow}>
            <View style={styles.statCard}>
              <Text style={styles.statEmoji}>🔥</Text>
              <Text style={styles.statLabel}>連続</Text>
              <View style={styles.statValueRow}>
                <Text style={styles.statValue}>{userProgress.currentStreak}</Text>
                <Text style={styles.statChange}>+2</Text>
              </View>
            </View>
            <View style={styles.statCard}>
              <Text style={styles.statEmoji}>🎨</Text>
              <Text style={styles.statLabel}>作家</Text>
              <View style={styles.statValueRow}>
                <Text style={styles.statValue}>156</Text>
                <Text style={styles.statChange}>+15</Text>
              </View>
            </View>
            <View style={styles.statCard}>
              <Text style={styles.statEmoji}>⏱</Text>
              <Text style={styles.statLabel}>時間</Text>
              <View style={styles.statValueRow}>
                <Text style={styles.statValue}>{userProgress.totalHours}</Text>
                <Text style={styles.statChange}>+4</Text>
              </View>
            </View>
          </View>

          {/* Proficiency by Era */}
          <View style={styles.proficiencySection}>
            <Text style={styles.proficiencyTitle}>時代別の習熟度</Text>
            {eraProgressData.map((era) => (
              <View key={era.name} style={styles.eraItem}>
                <View style={styles.eraHeader}>
                  <Text style={styles.eraName}>{era.name}</Text>
                  <Text style={styles.eraPercent}>{era.progress}%</Text>
                </View>
                <View style={styles.eraProgressBar}>
                  <View
                    style={[
                      styles.eraProgressFill,
                      { width: `${era.progress}%` },
                    ]}
                  />
                </View>
              </View>
            ))}
            <Text style={styles.suggestion}>
              おすすめ：次は印象派を重点的に学習しましょう
            </Text>
          </View>

          {/* Continue Learning Button */}
          <TouchableOpacity style={styles.continueButton}>
            <Text style={styles.continueButtonText}>学習を続ける</Text>
          </TouchableOpacity>

          <View style={{ height: Spacing.xxl }} />
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
  headerTitle: {
    fontFamily: Fonts.serifSemiBold,
    color: '#fff',
    fontSize: FontSize.lg,
  },
  levelSection: {
    alignItems: 'center',
    marginTop: Spacing.lg,
  },
  levelTitle: {
    fontFamily: Fonts.serifBold,
    color: '#fff',
    fontSize: FontSize.xxxl,
  },
  levelSubtitle: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
    marginTop: Spacing.xs,
  },
  circleContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: Spacing.xl,
    marginBottom: Spacing.lg,
  },
  circleContent: {
    position: 'absolute',
    alignItems: 'center',
  },
  masteryPercent: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: 48,
  },
  masteryLabel: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.xs,
    letterSpacing: 2,
  },
  overallCard: {
    marginHorizontal: Spacing.lg,
    backgroundColor: Colors.dark.surfaceSecondary,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
  },
  overallHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  overallTitle: {
    fontFamily: Fonts.sansMedium,
    color: '#fff',
    fontSize: FontSize.md,
  },
  readyText: {
    fontFamily: Fonts.sansMedium,
    color: Colors.accent,
    fontSize: FontSize.sm,
  },
  overallProgressBar: {
    height: 8,
    backgroundColor: Colors.dark.border,
    borderRadius: 4,
    marginTop: Spacing.md,
    overflow: 'hidden',
  },
  overallProgressFill: {
    height: '100%',
    backgroundColor: Colors.accent,
    borderRadius: 4,
  },
  overallQuote: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
    marginTop: Spacing.md,
  },
  statsRow: {
    flexDirection: 'row',
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.lg,
    gap: Spacing.md,
  },
  statCard: {
    flex: 1,
    backgroundColor: Colors.dark.surfaceSecondary,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    alignItems: 'center',
  },
  statEmoji: {
    fontSize: 24,
  },
  statLabel: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.xs,
    marginTop: Spacing.xs,
  },
  statValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: Spacing.xs,
    marginTop: Spacing.xs,
  },
  statValue: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.xxl,
  },
  statChange: {
    fontFamily: Fonts.sansMedium,
    color: Colors.accent,
    fontSize: FontSize.sm,
  },
  proficiencySection: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.xl,
  },
  proficiencyTitle: {
    fontFamily: Fonts.serifSemiBold,
    color: '#fff',
    fontSize: FontSize.lg,
    marginBottom: Spacing.md,
  },
  eraItem: {
    marginBottom: Spacing.md,
  },
  eraHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.xs,
  },
  eraName: {
    fontFamily: Fonts.sansRegular,
    color: '#fff',
    fontSize: FontSize.sm,
  },
  eraPercent: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.sm,
  },
  eraProgressBar: {
    height: 8,
    backgroundColor: Colors.dark.surfaceSecondary,
    borderRadius: 4,
    overflow: 'hidden',
  },
  eraProgressFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: 4,
  },
  suggestion: {
    fontFamily: Fonts.sansRegular,
    color: Colors.primary,
    fontSize: FontSize.sm,
    marginTop: Spacing.md,
  },
  continueButton: {
    marginHorizontal: Spacing.lg,
    marginTop: Spacing.xl,
    backgroundColor: Colors.primary,
    borderRadius: BorderRadius.full,
    paddingVertical: Spacing.md,
    alignItems: 'center',
  },
  continueButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
});
