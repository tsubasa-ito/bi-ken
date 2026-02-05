import { useState, useMemo } from 'react';
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
import { useArtworksByEra } from '../../src/hooks/useArtworks';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - Spacing.lg * 2 - Spacing.md) / 2;

type FilterType = 'all' | 'renaissance' | 'impressionism' | 'baroque' | 'modern' | 'japanese';

const filters: { label: string; value: FilterType }[] = [
  { label: 'すべて', value: 'all' },
  { label: 'ルネサンス', value: 'renaissance' },
  { label: '印象派', value: 'impressionism' },
  { label: 'バロック', value: 'baroque' },
  { label: '近代', value: 'modern' },
  { label: '日本美術', value: 'japanese' },
];

export default function CollectionScreen() {
  const router = useRouter();
  const [selectedFilter, setSelectedFilter] = useState<FilterType>('all');

  // APIから作品を取得
  const { artworks, loading, error, refetch } = useArtworksByEra(selectedFilter, 20);

  // コレクション数（デモ用）
  const collectionCount = useMemo(() => artworks.length, [artworks]);

  const handleArtworkPress = (id: string) => {
    router.push(`/artwork/${id}`);
  };

  return (
    <LinearGradient colors={['#0D1117', '#161B22']} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.avatarButton}>
            <Ionicons name="person-circle-outline" size={32} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>コレクション</Text>
          <TouchableOpacity>
            <Ionicons name="search" size={24} color="#fff" />
          </TouchableOpacity>
        </View>

        <ScrollView showsVerticalScrollIndicator={false}>
          {/* Title Section */}
          <View style={styles.titleSection}>
            <Text style={styles.mainTitle}>コレクション</Text>
            <View style={styles.progressInfo}>
              <Text style={styles.progressCount}>
                メトロポリタン美術館の名作を探索
              </Text>
            </View>
          </View>

          {/* Filter Pills */}
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.filterContainer}
          >
            {filters.map((filter) => (
              <TouchableOpacity
                key={filter.value}
                style={[
                  styles.filterPill,
                  selectedFilter === filter.value && styles.filterPillActive,
                ]}
                onPress={() => setSelectedFilter(filter.value)}
              >
                <Text
                  style={[
                    styles.filterText,
                    selectedFilter === filter.value && styles.filterTextActive,
                  ]}
                >
                  {filter.label}
                </Text>
                {selectedFilter === filter.value && (
                  <Ionicons name="chevron-down" size={16} color="#fff" />
                )}
              </TouchableOpacity>
            ))}
          </ScrollView>

          {/* Loading State */}
          {loading && (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color="#A78BFA" />
              <Text style={styles.loadingText}>作品を読み込み中...</Text>
            </View>
          )}

          {/* Error State */}
          {error && !loading && (
            <View style={styles.loadingContainer}>
              <Ionicons name="alert-circle-outline" size={48} color={Colors.error} />
              <Text style={styles.loadingText}>読み込みに失敗しました</Text>
              <TouchableOpacity style={styles.retryButton} onPress={refetch}>
                <Text style={styles.retryButtonText}>再試行</Text>
              </TouchableOpacity>
            </View>
          )}

          {/* Artwork Grid */}
          {!loading && !error && (
            <View style={styles.grid}>
              {artworks.length === 0 ? (
                <View style={styles.emptyContainer}>
                  <Ionicons name="images-outline" size={48} color={Colors.dark.textTertiary} />
                  <Text style={styles.emptyText}>作品が見つかりません</Text>
                </View>
              ) : (
                artworks.map((artwork, index) => (
                  <TouchableOpacity
                    key={`${artwork.id}-${index}`}
                    style={styles.artworkCard}
                    onPress={() => handleArtworkPress(artwork.id)}
                  >
                    <Image
                      source={{ uri: artwork.imageUrl }}
                      style={styles.artworkImage}
                      resizeMode="cover"
                    />
                    <View style={styles.artworkInfo}>
                      <Text style={styles.artworkTitle} numberOfLines={2}>
                        {artwork.title}
                      </Text>
                      <Text style={styles.artworkArtist} numberOfLines={1}>
                        {artwork.artist}
                      </Text>
                      {artwork.year > 0 && (
                        <Text style={styles.artworkYear}>{artwork.year}年</Text>
                      )}
                    </View>
                  </TouchableOpacity>
                ))
              )}
            </View>
          )}

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
  avatarButton: {
    opacity: 0.8,
  },
  headerTitle: {
    fontFamily: Fonts.serifSemiBold,
    color: '#fff',
    fontSize: FontSize.lg,
  },
  titleSection: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.md,
  },
  mainTitle: {
    fontFamily: Fonts.serifBold,
    color: '#fff',
    fontSize: FontSize.xxxl,
  },
  progressInfo: {
    marginTop: Spacing.sm,
  },
  progressCount: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
  },
  loadingContainer: {
    paddingVertical: Spacing.xxl * 2,
    alignItems: 'center',
    gap: Spacing.md,
  },
  loadingText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.md,
  },
  retryButton: {
    marginTop: Spacing.md,
    backgroundColor: '#A78BFA',
    paddingHorizontal: Spacing.xl,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.full,
  },
  retryButtonText: {
    fontFamily: Fonts.sansBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
  emptyContainer: {
    width: '100%',
    paddingVertical: Spacing.xxl * 2,
    alignItems: 'center',
    gap: Spacing.md,
  },
  emptyText: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.md,
  },
  filterContainer: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.lg,
    gap: Spacing.sm,
  },
  filterPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.dark.surfaceSecondary,
    marginRight: Spacing.sm,
  },
  filterPillActive: {
    backgroundColor: '#A78BFA',
  },
  filterText: {
    fontFamily: Fonts.sansMedium,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.sm,
  },
  filterTextActive: {
    color: '#fff',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: Spacing.lg,
    gap: Spacing.md,
  },
  artworkCard: {
    width: CARD_WIDTH,
    marginBottom: Spacing.md,
  },
  artworkImage: {
    width: '100%',
    height: CARD_WIDTH * 1.2,
    borderRadius: BorderRadius.md,
    backgroundColor: Colors.dark.surfaceSecondary,
  },
  artworkInfo: {
    marginTop: Spacing.sm,
  },
  artworkTitle: {
    fontFamily: Fonts.serifSemiBold,
    color: '#fff',
    fontSize: FontSize.md,
  },
  artworkArtist: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textSecondary,
    fontSize: FontSize.xs,
    marginTop: 4,
  },
  artworkYear: {
    fontFamily: Fonts.sansRegular,
    color: Colors.dark.textTertiary,
    fontSize: FontSize.xs,
    marginTop: 2,
  },
});
