import React, { useMemo, useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '@/components/shared/Screen';
import { Card } from '@/components/shared/CardComponent';
import { useApp } from '@/lib/context/AppContext';
import { formatCurrency, isThisMonth } from '@/lib/utils/helpers';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS, SHADOWS } from '@/lib/theme';
import {
  filterTransactionsBySource,
  getWeeklyExpenseData,
  toVictoryChartData,
  getCategoryTotals as getCategoryTotalsHelper,
  getTotalWeekly,
  formatINR,
} from '@/lib/features/analytics/advancedAnalytics';
import {
  VictoryChart,
  VictoryArea,
  VictoryAxis,
  VictoryTooltip,
  VictoryVoronoiContainer,
  VictoryLine,
} from 'victory-native';
import { Defs, LinearGradient, Stop } from 'react-native-svg';

type Period = 'week' | 'month' | 'year';

export default function AnalyticsScreen() {
  const router = useRouter();
  const { transactions } = useApp();
  const [period, setPeriod] = useState<Period>('week');
  const [selectedSource, setSelectedSource] = useState<'all' | string>('all');
  const [selectedDay, setSelectedDay] = useState<string | null>(null);

  // Filter transactions by source and expense type
  const filteredTransactions = useMemo(() => {
    const bySource = filterTransactionsBySource(transactions, selectedSource);
    return bySource.filter((t) => t.type === 'expense');
  }, [transactions, selectedSource]);

  // Weekly data for chart (Mon..Sun)
  const weeklyData = useMemo(() => getWeeklyExpenseData(filteredTransactions), [filteredTransactions]);

  // Category breakdown
  const categoryTotals = useMemo(() => getCategoryTotalsHelper(filteredTransactions), [filteredTransactions]);

  // Monthly statistics
  const monthlyTransactions = transactions.filter((t) => isThisMonth(t.date));

  const totalExpense = useMemo(() => monthlyTransactions.reduce((sum, t) => sum + t.amount, 0), [monthlyTransactions]);

  const avgDaily = useMemo(() => {
    const daysInMonth = new Date(
      new Date().getFullYear(),
      new Date().getMonth() + 1,
      0
    ).getDate();
    return totalExpense / daysInMonth;
  }, [totalExpense]);

  const top3Categories = useMemo(
    () =>
      Object.entries(categoryTotals)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 3),
    [categoryTotals]
  );

  const victoryData = useMemo(() => toVictoryChartData(weeklyData), [weeklyData]);
  const totalWeekly = useMemo(() => getTotalWeekly(weeklyData), [weeklyData]);
  const maxY = Math.max(...weeklyData, 10);

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
          <Text style={styles.title}>Analytics</Text>
          <View style={{ width: 28 }} />
        </View>

        {/* Period Selector */}
        <View style={styles.periodSelector}>
          {(['week', 'month', 'year'] as const).map((p) => (
            <TouchableOpacity
              key={p}
              onPress={() => setPeriod(p)}
              style={[
                styles.periodButton,
                period === p && styles.periodButtonActive,
              ]}
            >
              <Text
                style={[
                  styles.periodButtonText,
                  period === p && styles.periodButtonTextActive,
                ]}
              >
                {p.charAt(0).toUpperCase() + p.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Weekly Chart */}
        <Card style={{ ...styles.chartCard, ...SHADOWS.soft }}>
          <Text style={styles.chartTitle}>Spending Trend</Text>
          <VictoryChart
            height={260}
            width={Dimensions.get('window').width - SPACING.xl}
            padding={{ top: 20, bottom: 40, left: 40, right: 40 }}
            containerComponent={
              <VictoryVoronoiContainer
                labels={({ datum }) => formatINR(datum.y)}
                onActivated={(points) => setSelectedDay(points && points[0] ? String(points[0].x) : null)}
                labelComponent={
                  <VictoryTooltip
                    flyoutStyle={{ fill: COLORS.purpleMain }}
                    style={{ fill: '#fff' }}
                  />
                }
              />
            }
          >
            <Defs>
              <LinearGradient id="gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <Stop offset="0%" stopColor="#1E90FF" stopOpacity={0.5} />
                <Stop offset="100%" stopColor="#1E90FF" stopOpacity={0} />
              </LinearGradient>
            </Defs>

            <VictoryAxis
              style={{ axis: { stroke: 'transparent' }, tickLabels: { fill: '#8A8FA3', fontSize: 12 } }}
            />

            <VictoryAxis
              dependentAxis
              orientation="right"
              tickFormat={(x) => `₹${x}`}
              style={{ axis: { stroke: 'transparent' }, tickLabels: { fill: '#8A8FA3', fontSize: 12 } }}
            />

            <VictoryArea
              data={victoryData}
              interpolation="natural"
              style={{ data: { fill: 'url(#gradient)', stroke: '#1E90FF', strokeWidth: 3 } }}
            />

            {selectedDay && (
              <VictoryLine
                style={{ data: { stroke: '#1E90FF', strokeDasharray: '5,5' } }}
                data={[{ x: selectedDay, y: 0 }, { x: selectedDay, y: maxY }]}
              />
            )}
          </VictoryChart>
        </Card>

        {/* Statistics Cards */}
        <View style={styles.statsRound}>
          <StatCard label="Total Expense" value={formatCurrency(totalExpense)} />
          <StatCard label="Daily Average" value={formatCurrency(avgDaily)} />
        </View>

        {/* Top Categories */}
        {top3Categories.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Top Categories</Text>
            {top3Categories.map(([category, amount], index) => (
              <Card key={category} style={styles.categoryCard}>
                <View style={styles.categoryRow}>
                  <View style={styles.categoryLeft}>
                    <View style={styles.categoryNumber}>
                      <Text style={styles.categoryNumberText}>{index + 1}</Text>
                    </View>
                    <Text style={styles.categoryName}>{category}</Text>
                  </View>
                  <Text style={styles.categoryAmount}>
                    {formatCurrency(amount as number)}
                  </Text>
                </View>
              </Card>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}

interface StatCardProps {
  label: string;
  value: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, value }) => {
  return (
    <Card style={styles.statCard}>
      <Text style={styles.statLabel}>{label}</Text>
      <Text style={styles.statValue}>{value}</Text>
    </Card>
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
  periodSelector: {
    flexDirection: 'row',
    gap: SPACING.md,
    marginBottom: SPACING.lg,
  },
  periodButton: {
    flex: 1,
    paddingVertical: SPACING.md,
    borderRadius: BORDER_RADIUS.medium,
    borderWidth: 1,
    borderColor: COLORS.borderColor,
    justifyContent: 'center',
    alignItems: 'center',
  },
  periodButtonActive: {
    backgroundColor: COLORS.purpleMain,
    borderColor: COLORS.purpleMain,
  },
  periodButtonText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textSecondary,
    fontWeight: '600',
  },
  periodButtonTextActive: {
    color: COLORS.cardBg,
  },
  chartCard: {
    padding: SPACING.lg,
    marginBottom: SPACING.lg,
  },
  chartTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
  },
  statsRound: {
    flexDirection: 'row',
    gap: SPACING.md,
    marginBottom: SPACING.lg,
  },
  statCard: {
    flex: 1,
    padding: SPACING.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginBottom: SPACING.sm,
  },
  statValue: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.purpleMain,
    fontSize: 20,
  },
  section: {
    marginBottom: SPACING.lg,
  },
  sectionTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
  },
  categoryCard: {
    padding: SPACING.md,
    marginBottom: SPACING.md,
  },
  categoryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  categoryLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  categoryNumber: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: COLORS.purpleMain,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  categoryNumberText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.cardBg,
    fontWeight: '700',
  },
  categoryName: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
  },
  categoryAmount: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.dangerRed,
    fontWeight: '700',
  },
});
