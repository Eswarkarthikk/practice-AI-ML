// Progress Bar Component with Status Colors

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS, SPACING, BORDER_RADIUS, TYPOGRAPHY } from '@/lib/theme';

interface ProgressBarProps {
  percentage: number; // 0-100
  height?: number;
  showPercentage?: boolean;
  color?: string; // If not provided, auto-select based on percentage
}

export const ProgressBar: React.FC<ProgressBarProps> = ({
  percentage,
  height = 8,
  showPercentage = false,
  color,
}) => {
  const clampedPercentage = Math.min(100, Math.max(0, percentage));
  
  // Auto-select color based on percentage if not provided
  let barColor = color;
  if (!barColor) {
    if (clampedPercentage >= 90) barColor = COLORS.dangerRed;
    else if (clampedPercentage >= 60) barColor = COLORS.warningOrange;
    else barColor = COLORS.successGreen;
  }

  return (
    <View style={styles.container}>
      <View
        style={[
          styles.background,
          { height },
        ]}
      >
        <View
          style={[
            styles.fill,
            {
              width: `${clampedPercentage}%`,
              height: '100%',
              backgroundColor: barColor,
            },
          ]}
        />
      </View>
      {showPercentage && (
        <Text style={styles.label}>{Math.round(clampedPercentage)}%</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  background: {
    width: '100%',
    backgroundColor: COLORS.borderColor,
    borderRadius: BORDER_RADIUS.full,
    overflow: 'hidden',
  },
  fill: {
    borderRadius: BORDER_RADIUS.full,
  },
  label: {
    fontSize: 12,
    fontWeight: '500',
    marginTop: SPACING.sm,
    color: COLORS.textSecondary,
  },
});
