/**
 * ScreenWrapper - Consistent screen layout wrapper
 * Provides SafeAreaView, ScrollView, and proper background
 */

import React, { ReactNode } from 'react';
import { SafeAreaView, ScrollView, View, StyleSheet, ViewStyle } from 'react-native';
import { COLORS, SPACING } from '@/lib/theme';

interface ScreenWrapperProps {
  children: ReactNode;
  style?: ViewStyle;
  scrollEnabled?: boolean;
  paddingHorizontal?: number;
}

export const ScreenWrapper: React.FC<ScreenWrapperProps> = ({
  children,
  style,
  scrollEnabled = true,
  paddingHorizontal = SPACING.md,
}) => {
  return (
    <SafeAreaView style={[styles.container, style]}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        scrollEnabled={scrollEnabled}
        contentContainerStyle={{
          paddingHorizontal: paddingHorizontal,
          paddingBottom: SPACING.xl,
        }}
      >
        {children}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
});
