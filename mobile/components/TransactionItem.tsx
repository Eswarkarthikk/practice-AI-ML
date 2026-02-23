/**
 * TransactionItem - Individual transaction item for list
 */

import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING } from '@/lib/theme';

interface TransactionItemProps {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle: string;
  amount: string;
  isExpense: boolean;
  iconColor?: string;
  onEdit?: () => void;
}

export const TransactionItem: React.FC<TransactionItemProps> = ({
  icon,
  title,
  subtitle,
  amount,
  isExpense,
  iconColor = COLORS.purpleMain,
  onEdit,
}) => {
  const amountColor = isExpense ? COLORS.dangerRed : COLORS.successGreen;

  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Ionicons name={icon} size={24} color={iconColor} />
      </View>

      <View style={styles.content}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.subtitle}>{subtitle}</Text>
      </View>

      <View style={styles.amountContainer}>
        <Text style={[styles.amount, { color: amountColor }]}> 
          {isExpense ? '-' : '+'}{amount}
        </Text>
        {onEdit && (
          <TouchableOpacity onPress={onEdit} style={styles.editButton} activeOpacity={0.7}>
            <Ionicons name="pencil" size={16} color={COLORS.textSecondary} />
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
  },
  iconContainer: {
    width: 45,
    height: 45,
    borderRadius: 22.5,
    backgroundColor: '#EEF0F6',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.textPrimary,
    marginBottom: 2,
  },
  subtitle: {
    fontSize: 12,
    color: COLORS.textSecondary,
    fontWeight: '400',
  },
  amountContainer: {
    alignItems: 'flex-end',
  },
  amount: {
    fontSize: 14,
    fontWeight: '600',
  },
  editButton: {
    marginTop: 8,
    marginLeft: 8,
    padding: 6,
    borderRadius: 6,
  },
});
