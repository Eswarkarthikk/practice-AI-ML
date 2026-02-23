import React, { useState } from 'react';
import { View, Text, StyleSheet, Pressable, FlatList } from 'react-native';
import { useTransactions } from '@/lib/context/TransactionContext';
import { COLORS, SPACING, SHADOWS } from '@/lib/theme';
import type { Category, Transaction } from '@/lib/types/transaction';
import { Ionicons } from '@expo/vector-icons';

const CATEGORY_ICONS: Record<string, string> = {
  food: '🍔',
  transport: '🚗',
  entertainment: '🎬',
  shopping: '🛍️',
  utilities: '💡',
  health: '🏥',
  salary: '💵',
  investment: '📈',
  other: '📌',
};

export default function TransactionHistoryScreen() {
  const { transactions, deleteTransaction } = useTransactions();
  const [filterType, setFilterType] = useState<'all' | 'income' | 'expense'>('all');

  const filteredTransactions = transactions.filter(
    t => filterType === 'all' || t.type === filterType
  );

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-IN', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const renderTransaction = ({ item }: { item: Transaction }) => (
    <Pressable
      style={[
        styles.transactionCard,
        {
          borderLeftColor:
            item.type === 'income'
              ? COLORS.successGreen
              : COLORS.dangerRed,
        },
      ]}
      onLongPress={() => deleteTransaction(item.id)}
    >
      <View style={styles.transactionLeft}>
        <View style={styles.iconCircle}>
          <Text style={styles.categoryIcon}>
            {CATEGORY_ICONS[item.category as string]}
          </Text>
        </View>
        <View style={styles.transactionInfo}>
          <Text style={styles.transactionDescription}>{item.description}</Text>
          <Text style={styles.transactionDate}>{formatDate(item.date)}</Text>
        </View>
      </View>
      <Text
        style={[
          styles.transactionAmount,
          {
            color:
              item.type === 'income'
                ? COLORS.successGreen
                : COLORS.dangerRed,
          },
        ]}
      >
        {item.type === 'income' ? '+' : '-'}${item.amount.toFixed(2)}
      </Text>
    </Pressable>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Transaction History</Text>
      </View>

      {/* Filter Buttons */}
      <View style={styles.filterContainer}>
        <Pressable
          style={[
            styles.filterButton,
            filterType === 'all' && styles.filterActive,
          ]}
          onPress={() => setFilterType('all')}
        >
          <Text
            style={[
              styles.filterText,
              filterType === 'all' && styles.filterTextActive,
            ]}
          >
            All
          </Text>
        </Pressable>
        <Pressable
          style={[
            styles.filterButton,
            filterType === 'income' && styles.filterActive,
          ]}
          onPress={() => setFilterType('income')}
        >
          <Text
            style={[
              styles.filterText,
              filterType === 'income' && styles.filterTextActive,
            ]}
          >
            Income
          </Text>
        </Pressable>
        <Pressable
          style={[
            styles.filterButton,
            filterType === 'expense' && styles.filterActive,
          ]}
          onPress={() => setFilterType('expense')}
        >
          <Text
            style={[
              styles.filterText,
              filterType === 'expense' && styles.filterTextActive,
            ]}
          >
            Expense
          </Text>
        </Pressable>
      </View>

      {/* Transactions List */}
      {filteredTransactions.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Ionicons name="receipt" size={48} color={COLORS.textSecondary} />
          <Text style={styles.emptyText}>No transactions</Text>
          <Text style={styles.emptySubText}>
            Tap to add your first transaction
          </Text>
        </View>
      ) : (
        <FlatList
          data={filteredTransactions as any[]}
          renderItem={renderTransaction}
          keyExtractor={item => item.id}
          scrollEnabled={true}
          contentContainerStyle={styles.listContent}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  header: {
    paddingHorizontal: SPACING.md,
    paddingTop: SPACING.md,
    paddingBottom: SPACING.lg,
  },
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.lg,
  },
  filterContainer: {
    flexDirection: 'row',
    gap: SPACING.sm,
    marginBottom: SPACING.lg,
    paddingHorizontal: SPACING.md,
  },
  filterButton: {
    flex: 1,
    paddingVertical: SPACING.sm,
    paddingHorizontal: SPACING.md,
    borderRadius: 12,
    backgroundColor: COLORS.cardBg,
    alignItems: 'center',
    ...SHADOWS.soft,
  },
  filterActive: {
    backgroundColor: COLORS.purpleMain,
  },
  filterText: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.textSecondary,
  },
  filterTextActive: {
    color: '#FFFFFF',
    fontWeight: '600',
  },
  listContent: {
    paddingHorizontal: SPACING.md,
    paddingTop: 0,
    paddingBottom: SPACING.xl,
  },
  transactionCard: {
    backgroundColor: COLORS.cardBg,
    borderRadius: 18,
    padding: SPACING.md,
    marginBottom: SPACING.sm,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderLeftWidth: 4,
    ...SHADOWS.soft,
  },
  transactionLeft: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    gap: SPACING.md,
  },
  iconCircle: {
    width: 45,
    height: 45,
    borderRadius: 22.5,
    backgroundColor: '#EEF0F6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  categoryIcon: {
    fontSize: 20,
  },
  transactionInfo: {
    flex: 1,
  },
  transactionDescription: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.xs,
    textTransform: 'capitalize',
  },
  transactionDate: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  transactionAmount: {
    fontSize: 14,
    fontWeight: '600',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: SPACING.lg,
    marginTop: SPACING.xl,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginTop: SPACING.md,
    marginBottom: SPACING.sm,
  },
  emptySubText: {
    fontSize: 14,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
});
