import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS, TYPOGRAPHY, SPACING, SHADOWS } from '@/lib/theme';

interface PrimaryButtonProps {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  gradient?: boolean;
}

export const PrimaryButton: React.FC<PrimaryButtonProps> = ({
  title,
  onPress,
  loading = false,
  disabled = false,
  style,
  gradient = true,
}) => {
  const buttonContent = (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onPress}
      disabled={loading || disabled}
      style={[
        styles.container,
        disabled && styles.disabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={COLORS.cardBg} size="small" />
      ) : (
        <Text style={styles.text}>{title}</Text>
      )}
    </TouchableOpacity>
  );

  if (gradient) {
    return (
      <LinearGradient
        colors={[COLORS.purpleMain, COLORS.purpleLight]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[styles.gradient, disabled && styles.disabledGradient]}
      >
        {buttonContent}
      </LinearGradient>
    );
  }

  return buttonContent;
};

interface SecondaryButtonProps {
  title: string;
  onPress: () => void;
  disabled?: boolean;
  style?: ViewStyle;
}

export const SecondaryButton: React.FC<SecondaryButtonProps> = ({
  title,
  onPress,
  disabled = false,
  style,
}) => {
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onPress}
      disabled={disabled}
      style={[styles.secondaryContainer, disabled && styles.disabled, style]}
    >
      <Text style={styles.secondaryText}>{title}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    height: 50,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    ...SHADOWS.soft,
  },
  gradient: {
    borderRadius: 18,
  },
  text: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.cardBg,
    fontWeight: '600',
  },
  disabled: {
    opacity: 0.6,
  },
  disabledGradient: {
    opacity: 0.6,
  },
  secondaryContainer: {
    height: 50,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: COLORS.purpleMain,
  },
  secondaryText: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.purpleMain,
    fontWeight: '600',
  },
});
