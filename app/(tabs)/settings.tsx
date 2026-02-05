import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors, Spacing, BorderRadius, FontSize } from '../../src/constants/colors';
import { Fonts } from '../../src/constants/fonts';
import { useState } from 'react';

interface SettingItemProps {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle?: string;
  value?: string;
  hasArrow?: boolean;
  onPress?: () => void;
}

function SettingItem({ icon, title, subtitle, value, hasArrow = true, onPress }: SettingItemProps) {
  const colors = Colors.dark;

  return (
    <TouchableOpacity
      style={[styles.settingItem, { backgroundColor: colors.surface }]}
      onPress={onPress}
    >
      <View style={[styles.iconContainer, { backgroundColor: colors.surfaceSecondary }]}>
        <Ionicons name={icon} size={20} color={Colors.primary} />
      </View>
      <View style={styles.settingContent}>
        <Text style={styles.settingTitle}>{title}</Text>
        {subtitle && (
          <Text style={[styles.settingSubtitle, { color: Colors.primary }]}>{subtitle}</Text>
        )}
      </View>
      {value && (
        <Text style={[styles.settingValue, { color: Colors.primary }]}>{value}</Text>
      )}
      {hasArrow && (
        <Ionicons name="chevron-forward" size={20} color={colors.textTertiary} />
      )}
    </TouchableOpacity>
  );
}

interface SettingSwitchProps {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}

function SettingSwitch({ icon, title, value, onValueChange }: SettingSwitchProps) {
  const colors = Colors.dark;

  return (
    <View style={[styles.settingItem, { backgroundColor: colors.surface }]}>
      <View style={[styles.iconContainer, { backgroundColor: colors.surfaceSecondary }]}>
        <Ionicons name={icon} size={20} color={colors.textSecondary} />
      </View>
      <View style={styles.settingContent}>
        <Text style={styles.settingTitle}>{title}</Text>
      </View>
      <Switch
        value={value}
        onValueChange={onValueChange}
        trackColor={{ false: colors.border, true: Colors.primary }}
        thumbColor="#fff"
      />
    </View>
  );
}

export default function SettingsScreen() {
  const router = useRouter();
  const colors = Colors.dark;

  const [dailyReminders, setDailyReminders] = useState(true);
  const [darkMode, setDarkMode] = useState(true);

  return (
    <LinearGradient colors={['#0D1117', '#161B22']} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()}>
            <Ionicons name="chevron-back" size={28} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>設定</Text>
          <View style={{ width: 28 }} />
        </View>

        <ScrollView showsVerticalScrollIndicator={false}>
          {/* Account Section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>
              アカウント
            </Text>
            <View style={[styles.sectionCard, { backgroundColor: colors.surface }]}>
              <SettingItem
                icon="person"
                title="山田 花子"
                subtitle="プロフィールを編集"
                hasArrow
              />
              <View style={[styles.divider, { backgroundColor: colors.border }]} />
              <SettingItem
                icon="star"
                title="プラン"
                subtitle="美術検定2級・プレミアム"
                hasArrow
              />
            </View>
          </View>

          {/* Learning Preferences Section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>
              学習設定
            </Text>
            <View style={[styles.sectionCard, { backgroundColor: colors.surface }]}>
              <SettingItem
                icon="speedometer"
                title="難易度レベル"
                value="中級"
                hasArrow
              />
              <View style={[styles.divider, { backgroundColor: colors.border }]} />
              <SettingItem
                icon="flag"
                title="1日の目標"
                value="20問"
                hasArrow
              />
            </View>
          </View>

          {/* App Appearance Section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>
              アプリの表示
            </Text>
            <View style={[styles.sectionCard, { backgroundColor: colors.surface }]}>
              <SettingSwitch
                icon="notifications"
                title="学習リマインダー"
                value={dailyReminders}
                onValueChange={setDailyReminders}
              />
              <View style={[styles.divider, { backgroundColor: colors.border }]} />
              <SettingSwitch
                icon="moon"
                title="ダークモード"
                value={darkMode}
                onValueChange={setDarkMode}
              />
            </View>
          </View>

          {/* Logout Button */}
          <TouchableOpacity style={styles.logoutButton}>
            <Text style={styles.logoutText}>ログアウト</Text>
          </TouchableOpacity>

          {/* Footer */}
          <View style={styles.footer}>
            <Text style={styles.footerText}>
              美術検定学習コンパニオン・v2.4.1
            </Text>
            <View style={styles.footerLinks}>
              <TouchableOpacity>
                <Text style={[styles.footerLink, { color: Colors.primary }]}>
                  プライバシーポリシー
                </Text>
              </TouchableOpacity>
              <TouchableOpacity>
                <Text style={[styles.footerLink, { color: Colors.primary }]}>
                  利用規約
                </Text>
              </TouchableOpacity>
            </View>
          </View>

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
    fontSize: FontSize.xl,
    color: '#fff',
  },
  section: {
    paddingHorizontal: Spacing.lg,
    marginTop: Spacing.xl,
  },
  sectionTitle: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.xs,
    letterSpacing: 1,
    marginBottom: Spacing.sm,
    color: Colors.dark.textSecondary,
  },
  sectionCard: {
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: Spacing.md,
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.sm,
    justifyContent: 'center',
    alignItems: 'center',
  },
  settingContent: {
    flex: 1,
    marginLeft: Spacing.md,
  },
  settingTitle: {
    fontFamily: Fonts.sansMedium,
    fontSize: FontSize.md,
    color: '#fff',
  },
  settingSubtitle: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    marginTop: 2,
  },
  settingValue: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    marginRight: Spacing.sm,
  },
  divider: {
    height: 1,
    marginLeft: 68,
  },
  logoutButton: {
    marginHorizontal: Spacing.lg,
    marginTop: Spacing.xl,
    backgroundColor: 'rgba(255, 107, 107, 0.1)',
    borderRadius: BorderRadius.lg,
    paddingVertical: Spacing.md,
    alignItems: 'center',
  },
  logoutText: {
    fontFamily: Fonts.sansMedium,
    color: Colors.error,
    fontSize: FontSize.md,
  },
  footer: {
    alignItems: 'center',
    marginTop: Spacing.xl,
    paddingHorizontal: Spacing.lg,
  },
  footerText: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
    color: Colors.dark.textSecondary,
  },
  footerLinks: {
    flexDirection: 'row',
    gap: Spacing.lg,
    marginTop: Spacing.sm,
  },
  footerLink: {
    fontFamily: Fonts.sansRegular,
    fontSize: FontSize.sm,
  },
});
