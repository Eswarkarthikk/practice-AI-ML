import { useEffect } from 'react';
import { useRouter, Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { AppProvider, useApp } from '@/lib/context/AppContext';
import { TransactionProvider, useTransactions } from '@/lib/context/TransactionContext';
import { BudgetProvider } from '@/lib/features/budgets/BudgetContext';
import { GoalProvider } from '@/lib/features/goals/GoalContext';
import { COLORS } from '@/lib/theme';

SplashScreen.preventAutoHideAsync();

const RootLayoutContent = () => {
  const router = useRouter();
  const { profile, loading } = useApp();

  useEffect(() => {
    if (!loading) {
      SplashScreen.hideAsync();

      if (!profile) {
        router.replace('/onboarding');
      }
    }
  }, [loading, profile]);

  if (loading) return null;

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: COLORS.bgLight },
      }}
    >
      <Stack.Screen name="onboarding" />
      <Stack.Screen name="profile-setup" />
      <Stack.Screen name="add-source" />

      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="add-transaction" />
      <Stack.Screen name="analytics" />
      <Stack.Screen name="budget" />
    </Stack>
  );
};

export default function RootLayout() {
  return (
    <AppProvider>
      <TransactionProvider>
        {/* InnerProviders needs access to transactions from TransactionProvider */}
        <ProvidersBridge />
      </TransactionProvider>
    </AppProvider>
  );
}

const ProvidersBridge: React.FC = () => {
  const { transactions } = useTransactions();

  return (
    <BudgetProvider transactions={transactions}>
      <GoalProvider>
        <RootLayoutContent />
      </GoalProvider>
    </BudgetProvider>
  );
};