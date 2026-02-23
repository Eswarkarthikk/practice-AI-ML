// Button Component - Professional button variants

import React from 'react';
import { Pressable, Text, StyleSheet, ActivityIndicator, ViewStyle } from 'react-native';
import { COLORS, SPACING, TYPOGRAPHY, BORDER_RADIUS } from '@/lib/theme';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';
type ButtonSize = 'small' | 'medium' | 'large';

interface ButtonProps {
  onPress: () => void;
  title: string;
  variant?: ButtonVariant;
  size?: ButtonSize;
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  onPress,
  title,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
  fullWidth = false,
}) => {
  const sizeStyles: Record<string, ViewStyle> = {
    small: { height: 36, paddingHorizontal: SPACING.md },
    medium: { height: 48, paddingHorizontal: SPACING.lg },
    large: { height: 56, paddingHorizontal: SPACING.lg },
  };

  const variantStyles: Record<string, ViewStyle> = {
    primary: {
      backgroundColor: COLORS.purpleMain,
      borderColor: COLORS.purpleMain,
    },
    secondary: {
      backgroundColor: 'transparent',
      borderColor: COLORS.purpleMain,
    },
    danger: {
      backgroundColor: COLORS.dangerRed,
      borderColor: COLORS.dangerRed,
    },
    ghost: {
      backgroundColor: 'transparent',
      borderColor: 'transparent',
    },
  };

  const textColors: Record<string, string> = {
    primary: COLORS.cardBg,
    secondary: COLORS.purpleMain,
    danger: COLORS.cardBg,
    ghost: COLORS.purpleMain,
  };

  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        styles.button,
        sizeStyles[size],
        variantStyles[variant],
        { borderWidth: variant === 'secondary' ? 1 : 0 },
        fullWidth && { width: '100%' },
        (disabled || loading) && { opacity: 0.6 },
      ]}
    >
      {loading ? (
        <ActivityIndicator color={textColors[variant]} />
      ) : (
        <Text
          style={[
            TYPOGRAPHY.styles.body,
            { color: textColors[variant], fontWeight: '600' },
          ]}
        >
          {title}
        </Text>
      )}
    </Pressable>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: BORDER_RADIUS.medium,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
