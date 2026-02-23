/**
 * Header - Screen header with greeting and avatar
 */

import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, TYPOGRAPHY, SHADOWS } from '@/lib/theme';

interface HeaderProps {
  greeting?: string;
  name?: string;
  subtitle?: string;
  onBellPress?: () => void;
  avatarUrl?: string;
  showBell?: boolean;
}

export const Header: React.FC<HeaderProps> = ({
  greeting = 'Hey',
  name = 'Antor',
  subtitle = 'Welcome back',
  onBellPress,
  avatarUrl,
  showBell = true,
}) => {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <View style={styles.avatar}>
          {avatarUrl ? (
            <Image source={{ uri: avatarUrl }} style={styles.avatarImage} />
          ) : (
            <View style={styles.avatarPlaceholder}>
              <Text style={styles.avatarInitial}>A</Text>
            </View>
          )}
        </View>
        <View style={styles.textContent}>
          <Text style={styles.greeting}>{greeting}</Text>
          <Text style={styles.name}>
            {name}
          </Text>
          <Text style={styles.subtitle}>{subtitle}</Text>
        </View>
      </View>

      {showBell && (
        <TouchableOpacity
          style={styles.bellContainer}
          onPress={onBellPress}
          activeOpacity={0.7}
        >
          <Ionicons name="notifications" size={24} color={COLORS.textPrimary} />
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 60,
    marginBottom: SPACING.lg,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    marginRight: SPACING.md,
    overflow: 'hidden',
  },
  avatarImage: {
    width: '100%',
    height: '100%',
  },
  avatarPlaceholder: {
    width: '100%',
    height: '100%',
    backgroundColor: COLORS.purpleMain,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarInitial: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  textContent: {
    flex: 1,
  },
  greeting: {
    fontSize: 12,
    color: COLORS.textSecondary,
    fontWeight: '400',
  },
  name: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.textPrimary,
  },
  subtitle: {
    fontSize: 12,
    color: COLORS.textSecondary,
    fontWeight: '400',
    marginTop: 2,
  },
  bellContainer: {
    padding: SPACING.sm,
  },
});
