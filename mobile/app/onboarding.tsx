import React from 'react';
import {
  View,
  StyleSheet,
  Text,
  Image,
  StatusBar,
} from 'react-native';
import { useRouter } from 'expo-router';
import { PrimaryButton } from '@/components/shared/PrimaryButton';
import { COLORS, TYPOGRAPHY, SPACING, PADDING } from '@/lib/theme';

export default function OnboardingScreen() {
  const router = useRouter();

  const handleGetStarted = () => {
    router.push('/profile-setup' as any);
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <View style={styles.content}>
        {/* Logo/Illustration Area */}
        <View style={styles.illustrationContainer}>
          <Text style={styles.emoji}>💰</Text>
        </View>

        {/* Text Content */}
        <View style={styles.textContainer}>
          <Text style={styles.title}>Track Your Transactions</Text>
          <Text style={styles.subtitle}>
            Manage your finances with ease. Track income, expenses, and reach your financial goals.
          </Text>
        </View>
      </View>

      {/* Button */}
      <View style={styles.buttonContainer}>
        <PrimaryButton
          title="Get Started"
          onPress={handleGetStarted}
          gradient
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
    paddingHorizontal: PADDING.horizontal,
    justifyContent: 'space-between',
    paddingTop: SPACING.xl,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  illustrationContainer: {
    marginBottom: SPACING.xl,
  },
  emoji: {
    fontSize: 80,
  },
  textContainer: {
    alignItems: 'center',
  },
  title: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    fontSize: 28,
    fontWeight: '700',
  },
  subtitle: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
    maxWidth: '90%',
  },
  buttonContainer: {
    marginBottom: SPACING.lg,
  },
});
