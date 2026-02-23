/**
 * SectionTitle - Section header text
 */

import React from 'react';
import { Text, StyleSheet, TextStyle, StyleProp } from 'react-native';
import { COLORS, SPACING } from '@/lib/theme';

interface SectionTitleProps {
  title: string;
  style?: StyleProp<TextStyle>;
}

export const SectionTitle: React.FC<SectionTitleProps> = ({
  title,
  style,
}) => {
  return <Text style={[styles.title, style]}>{title}</Text>;
};

const styles = StyleSheet.create({
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    marginTop: SPACING.lg,
  },
});
