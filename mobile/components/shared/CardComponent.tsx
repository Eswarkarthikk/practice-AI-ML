import React from 'react';
import {
  View,
  StyleSheet,
  ViewStyle,
  TouchableOpacity,
} from 'react-native';
import { COLORS, SPACING, SHADOWS, BORDER_RADIUS } from '@/lib/theme';

interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
  padding?: number;
}

export const Card: React.FC<CardProps> = ({
  children,
  style,
  onPress,
  padding = SPACING.lg,
}) => {
  const cardStyle = [
    styles.container,
    { padding },
    style,
  ];

  if (onPress) {
    return (
      <TouchableOpacity
        activeOpacity={0.85}
        onPress={onPress}
        style={cardStyle}
      >
        {children}
      </TouchableOpacity>
    );
  }

  return <View style={cardStyle}>{children}</View>;
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: COLORS.cardBg,
    borderRadius: BORDER_RADIUS.card,
    ...SHADOWS.soft,
  },
});
