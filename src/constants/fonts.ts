export const Fonts = {
  // Noto Sans JP - 本文用サンセリフ体
  sansLight: 'NotoSansJP_300Light',
  sansRegular: 'NotoSansJP_400Regular',
  sansMedium: 'NotoSansJP_500Medium',
  sansBold: 'NotoSansJP_700Bold',
  sansBlack: 'NotoSansJP_900Black',

  // Noto Serif JP - 見出し用セリフ体（美術検定らしい上品な印象）
  serifLight: 'NotoSerifJP_300Light',
  serifRegular: 'NotoSerifJP_400Regular',
  serifMedium: 'NotoSerifJP_500Medium',
  serifSemiBold: 'NotoSerifJP_600SemiBold',
  serifBold: 'NotoSerifJP_700Bold',
  serifBlack: 'NotoSerifJP_900Black',
};

// テキストスタイルのプリセット
export const TextStyles = {
  // 大見出し（作品タイトルなど）
  displayLarge: {
    fontFamily: Fonts.serifBold,
    fontSize: 32,
    lineHeight: 44,
  },
  // 中見出し（セクションタイトルなど）
  displayMedium: {
    fontFamily: Fonts.serifSemiBold,
    fontSize: 24,
    lineHeight: 34,
  },
  // 小見出し
  displaySmall: {
    fontFamily: Fonts.serifMedium,
    fontSize: 20,
    lineHeight: 28,
  },
  // 本文
  bodyLarge: {
    fontFamily: Fonts.sansRegular,
    fontSize: 16,
    lineHeight: 26,
  },
  bodyMedium: {
    fontFamily: Fonts.sansRegular,
    fontSize: 14,
    lineHeight: 22,
  },
  bodySmall: {
    fontFamily: Fonts.sansRegular,
    fontSize: 12,
    lineHeight: 18,
  },
  // ラベル
  labelLarge: {
    fontFamily: Fonts.sansMedium,
    fontSize: 14,
    lineHeight: 20,
  },
  labelMedium: {
    fontFamily: Fonts.sansMedium,
    fontSize: 12,
    lineHeight: 16,
  },
  labelSmall: {
    fontFamily: Fonts.sansMedium,
    fontSize: 10,
    lineHeight: 14,
    letterSpacing: 0.5,
  },
};
