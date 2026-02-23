import React, { useMemo } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Card } from '@/components/shared/CardComponent';
import { useApp } from '@/lib/context/AppContext';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS, SHADOWS } from '@/lib/theme';
import { formatCurrency, isThisMonth } from '@/lib/utils/helpers';

export default function BudgetScreen() {
  const router = useRouter();
  const { transactions, categories } = useApp();

  // Calculate spending by category
  const categorySpending = useMemo(() => {
    const spending: { [key: string]: number } = {};
    transactions
      .filter((t) => t.type === 'expense' && isThisMonth(t.date))
      .forEach((t) => {
        spending[t.category] = (spending[t.category] || 0) + t.amount;
      });
    return spending;
  }, [transactions]);

  // Get all categories with their spending
  const budgetList = useMemo(() => {
    return categories.map((cat) => {
      const spent = categorySpending[cat.id] || 0;
      const limit = 500; // Default limit, can be made dynamic
      const percentage = Math.min((spent / limit) * 100, 100);
      const status =
        percentage > 100 ? 'exceeded' : percentage > 80 ? 'warning' : 'safe';

      return {
        ...cat,
        spent,
        limit,
        percentage,
        status,
      };
    });
  }, [categories, categorySpending]);

  const totalSpent = useMemo(
    () => Object.values(categorySpending).reduce((sum, val) => sum + val, 0),
    [categorySpending]
  );

  const totalBudget = useMemo(() => categories.length * 500, [categories]);

  const getStatusColor = (
    status: 'exceeded' | 'warning' | 'safe'
  ): string => {
    switch (status) {
      case 'exceeded':
        return COLORS.dangerRed;
      case 'warning':
        return '#F5A623';
      case 'safe':
        return COLORS.successGreen;
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()}>
            <Ionicons name="chevron-back" size={28} color={COLORS.textPrimary} />
          </TouchableOpacity>
          <Text style={styles.title}>Budget</Text>
          <View style={{ width: 28 }} />
        </View>

        {/* Overall Budget Overview */}
        <Card style={{ ...styles.overviewCard, ...SHADOWS.soft }}>
          <Text style={styles.overviewLabel}>Monthly Budget</Text>
          <Text style={styles.overviewAmount}>
            {formatCurrency(totalSpent)} / {formatCurrency(totalBudget)}
          </Text>

          {/* Progress Bar */}
          <View style={styles.progressBarContainer}>
            <View
              style={[
                styles.progressBar,
                {
                  width: `${Math.min((totalSpent / totalBudget) * 100, 100)}%`,
                  backgroundColor: getStatusColor(
                    totalSpent > totalBudget
                      ? 'exceeded'
                      : totalSpent > totalBudget * 0.8
                        ? 'warning'
                        : 'safe'
                  ),
                },
              ]}
            />
          </View>

          <View style={styles.overviewStats}>
            <View>
              <Text style={styles.overviewStatLabel}>Spent</Text>
              <Text style={styles.overviewStatValue}>
                {formatCurrency(totalSpent)}
              </Text>
            </View>
            <View>
              <Text style={styles.overviewStatLabel}>Remaining</Text>
              <Text
                style={[
                  styles.overviewStatValue,
                  {
                    color: totalBudget - totalSpent < 0 ? COLORS.dangerRed : COLORS.successGreen,
                  },
                ]}
              >
                {formatCurrency(Math.max(totalBudget - totalSpent, 0))}
              </Text>
            </View>
          </View>
        </Card>

        {/* Category Budgets */}
        <Text style={styles.sectionTitle}>Category Budgets</Text>

        {budgetList.map((budget) => {
          const statusColor = getStatusColor(budget.status as 'exceeded' | 'warning' | 'safe');
          const statusEmoji =
            budget.status === 'exceeded'
              ? '❌'
              : budget.status === 'warning'
                ? '⚠️'
                : '✅';

          return (
            <Card key={budget.id} style={styles.budgetCard}>
              <View style={styles.budgetHeader}>
                <View style={styles.budgetTitle}>
                  <Text style={styles.budgetTitleEmoji}>{budget.icon}</Text>
                  <View>
                    <Text style={styles.budgetName}>{budget.name}</Text>
                    <Text style={styles.budgetSpent}>
                      {formatCurrency(budget.spent)} / {formatCurrency(budget.limit)}
                    </Text>
                  </View>
                </View>
                <Text style={styles.statusEmoji}>{statusEmoji}</Text>
              </View>

              {/* Progress Bar */}
              <View style={styles.progressBarContainer}>
                <View
                  style={[
                    styles.progressBar,
                    {
                      width: `${Math.min(budget.percentage, 100)}%`,
                      backgroundColor: statusColor,
                    },
                  ]}
                />
              </View>

              <View style={styles.budgetFooter}>
                <Text style={styles.budgetPercentage}>
                  {Math.round(budget.percentage)}%
                </Text>
                {budget.status === 'exceeded' && (
                  <Text style={styles.budgetExceeded}>
                    Over by {formatCurrency(budget.spent - budget.limit)}
                  </Text>
                )}
              </View>
            </Card>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  scrollContent: {
    paddingHorizontal: PADDING.horizontal,
    paddingVertical: SPACING.lg,
    paddingBottom: SPACING.xl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.lg,
  },
  title: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    fontSize: 24,
  },
  overviewCard: {
    padding: SPACING.lg,
    marginBottom: SPACING.lg,
  },
  overviewLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginBottom: SPACING.sm,
  },
  overviewAmount: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    fontSize: 24,
    marginBottom: SPACING.lg,
  },
  progressBarContainer: {
    height: 8,
    backgroundColor: COLORS.bgLight,
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: SPACING.lg,
  },
  progressBar: {
    height: '100%',
    borderRadius: 4,
  },
  overviewStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  overviewStatLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginBottom: SPACING.xs,
  },
  overviewStatValue: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '700',
  },
  sectionTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
  },
  budgetCard: {
    padding: SPACING.lg,
    marginBottom: SPACING.md,
  },
  budgetHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING.lg,
  },
  budgetTitle: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  budgetTitleEmoji: {
    fontSize: 20,
    marginRight: SPACING.md,
  },
  budgetName: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
    marginBottom: SPACING.xs,
  },
  budgetSpent: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  statusEmoji: {
    fontSize: 20,
  },
  budgetFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  budgetPercentage: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    fontWeight: '600',
  },
  budgetExceeded: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.dangerRed,
    fontWeight: '600',
  },
});
