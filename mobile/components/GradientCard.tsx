/**
 * GradientCard - Gradient balance card with gradient background
 */

import React from 'react';
import { View, Text, StyleSheet, ImageSourcePropType, Image } from 'react-native';
import { LinearGradient as LinearGradientComponent } from 'expo-linear-gradient';
import { COLORS, SPACING, SHADOWS } from '@/lib/theme';

interface GradientCardProps {
  label?: string;
  amount?: string;
  cardNumber?: string;
  expiryDate?: string;
  cardholderName?: string;
  gradientStart?: string;
  gradientEnd?: string;
  visaLogo?: boolean;
}

export const GradientCard: React.FC<GradientCardProps> = ({
  label = 'Balance',
  amount = '$50,450.00',
  cardNumber = '**** **** **** 3456',
  expiryDate = '12/28',
  cardholderName = 'John Doe',
  gradientStart = COLORS.purpleMain,
  gradientEnd = COLORS.purpleLight || '#8E7CFF',
  visaLogo = true,
}) => {
  return (
    <LinearGradientComponent
      colors={[gradientStart, gradientEnd]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={styles.container}
    >
      <View style={styles.topRow}>
        <Text style={styles.label}>{label}</Text>
        {visaLogo && <Text style={styles.visaText}>VISA</Text>}
      </View>

      <Text style={styles.amount}>{amount}</Text>

      <View style={styles.bottomRow}>
        <View style={styles.cardInfo}>
          <Text style={styles.cardNumber}>{cardNumber}</Text>
          <Text style={styles.cardholderName}>{cardholderName}</Text>
        </View>
        <View style={styles.expiryContainer}>
          <Text style={styles.expiryLabel}>EXP</Text>
          <Text style={styles.expiryDate}>{expiryDate}</Text>
        </View>
      </View>
    </LinearGradientComponent>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 24,
    padding: SPACING.lg,
    marginBottom: SPACING.lg,
    ...SHADOWS.soft,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  label: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.8)',
    fontWeight: '400',
  },
  visaText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFFFFF',
    letterSpacing: 1,
  },
  amount: {
    fontSize: 28,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: SPACING.xl,
  },
  bottomRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
  cardInfo: {
    flex: 1,
  },
  cardNumber: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.8)',
    fontWeight: '400',
    marginBottom: SPACING.sm,
  },
  cardholderName: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.7)',
    fontWeight: '500',
  },
  expiryContainer: {
    alignItems: 'flex-end',
  },
  expiryLabel: {
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.8)',
    fontWeight: '400',
    marginBottom: 2,
  },
  expiryDate: {
    fontSize: 14,
    color: '#FFFFFF',
    fontWeight: '600',
  },
});
