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
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { Card } from '@/components/shared/CardComponent';
import { TransactionItem } from '@/components/TransactionItem';
import { FooterNavigation } from '@/components/FooterNavigation';
import { useApp } from '@/lib/context/AppContext';
import { useBudget } from '@/lib/features/budgets/BudgetContext';
import { useGoals } from '@/lib/features/goals/GoalContext';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS, SHADOWS } from '@/lib/theme';
import { formatCurrency, isThisMonth } from '@/lib/utils/helpers';

export default function HomeScreen() {
  const router = useRouter();
  const { profile, sources, transactions } = useApp();

  // Calculate totals
  const balance = useMemo(() => {
    let total = 0;
    sources.forEach((source) => {
      total += source.startingAmount;
      const sourceTransactions = transactions.filter((t) => t.source === source.id);
      sourceTransactions.forEach((t) => {
        if (t.type === 'income') {
          total += t.amount;
        } else {
          total -= t.amount;
        }
      });
    });
    return total;
  }, [sources, transactions]);

  const monthlyIncome = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'income' && isThisMonth(t.date))
      .reduce((sum, t) => sum + t.amount, 0);
  }, [transactions]);

  const monthlyExpense = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'expense' && isThisMonth(t.date))
      .reduce((sum, t) => sum + t.amount, 0);
  }, [transactions]);

  const { getBudgetStats } = useBudget();
  const { goals, getGoalStats } = useGoals();

  const currentMonthKey = useMemo(() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
  }, []);

  const budgetStats = useMemo(() => getBudgetStats(currentMonthKey), [getBudgetStats, currentMonthKey]);

  const primaryGoal = useMemo(() => (goals && goals.length > 0 ? goals[0] : null), [goals]);
  const primaryGoalStats = useMemo(() => (primaryGoal ? getGoalStats(primaryGoal.id) : null), [primaryGoal, getGoalStats]);

  const recentTransactions = useMemo(() => {
    return transactions.sort((a, b) => b.timestamp - a.timestamp).slice(0, 5);
  }, [transactions]);

  const getCategoryIcon = (category: string) => {
    const icons: { [key: string]: string } = {
      food: '🍔',
      transport: '🚗',
      entertainment: '🎬',
      shopping: '🛍️',
      bills: '📄',
      health: '🏥',
      other: '📦',
    };
    return icons[category] || '📌';
  };

  const handleAddTransaction = () => {
    router.push('/add-transaction' as any);
  };

  const handleAnalytics = () => {
    router.push('/analytics' as any);
  };

  const handleBudget = () => {
    router.push('/budget' as any);
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
          <View>
            <Text style={styles.greeting}>Hello, {profile?.name || 'User'}! 👋</Text>
            <Text style={styles.date}>{new Date().toLocaleDateString()}</Text>
          </View>
          <Ionicons name="notifications-outline" size={24} color={COLORS.textSecondary} />
        </View>

        {/* Budget & Goal Summaries */}
        <View style={{ marginBottom: SPACING.lg }}>
          <Card style={{ padding: SPACING.md, marginBottom: SPACING.md }}>
            <Text style={styles.sectionTitle}>Budget Overview</Text>
            <Text style={styles.smallText}>
              {budgetStats.totalLimit > 0
                ? `${Math.round(budgetStats.percentageUsed)}% of ${formatCurrency(budgetStats.totalLimit)} used`
                : 'No budget set for this month'}
            </Text>
            {budgetStats.totalLimit > 0 && (
              <View style={styles.progressTrack}>
                <View style={[styles.progressFill, { width: `${Math.min(100, Math.round(budgetStats.percentageUsed))}%`, backgroundColor: budgetStats.status === 'exceeded' ? COLORS.dangerRed : budgetStats.status === 'warning' ? COLORS.warningOrange : COLORS.successGreen }]} />
              </View>
            )}
          </Card>

          <Card style={{ padding: SPACING.md }}>
            <Text style={styles.sectionTitle}>Primary Goal</Text>
            {primaryGoalStats ? (
              <>
                <Text style={styles.smallText}>{primaryGoalStats.goal.title}</Text>
                <Text style={styles.smallText}>{Math.round(primaryGoalStats.percentageComplete)}% complete</Text>
                <View style={styles.progressTrack}>
                  <View style={[styles.progressFill, { width: `${Math.min(100, Math.round(primaryGoalStats.percentageComplete))}%`, backgroundColor: COLORS.purpleMain }]} />
                </View>
              </>
            ) : (
              <Text style={styles.smallText}>No active savings goals. Create one to get started.</Text>
            )}
          </Card>
        </View>

        {/* Balance Card */}
        <LinearGradient
          colors={[COLORS.purpleMain, COLORS.purpleLight]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.balanceCard, SHADOWS.soft]}
        >
          <Text style={styles.balanceLabel}>Total Balance</Text>
          <Text style={styles.balanceAmount}>{formatCurrency(balance)}</Text>

          <View style={styles.balanceStats}>
            <View style={styles.statItem}>
              <Text style={styles.statLabel}>Income</Text>
              <Text style={styles.statAmount}>{formatCurrency(monthlyIncome)}</Text>
            </View>
            <View style={styles.divider} />
            <View style={styles.statItem}>
              <Text style={styles.statLabel}>Expense</Text>
              <Text style={styles.statAmount}>{formatCurrency(monthlyExpense)}</Text>
            </View>
          </View>
        </LinearGradient>

        {/* Quick Actions */}
        <View style={styles.quickActions}>
          <QuickActionButton
            icon="add-circle-outline"
            label="Add Transaction"
            onPress={handleAddTransaction}
          />
          <QuickActionButton
            icon="bar-chart"
            label="Analytics"
            onPress={handleAnalytics}
          />
          <QuickActionButton
            icon="wallet-outline"
            label="Budget"
            onPress={handleBudget}
          />
        </View>

        {/* Recent Transactions */}
        {recentTransactions.length > 0 && (
          <View style={styles.recentSection}>
            <Text style={styles.sectionTitle}>Recent Transactions</Text>
            {recentTransactions.map((transaction) => {
              const isIncome = transaction.type === 'income';
              return (
                <Card key={transaction.id} style={styles.transactionItem}>
                  <TransactionItem
                    icon={isIncome ? 'wallet-outline' : 'card-outline'}
                    title={transaction.category}
                    subtitle={transaction.date}
                    amount={formatCurrency(transaction.amount)}
                    isExpense={!isIncome}
                    onEdit={() => router.push(`/add-transaction?id=${transaction.id}` as any)}
                  />
                </Card>
              );
            })}
          </View>
        )}

        {/* Empty State */}
        {recentTransactions.length === 0 && (
          <View style={styles.emptyState}>
            <Text style={styles.emptyStateEmoji}>📊</Text>
            <Text style={styles.emptyStateText}>No transactions yet</Text>
            <Text style={styles.emptyStateSubtext}>
              Add your first transaction to get started
            </Text>
          </View>
        )}
      </ScrollView>

      {/* Footer Navigation */}
      <FooterNavigation activeTab="home" />
    </View>
  );
}

