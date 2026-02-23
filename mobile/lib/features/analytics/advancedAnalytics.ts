// Enhanced Analytics with Financial Health Score

import { SavingsGoal } from '../goals/types';

// Minimal transaction shape used by analytics helpers
export type TransactionLike = {
  id?: string;
  amount: number;
  date: string;
  category?: string;
  type: 'income' | 'expense';
  source?: string;
  timestamp?: number;
  createdAt?: string;
  updatedAt?: string;
};

export interface FinancialHealthScore {
  score: number; // 0-100
  rating: 'poor' | 'fair' | 'good' | 'excellent';
  factors: {
    incomeStability: number;
    expenseRatio: number;
    savingsRate: number;
    budgetAdherence: number;
    goalProgress: number;
  };
  recommendations: string[];
}

export interface MonthlyReport {
  month: string;
  totalIncome: number;
  totalExpense: number;
  balance: number;
  topCategories: Array<{ category: string; amount: number }>;
  averageDailySpending: number;
  weeklyTrend: Array<{ week: number; spending: number }>;
}

export type SourceFilter = 'all' | string;

export interface ChartPoint {
  x: string;
  y: number;
}

export const formatINR = (amount: number) =>
  new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(amount);

/**
 * Filter transactions by source (accepts 'all', source id or source name)
 */
export const filterTransactionsBySource = (
  transactions: TransactionLike[],
  selectedSource: SourceFilter
) => {
  if (!selectedSource || selectedSource === 'all') return transactions;
  return transactions.filter(
    (tx) => tx.source === selectedSource || String(tx.source) === String(selectedSource)
  );
};

/**
 * Return 7 numbers representing Mon..Sun expenses
 */
export const getWeeklyExpenseData = (transactions: TransactionLike[]) => {
  const weekData = Array(7).fill(0);

  transactions.forEach((tx) => {
    if (tx.type !== 'expense') return;
    const d = new Date(tx.date);
    // Map JS day (0=Sun) to index where 0 = Mon, 6 = Sun
    const dayIndex = (d.getDay() + 6) % 7;
    weekData[dayIndex] += tx.amount;
  });

  return weekData;
};

export const toVictoryChartData = (weeklyData: number[]): ChartPoint[] => {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weeklyData.map((value, idx) => ({ x: labels[idx], y: value }));
};

export const getCategoryTotals = (transactions: TransactionLike[]) => {
  const totals: Record<string, number> = {};
  transactions.forEach((tx) => {
    if (tx.type !== 'expense') return;
    const key = String(tx.category || 'other');
    totals[key] = (totals[key] || 0) + tx.amount;
  });
  return totals;
};

export const getTotalWeekly = (weeklyData: number[]) => weeklyData.reduce((a, b) => a + b, 0);

/**
 * Calculate financial health score (0-100)
 */
export const calculateFinancialHealthScore = (
  transactions: TransactionLike[],
  budgets: any[] = [],
  goals: any[] = []
): FinancialHealthScore => {
  const now = new Date();
  const currentMonth = now.toISOString().substring(0, 7);
  const last3Months = Array.from({ length: 3 }, (_, i) => {
    const d = new Date(now);
    d.setMonth(d.getMonth() - i);
    return d.toISOString().substring(0, 7);
  });

  // Income stability (consistency over last 3 months)
  const incomeByMonth = last3Months.map(month =>
    transactions
      .filter(tx => tx.date.startsWith(month) && tx.type === 'income')
      .reduce((sum, tx) => sum + tx.amount, 0)
  );
  const avgIncome = incomeByMonth.reduce((a, b) => a + b, 0) / 3;
  const incomeVariance = incomeByMonth.reduce((sum, income) => {
    const diff = income - avgIncome;
    return sum + Math.abs(diff);
  }, 0) / 3;
  const incomeStability = Math.max(0, 100 - (incomeVariance / avgIncome) * 100);

  // Expense ratio (expenses / income)
  const currentMonthIncome = transactions
    .filter(tx => tx.date.startsWith(currentMonth) && tx.type === 'income')
    .reduce((sum, tx) => sum + tx.amount, 0);
  const currentMonthExpense = transactions
    .filter(tx => tx.date.startsWith(currentMonth) && tx.type === 'expense')
    .reduce((sum, tx) => sum + tx.amount, 0);
  const expenseRatio = avgIncome > 0 ? (currentMonthExpense / avgIncome) * 100 : 0;
  const expenseRatioScore = Math.max(0, 100 - expenseRatio);

  // Savings rate
  const totalIncome = transactions
    .filter(tx => tx.type === 'income')
    .reduce((sum, tx) => sum + tx.amount, 0);
  const totalExpense = transactions
    .filter(tx => tx.type === 'expense')
    .reduce((sum, tx) => sum + tx.amount, 0);
  const savingsRate = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;
  const savingsScore = Math.min(100, Math.max(0, savingsRate * 2)); // 50% savings = 100 score

  // Budget adherence
  const currentBudgets = budgets.filter(b => b.month === currentMonth);
  let budgetAdherence = 100;
  if (currentBudgets.length > 0) {
    const exceeded = currentBudgets.filter(b => b.spent > b.limit).length;
    budgetAdherence = ((currentBudgets.length - exceeded) / currentBudgets.length) * 100;
  }

  // Goal progress
  const activeGoals = goals.filter(g => new Date(g.deadline) > now);
  let goalProgress = 100;
  if (activeGoals.length > 0) {
    const avgProgress = activeGoals.reduce((sum, g) => {
      const progress = (g.savedAmount / g.targetAmount) * 100;
      return sum + Math.min(100, progress);
    }, 0) / activeGoals.length;
    goalProgress = avgProgress;
  }

  // Calculate weighted score
  const score = (
    incomeStability * 0.15 +
    expenseRatioScore * 0.25 +
    savingsScore * 0.25 +
    budgetAdherence * 0.20 +
    goalProgress * 0.15
  );

  // Determine rating
  let rating: 'poor' | 'fair' | 'good' | 'excellent';
  if (score >= 80) rating = 'excellent';
  else if (score >= 60) rating = 'good';
  else if (score >= 40) rating = 'fair';
  else rating = 'poor';

  // Generate recommendations
  const recommendations: string[] = [];
  if (incomeStability < 50) recommendations.push('Try to stabilize your income');
  if (expenseRatio > 80) recommendations.push('Consider reducing expenses');
  if (savingsRate < 10) recommendations.push('Aim to save at least 10% of income');
  if (budgetAdherence < 80) recommendations.push('Better adhere to your budgets');
  if (goalProgress < 50 && activeGoals.length > 0) recommendations.push('Increase contributions to savings goals');

  return {
    score: Math.round(score),
    rating,
    factors: {
      incomeStability: Math.round(incomeStability),
      expenseRatio: Math.round(expenseRatioScore),
      savingsRate: Math.round(savingsScore),
      budgetAdherence: Math.round(budgetAdherence),
      goalProgress: Math.round(goalProgress),
    },
    recommendations,
  };
};

