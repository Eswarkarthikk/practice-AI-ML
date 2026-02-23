/**
 * FAB - Floating Action Button
 */

import React from 'react';
import { TouchableOpacity, StyleSheet, ViewStyle } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SHADOWS } from '@/lib/theme';

interface FABProps {
  icon?: keyof typeof Ionicons.glyphMap;
  onPress: () => void;
  color?: string;
  backgroundColor?: string;
  style?: ViewStyle;
}

export const FAB: React.FC<FABProps> = ({
  icon = 'add',
  onPress,
  color = '#FFFFFF',
  backgroundColor = COLORS.purpleMain,
  style,
}) => {
  return (
    <TouchableOpacity
      style={[
        styles.container,
        { backgroundColor },
        style,
      ]}
      onPress={onPress}
      activeOpacity={0.8}
    >
      <Ionicons name={icon} size={26} color={color} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 30,
    right: 30,
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    ...SHADOWS.soft,
  },
});
