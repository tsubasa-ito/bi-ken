import { useEffect } from 'react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme, View, ActivityIndicator } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import {
  useFonts,
  NotoSansJP_300Light,
  NotoSansJP_400Regular,
  NotoSansJP_500Medium,
  NotoSansJP_700Bold,
  NotoSansJP_900Black,
} from '@expo-google-fonts/noto-sans-jp';
import {
  NotoSerifJP_300Light,
  NotoSerifJP_400Regular,
  NotoSerifJP_500Medium,
  NotoSerifJP_600SemiBold,
  NotoSerifJP_700Bold,
  NotoSerifJP_900Black,
} from '@expo-google-fonts/noto-serif-jp';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const [fontsLoaded] = useFonts({
    NotoSansJP_300Light,
    NotoSansJP_400Regular,
    NotoSansJP_500Medium,
    NotoSansJP_700Bold,
    NotoSansJP_900Black,
    NotoSerifJP_300Light,
    NotoSerifJP_400Regular,
    NotoSerifJP_500Medium,
    NotoSerifJP_600SemiBold,
    NotoSerifJP_700Bold,
    NotoSerifJP_900Black,
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: isDark ? '#0D1117' : '#F5F7FA' }}>
        <ActivityIndicator size="large" color="#4A7BF7" />
      </View>
    );
  }

  return (
    <>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: {
            backgroundColor: isDark ? '#0D1117' : '#F5F7FA',
          },
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen
          name="quiz/[id]"
          options={{
            presentation: 'card',
            animation: 'slide_from_right',
          }}
        />
        <Stack.Screen
          name="artwork/[id]"
          options={{
            presentation: 'modal',
            animation: 'slide_from_right',
          }}
        />
      </Stack>
    </>
  );
}