/**
 * Generate monthly report
 */
export const generateMonthlyReport = (
  transactions: TransactionLike[],
  month: string
): MonthlyReport => {
  const monthTransactions = transactions.filter(tx => tx.date.startsWith(month));

  const totalIncome = monthTransactions
    .filter(tx => tx.type === 'income')
    .reduce((sum, tx) => sum + tx.amount, 0);

  const totalExpense = monthTransactions
    .filter(tx => tx.type === 'expense')
    .reduce((sum, tx) => sum + tx.amount, 0);

  // Top categories
  const categorySpending: Record<string, number> = {};
  monthTransactions.forEach(tx => {
    if (tx.type === 'expense') {
      const key = String(tx.category || 'other');
      categorySpending[key] = (categorySpending[key] || 0) + tx.amount;
    }
  });

  const topCategories = Object.entries(categorySpending)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([category, amount]) => ({ category, amount }));

  // Weekly trend
  const weeklySpending: Record<number, number> = {};
  monthTransactions.forEach(tx => {
    if (tx.type === 'expense') {
      const date = new Date(tx.date);
      const week = Math.ceil(date.getDate() / 7);
      weeklySpending[week] = (weeklySpending[week] || 0) + tx.amount;
    }
  });

  const weeklyTrend = Object.entries(weeklySpending)
    .map(([week, spending]) => ({ week: parseInt(week), spending }))
    .sort((a, b) => a.week - b.week);

  const daysInMonth = monthTransactions.length > 0 ? 30 : 1;
  const averageDailySpending = totalExpense / daysInMonth;

  return {
    month,
    totalIncome,
    totalExpense,
    balance: totalIncome - totalExpense,
    topCategories,
    averageDailySpending,
    weeklyTrend,
  };
};

/**
 * Detect spending patterns
 */
export const detectSpendingPatterns = (transactions: TransactionLike[]): string[] => {
  const patterns: string[] = [];

  // Food spending
  const foodSpending = transactions
    .filter(tx => tx.category === 'food' && tx.type === 'expense')
    .reduce((sum, tx) => sum + tx.amount, 0);
  const avgTransaction = foodSpending / Math.max(1, transactions.filter(tx => tx.category === 'food').length);
  
  if (avgTransaction > 50) {
    patterns.push('High average food spending per transaction');
  }

  // Entertainment spending
  const entertainmentSpending = transactions
    .filter(tx => tx.category === 'entertainment' && tx.type === 'expense')
    .reduce((sum, tx) => sum + tx.amount, 0);
  
  if (entertainmentSpending > transactions.filter(tx => tx.type === 'expense').reduce((s, t) => s + t.amount, 0) * 0.2) {
    patterns.push('Entertainment spending is high (>20% of expenses)');
  }

  // Irregular shopping
  const shoppingCount = transactions.filter(tx => tx.category === 'shopping').length;
  if (shoppingCount > 10) {
    patterns.push('Frequent shopping transactions detected');
  }

  return patterns;
};
