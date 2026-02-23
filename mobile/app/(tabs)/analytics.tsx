import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useTransactions } from '@/lib/context/TransactionContext';
import { useApp } from '@/lib/context/AppContext';
import { calculateFinancialHealthScore, detectSpendingPatterns } from '@/lib/features/analytics/advancedAnalytics';
import { ScreenWrapper } from '@/components/ScreenWrapper';
import { COLORS, SPACING, SHADOWS } from '@/lib/theme';
import { SimplifiedDonutChart } from '@/components/DonutChart';

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

export default function RewardsScreen() {
  const { transactions } = useTransactions();

  const { budgets, goals } = useApp();

  const health = calculateFinancialHealthScore(transactions, budgets || [], goals || []);
  const patterns = detectSpendingPatterns(transactions);

  const totalIncome = transactions
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpense = transactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const categoryBreakdown: Record<string, number> = {};
  transactions
    .filter(t => t.type === 'expense')
    .forEach(t => {
      categoryBreakdown[t.category] = (categoryBreakdown[t.category] || 0) + t.amount;
    });

  const sortedCategories = Object.entries(categoryBreakdown).sort(
    (a, b) => b[1] - a[1]
  );

  const maxAmount = Math.max(...Object.values(categoryBreakdown), 1);
  const rewardsPoints = Math.floor((totalExpense / 100) * 10); // 10 points per 100 spent

  return (
    <ScreenWrapper>
      <Text style={styles.title}>Rewards & Analytics</Text>

      {/* Donut Chart Section */}
      <View style={styles.chartContainer}>
        <SimplifiedDonutChart
          data={sortedCategories}
          size={180}
          centerText={`${rewardsPoints}`}
        />
        <Text style={styles.chartLabel}>Points Earned</Text>
      </View>

      {/* Stats Cards Row */}
      <View style={styles.statsRow}>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Income</Text>
          <Text style={[styles.statValue, { color: COLORS.successGreen }]}>
            ${totalIncome.toFixed(0)}
          </Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Spent</Text>
          <Text style={[styles.statValue, { color: COLORS.dangerRed }]}>
            ${totalExpense.toFixed(0)}
          </Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Saved</Text>
          <Text style={[styles.statValue, { color: COLORS.purpleMain }]}>
            ${(totalIncome - totalExpense).toFixed(0)}
          </Text>
        </View>
      </View>

      {/* Financial Health */}
      <View style={styles.healthCard}>
        <Text style={{ fontSize: 16, fontWeight: '600', color: COLORS.textPrimary }}>Financial Health</Text>
        <Text style={{ fontSize: 28, fontWeight: '700', color: COLORS.purpleMain }}>{health.score}</Text>
        <Text style={{ color: COLORS.textSecondary }}>{health.rating.toUpperCase()}</Text>
        {health.recommendations.slice(0, 3).map((r, i) => (
          <Text key={i} style={{ color: COLORS.textSecondary, marginTop: 6 }}>• {r}</Text>
        ))}
      </View>

      {/* Detected Patterns */}
      <Text style={styles.sectionTitle}>Detected Patterns</Text>
      {patterns.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>No clear patterns detected</Text>
        </View>
      ) : (
        patterns.map((p, idx) => (
          <View key={idx} style={styles.categoryItem}>
            <Text style={{ color: COLORS.textPrimary }}>• {p}</Text>
          </View>
        ))
      )}

      {/* Category Breakdown */}
      <Text style={styles.sectionTitle}>Spending by Category</Text>
      {sortedCategories.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>No expenses yet</Text>
        </View>
      ) : (
        sortedCategories.map(([category, amount]) => (
          <View key={category} style={styles.categoryItem}>
            <View style={styles.categoryLeft}>
              <Text style={styles.categoryIcon}>
                {CATEGORY_ICONS[category] || '📌'}
              </Text>
              <View style={styles.categoryInfo}>
                <Text style={styles.categoryName}>
                  {category.charAt(0).toUpperCase() + category.slice(1)}
                </Text>
                <View style={styles.barContainer}>
                  <View
                    style={[
                      styles.bar,
                      {
                        width: `${Math.max((amount / maxAmount) * 100, 5)}%`,
                        backgroundColor:
                          amount / totalExpense > 0.4
                            ? COLORS.dangerRed
                            : amount / totalExpense > 0.2
                            ? '#F5A623'
                            : COLORS.successGreen,
                      },
                    ]}
                  />
                </View>
              </View>
            </View>
            <View style={styles.categoryRight}>
              <Text style={styles.categoryAmount}>${amount.toFixed(0)}</Text>
              <Text style={styles.categoryPercent}>
                {totalExpense > 0 ? ((amount / totalExpense) * 100).toFixed(0) : 0}%
              </Text>
            </View>
          </View>
        ))
      )}
    </ScreenWrapper>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.lg,
  },
  chartContainer: {
    alignItems: 'center',
    marginVertical: SPACING.xl,
    backgroundColor: COLORS.cardBg,
    borderRadius: 20,
    padding: SPACING.lg,
    ...SHADOWS.soft,
  },
  chartLabel: {
    fontSize: 14,
    color: COLORS.textSecondary,
    fontWeight: '500',
    marginTop: SPACING.md,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING.lg,
    gap: SPACING.sm,
  },
  statCard: {
    flex: 1,
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    padding: SPACING.md,
    alignItems: 'center',
    ...SHADOWS.soft,
  },
  statLabel: {
    fontSize: 12,
    color: COLORS.textSecondary,
    fontWeight: '400',
    marginBottom: SPACING.sm,
  },
  statValue: {
    fontSize: 16,
    fontWeight: '600',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    marginTop: SPACING.lg,
  },
  emptyContainer: {
    backgroundColor: COLORS.cardBg,
    borderRadius: 12,
    padding: SPACING.xl,
    alignItems: 'center',
    ...SHADOWS.soft,
  },
  emptyText: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  categoryItem: {
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    padding: SPACING.md,
    marginBottom: SPACING.sm,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    ...SHADOWS.soft,
  },
  categoryLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    gap: SPACING.md,
  },
  categoryIcon: {
    fontSize: 24,
  },
  categoryInfo: {
    flex: 1,
  },
  categoryName: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
  },
  barContainer: {
    height: 6,
    backgroundColor: COLORS.borderColor,
    borderRadius: 3,
    overflow: 'hidden',
  },
  bar: {
    height: '100%',
    borderRadius: 3,
  },
  categoryRight: {
    alignItems: 'flex-end',
  },
  categoryAmount: {
    fontSize: 14,
    fontWeight: '700',
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
  },
  categoryPercent: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  healthCard: {
    backgroundColor: COLORS.cardBg,
    padding: SPACING.lg,
    borderRadius: 16,
    marginBottom: SPACING.lg,
    ...SHADOWS.soft,
  },
});