interface QuickActionButtonProps {
  icon: string;
  label: string;
  onPress: () => void;
}

const QuickActionButton: React.FC<QuickActionButtonProps> = ({
  icon,
  label,
  onPress,
}) => {
  return (
    <TouchableOpacity activeOpacity={0.7} onPress={onPress} style={styles.actionButton}>
      <View style={styles.actionIconContainer}>
        <Ionicons name={icon as any} size={24} color={COLORS.purpleMain} />
      </View>
      <Text style={styles.actionLabel}>{label}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  scrollContent: {
    paddingHorizontal: PADDING.horizontal,
    paddingVertical: SPACING.lg,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING.lg,
  },
  greeting: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
  },
  date: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  balanceCard: {
    borderRadius: BORDER_RADIUS.card,
    padding: SPACING.lg,
    marginBottom: SPACING.lg,
  },
  balanceLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.cardBg,
    opacity: 0.9,
    marginBottom: SPACING.sm,
  },
  balanceAmount: {
    fontSize: 32,
    fontWeight: '700',
    color: COLORS.cardBg,
    marginBottom: SPACING.lg,
  },
  balanceStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  statItem: {
    flex: 1,
  },
  statLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.cardBg,
    opacity: 0.8,
    marginBottom: SPACING.sm,
  },
  statAmount: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.cardBg,
    fontWeight: '700',
  },
  divider: {
    width: 1,
    height: 30,
    backgroundColor: COLORS.cardBg,
    opacity: 0.3,
  },
  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING.xl,
  },
  actionButton: {
    alignItems: 'center',
    flex: 1,
  },
  actionIconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: COLORS.bgLight,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.sm,
    ...SHADOWS.soft,
  },
  actionLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
  recentSection: {
    marginTop: SPACING.lg,
  },
  sectionTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
  },
  transactionItem: {
    marginBottom: SPACING.md,
    padding: SPACING.md,
  },
  transactionContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  transactionLeft: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  categoryIcon: {
    width: 45,
    height: 45,
    borderRadius: 22.5,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  categoryIconText: {
    fontSize: 20,
  },
  transactionCategory: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
    marginBottom: SPACING.xs,
  },
  transactionDate: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  transactionAmount: {
    ...TYPOGRAPHY.styles.body,
    fontWeight: '700',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: SPACING.xl,
  },
  emptyStateEmoji: {
    fontSize: 48,
    marginBottom: SPACING.md,
  },
  emptyStateText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
    marginBottom: SPACING.sm,
  },
  emptyStateSubtext: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  smallText: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginBottom: SPACING.sm,
  },
  progressTrack: {
    height: 8,
    width: '100%',
    backgroundColor: COLORS.cardBg,
    borderRadius: 8,
    overflow: 'hidden',
    marginTop: SPACING.sm,
  },
  progressFill: {
    height: '100%',
    borderRadius: 8,
  },
});
