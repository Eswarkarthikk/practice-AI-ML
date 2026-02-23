/**
 * OperationButton - Individual operation button for operations row
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING } from '@/lib/theme';

interface OperationButtonProps {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  onPress: () => void;
  color?: string;
}

export const OperationButton: React.FC<OperationButtonProps> = ({
  icon,
  label,
  onPress,
  color = COLORS.textPrimary,
}) => {
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.iconContainer}>
        <Ionicons name={icon} size={22} color={color} />
      </View>
      <Text style={styles.label}>{label}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#EEF0F6',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  label: {
    fontSize: 12,
    color: COLORS.textPrimary,
    fontWeight: '500',
    textAlign: 'center',
  },
});
