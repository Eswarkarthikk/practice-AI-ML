// Budget utility function

import { Budget, BudgetStats } from './types';
import { Transaction } from '../transactions/types';

export const calculateBudgetUsage = (
  budgets: Budget[],
  transactions: Transaction[],
  month: string
): BudgetStats => {
  const monthBudgets = budgets.filter(b => b.month === month);
  
  // Calculate spending by category
  const spending: Record<string, number> = {
    global: 0,
  };

  transactions.forEach(tx => {
    const txMonth = tx.date.substring(0, 7); // YYYY-MM
    if (txMonth === month && tx.type === 'expense') {
      if (!spending[tx.category]) spending[tx.category] = 0;
      spending[tx.category] += tx.amount;
      spending.global += tx.amount;
    }
  });

  // Get global budget
  const globalBudget = monthBudgets.find(b => b.category === 'global');
  const totalLimit = globalBudget?.limit || 0;
  const totalSpent = spending.global;
  const percentageUsed = totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0;

  let status: 'safe' | 'warning' | 'exceeded' = 'safe';
  if (percentageUsed >= 90) status = 'exceeded';
  else if (percentageUsed >= 60) status = 'warning';

  // Category budgets
  const categoryBudgets = monthBudgets
    .filter((b): b is Budget & { category: string } => b.category !== 'global')
    .map(budget => {
      const catSpent = spending[budget.category] || 0;
      const catPercentage = (catSpent / budget.limit) * 100;
      let catStatus: 'safe' | 'warning' | 'exceeded' = 'safe';
      if (catPercentage >= 90) catStatus = 'exceeded';
      else if (catPercentage >= 60) catStatus = 'warning';

      return {
        category: budget.category,
        limit: budget.limit,
        spent: catSpent,
        percentageUsed: catPercentage,
        status: catStatus,
      };
    });

  return {
    totalLimit,
    totalSpent,
    percentageUsed,
    status,
    categoryBudgets: categoryBudgets as any,
  };
};

// Get status color based on percentage
export const getBudgetStatusColor = (percentageUsed: number): string => {
  if (percentageUsed >= 90) return '#DC2626'; // danger
  if (percentageUsed >= 60) return '#F59E0B'; // warning
  return '#16A34A'; // success
};
