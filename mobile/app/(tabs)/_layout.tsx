import { Stack } from 'expo-router';
import { COLORS } from '@/lib/theme';

export default function TabLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: COLORS.bgLight },
      }}
    >
      <Stack.Screen name="index" />
    </Stack>
  );
}
