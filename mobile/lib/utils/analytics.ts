import { Transaction } from '../types/transaction';

export interface Analytics {
  totalIncome: number;
  totalExpense: number;
  balance: number;
  // keys are category ids/names
  categoryBreakdown: Record<string, number>;
  dailyAverage: number;
  highestSpendingCategory: string | null;
  transactionCount: number;
  monthlyTrend: { month: string; expense: number; income: number }[];
}

export const calculateAnalytics = (transactions: Transaction[]): Analytics => {
  if (transactions.length === 0) {
    return {
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      categoryBreakdown: {} as Record<string, number>,
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
      const key = String(t.category);
      acc[key] = (acc[key] || 0) + t.amount;
      return acc;
    }, {} as Record<string, number>);

  const highestSpendingCategory = Object.entries(categoryBreakdown)
    .sort(([, a], [, b]) => b - a)[0]?.[0] || null;

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
    const cat = analytics.highestSpendingCategory;
    insights.push(`📊 Your highest spending category is ${cat} (₹${(analytics.categoryBreakdown[cat] || 0).toFixed(2)})`);
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

  if ((analytics.categoryBreakdown['food'] || 0) > analytics.totalExpense * 0.3) {
    insights.push(`🍔 Food spending is high! Consider meal planning to save money.`);
  }

  return insights;
};
