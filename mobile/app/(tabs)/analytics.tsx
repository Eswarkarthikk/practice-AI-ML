import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useTransactions } from '@/lib/context/TransactionContext';
import { calculateAnalytics, generateAIInsights } from '@/lib/utils/analytics';

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

export default function AnalyticsScreen() {
  const { transactions } = useTransactions();
  const analytics = calculateAnalytics(transactions);
  const insights = generateAIInsights(analytics, transactions);

  const renderProgressBar = (value: number, max: number) => {
    const percentage = max > 0 ? (value / max) * 100 : 0;
    return (
      <View style={styles.progressBarContainer}>
        <View style={[styles.progressBar, { width: `${Math.min(percentage, 100)}%` }]} />
      </View>
    );
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>📊 Analytics Dashboard</Text>

      {/* Summary Cards */}
      <View style={styles.summaryContainer}>
        <View style={[styles.summaryCard, styles.incomeCard]}>
          <Text style={styles.summaryLabel}>Total Income</Text>
          <Text style={styles.summaryAmount}>₹{analytics.totalIncome.toFixed(2)}</Text>
        </View>
        <View style={[styles.summaryCard, styles.expenseCard]}>
          <Text style={styles.summaryLabel}>Total Expenses</Text>
          <Text style={styles.summaryAmount}>₹{analytics.totalExpense.toFixed(2)}</Text>
        </View>
        <View style={[styles.summaryCard, analytics.balance > 0 ? styles.balanceCardPositive : styles.balanceCardNegative]}>
          <Text style={styles.summaryLabel}>Balance</Text>
          <Text style={styles.summaryAmount}>₹{analytics.balance.toFixed(2)}</Text>
        </View>
      </View>

      {/* Key Metrics */}
      <View style={styles.metricsSection}>
        <Text style={styles.sectionTitle}>Key Metrics</Text>
        <View style={styles.metricCard}>
          <Text style={styles.metricLabel}>📈 Daily Average Spending</Text>
          <Text style={styles.metricValue}>₹{analytics.dailyAverage.toFixed(2)}</Text>
        </View>
        <View style={styles.metricCard}>
          <Text style={styles.metricLabel}>💳 Total Transactions</Text>
          <Text style={styles.metricValue}>{analytics.transactionCount}</Text>
        </View>
      </View>

      {/* Category Breakdown */}
      <View style={styles.categorySection}>
        <Text style={styles.sectionTitle}>Spending by Category</Text>
        {Object.keys(analytics.categoryBreakdown).length === 0 ? (
          <Text style={styles.emptyText}>No expense data yet</Text>
        ) : (
          Object.entries(analytics.categoryBreakdown)
            .sort(([, a], [, b]) => b - a)
            .map(([category, amount]) => (
              <View key={category} style={styles.categoryItem}>
                <View style={styles.categoryHeader}>
                  <Text style={styles.categoryName}>
                    {CATEGORY_ICONS[category] || '📌'} {category}
                  </Text>
                  <Text style={styles.categoryAmount}>₹{amount.toFixed(2)}</Text>
                </View>
                {renderProgressBar(amount, analytics.totalExpense)}
                <Text style={styles.categoryPercent}>
                  {((amount / analytics.totalExpense) * 100).toFixed(1)}%
                </Text>
              </View>
            ))
        )}
      </View>

      {/* Monthly Trend */}
      {analytics.monthlyTrend.length > 0 && (
        <View style={styles.trendSection}>
          <Text style={styles.sectionTitle}>Monthly Trend</Text>
          {analytics.monthlyTrend.map((data, index) => (
            <View key={index} style={styles.trendItem}>
              <View style={styles.trendMonthLabel}>
                <Text style={styles.trendMonth}>{data.month}</Text>
              </View>
              <View style={styles.trendValues}>
                <View style={styles.trendValue}>
                  <Text style={styles.trendLabel}>Income</Text>
                  <Text style={[styles.trendNumber, styles.incomeText]}>
                    +₹{data.income.toFixed(0)}
                  </Text>
                </View>
                <View style={styles.trendValue}>
                  <Text style={styles.trendLabel}>Expense</Text>
                  <Text style={[styles.trendNumber, styles.expenseText]}>
                    -₹{data.expense.toFixed(0)}
                  </Text>
                </View>
              </View>
            </View>
          ))}
        </View>
      )}

      {/* AI Insights */}
      <View style={styles.insightsSection}>
        <Text style={styles.sectionTitle}>🤖 AI Insights</Text>
        {insights.length === 0 ? (
          <Text style={styles.emptyText}>Add more transactions to get insights</Text>
        ) : (
          insights.map((insight, index) => (
            <View key={index} style={styles.insightCard}>
              <Text style={styles.insightText}>{insight}</Text>
            </View>
          ))
        )}
      </View>

      <View style={styles.spacer} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    padding: 16,
    paddingTop: 20,
    color: '#333',
  },
  summaryContainer: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    gap: 10,
    marginBottom: 20,
  },
  summaryCard: {
    flex: 1,
    borderRadius: 12,
    padding: 16,
    justifyContent: 'center',
    alignItems: 'center',
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 3,
  },
  incomeCard: {
    backgroundColor: '#4CAF50',
  },
  expenseCard: {
    backgroundColor: '#f44336',
  },
  balanceCardPositive: {
    backgroundColor: '#2196F3',
  },
  balanceCardNegative: {
    backgroundColor: '#FF9800',
  },
  summaryLabel: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
    marginBottom: 8,
  },
  summaryAmount: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  metricsSection: {
    paddingHorizontal: 12,
    marginBottom: 20,
  },
  metricCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  metricLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  metricValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2196F3',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  categorySection: {
    paddingHorizontal: 12,
    marginBottom: 20,
  },
  categoryItem: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 14,
    marginBottom: 10,
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  categoryHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  categoryName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  categoryAmount: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#f44336',
  },
  progressBarContainer: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    marginBottom: 6,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#f44336',
    borderRadius: 4,
  },
  categoryPercent: {
    fontSize: 12,
    color: '#999',
    textAlign: 'right',
  },
  trendSection: {
    paddingHorizontal: 12,
    marginBottom: 20,
  },
  trendItem: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 14,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  trendMonthLabel: {
    marginRight: 16,
  },
  trendMonth: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#333',
    minWidth: 60,
  },
  trendValues: {
    flex: 1,
    flexDirection: 'row',
    gap: 16,
  },
  trendValue: {
    flex: 1,
  },
  trendLabel: {
    fontSize: 11,
    color: '#999',
    marginBottom: 4,
  },
  trendNumber: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  incomeText: {
    color: '#4CAF50',
  },
  expenseText: {
    color: '#f44336',
  },
  insightsSection: {
    paddingHorizontal: 12,
    marginBottom: 20,
  },
  insightCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 14,
    marginBottom: 10,
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  insightText: {
    fontSize: 14,
    color: '#333',
    lineHeight: 20,
  },
  emptyText: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    paddingVertical: 20,
  },
  spacer: {
    height: 40,
  },
});
