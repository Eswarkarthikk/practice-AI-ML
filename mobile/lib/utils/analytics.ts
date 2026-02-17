import { Transaction, Category } from '../types/transaction';

export interface Analytics {
  totalIncome: number;
  totalExpense: number;
  balance: number;
  categoryBreakdown: Record<Category, number>;
  dailyAverage: number;
  highestSpendingCategory: Category | null;
  transactionCount: number;
  monthlyTrend: { month: string; expense: number; income: number }[];
}

export const calculateAnalytics = (transactions: Transaction[]): Analytics => {
  if (transactions.length === 0) {
    return {
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      categoryBreakdown: {} as Record<Category, number>,
      dailyAverage: 0,
      highestSpendingCategory: null,
      transactionCount: 0,
      monthlyTrend: [],
    };
  }

  const totalIncome = transactions
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpense = transactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const categoryBreakdown = transactions
    .filter(t => t.type === 'expense')
    .reduce((acc, t) => {
      acc[t.category] = (acc[t.category] || 0) + t.amount;
      return acc;
    }, {} as Record<Category, number>);

  const highestSpendingCategory = Object.entries(categoryBreakdown)
    .sort(([, a], [, b]) => b - a)[0]?.[0] as Category | null;

  // Calculate daily average
  const daysSpan = transactions.length > 0
    ? (Date.now() - Math.min(...transactions.map(t => t.timestamp))) / (1000 * 60 * 60 * 24)
    : 1;

  const dailyAverage = totalExpense / Math.max(daysSpan, 1);

  // Monthly trend
  const monthlyData: Record<string, { expense: number; income: number }> = {};
  transactions.forEach(t => {
    const date = new Date(t.date);
    const month = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
    if (!monthlyData[month]) {
      monthlyData[month] = { expense: 0, income: 0 };
    }
    if (t.type === 'income') {
      monthlyData[month].income += t.amount;
    } else {
      monthlyData[month].expense += t.amount;
    }
  });

  const monthlyTrend = Object.entries(monthlyData)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([month, data]) => ({ month, ...data }));

  return {
    totalIncome,
    totalExpense,
    balance: totalIncome - totalExpense,
    categoryBreakdown,
    dailyAverage,
    highestSpendingCategory,
    transactionCount: transactions.length,
    monthlyTrend,
  };
};

export const generateAIInsights = (analytics: Analytics, transactions: Transaction[]): string[] => {
  const insights: string[] = [];

  if (analytics.balance > 0) {
    insights.push(`💰 Great job! You have a positive balance of ₹${analytics.balance.toFixed(2)}`);
  } else if (analytics.balance < 0) {
    insights.push(`⚠️ You're in deficit by ₹${Math.abs(analytics.balance).toFixed(2)}`);
  }

  if (analytics.highestSpendingCategory) {
    insights.push(`📊 Your highest spending category is ${analytics.highestSpendingCategory} (₹${analytics.categoryBreakdown[analytics.highestSpendingCategory].toFixed(2)})`);
  }

  if (analytics.dailyAverage > 0) {
    insights.push(`📈 Your daily average spending is ₹${analytics.dailyAverage.toFixed(2)}`);
  }

  const lastWeekTransactions = transactions.filter(
    t => Date.now() - t.timestamp < 7 * 24 * 60 * 60 * 1000
  );

  if (lastWeekTransactions.length > 5) {
    insights.push(`🔥 You made ${lastWeekTransactions.length} transactions this week!`);
  }

  if (analytics.categoryBreakdown['food'] && analytics.categoryBreakdown['food'] > analytics.totalExpense * 0.3) {
    insights.push(`🍔 Food spending is high! Consider meal planning to save money.`);
  }

  return insights;
};
