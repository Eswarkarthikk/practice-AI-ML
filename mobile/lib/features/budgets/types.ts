// Budget System Types

import { Category } from '../transactions/types';

export interface Budget {
  id: string;
  category: Category | 'global'; // 'global' for monthly budget
  limit: number;
  spent: number;
  period: 'monthly'; // Can extend to weekly, yearly later
  month: string; // YYYY-MM format
  createdAt: string;
  updatedAt: string;
}

export interface BudgetStats {
  totalLimit: number;
  totalSpent: number;
  percentageUsed: number; // 0-100
  status: 'safe' | 'warning' | 'exceeded'; // safe: 0-60%, warning: 60-90%, exceeded: 90%+
  categoryBudgets: Array<{
    category: Category;
    limit: number;
    spent: number;
    percentageUsed: number;
    status: 'safe' | 'warning' | 'exceeded';
  }>;
}

export interface BudgetContextType {
  budgets: Budget[];
  addBudget: (budget: Omit<Budget, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateBudget: (id: string, updates: Partial<Budget>) => Promise<void>;
  deleteBudget: (id: string) => Promise<void>;
  getBudgetStats: (month: string) => BudgetStats;
  isLoading: boolean;
}
