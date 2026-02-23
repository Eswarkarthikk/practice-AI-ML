// Archived duplicate Card component. Use CardComponent.tsx as canonical Card.

// Original contents kept for reference.

import React, { ReactNode } from 'react';
import { View, ViewStyle, StyleSheet } from 'react-native';
import { COLORS, SPACING, BORDER_RADIUS, SHADOWS } from '@/lib/theme';

interface CardProps {
  children: ReactNode;
  variant?: 'default' | 'outlined';
  padding?: number;
  style?: ViewStyle;
}

export const Card = ({
  children,
  variant = 'default',
  padding = SPACING.md,
  style,
}: CardProps) => {
  return (
    <View
      style={[
        styles.card,
        variant === 'outlined' && styles.outlined,
        { padding },
        style,
      ]}
    >
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.cardBg,
    borderRadius: BORDER_RADIUS.large,
    ...SHADOWS.soft,
  },
  outlined: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: COLORS.borderColor,
    shadowOpacity: 0,
    elevation: 0,
  },
});
