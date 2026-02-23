// Budget Context & State Management

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Budget, BudgetStats, BudgetContextType } from './types';
import { Category, Transaction } from '../transactions/types';

const BudgetContext = createContext<BudgetContextType | undefined>(undefined);

interface BudgetProviderProps {
  children: ReactNode;
  transactions: Transaction[];
}

export const BudgetProvider: React.FC<BudgetProviderProps> = ({ children, transactions }) => {
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Load budgets from AsyncStorage
  const loadBudgets = async () => {
    try {
      setIsLoading(true);
      const stored = await AsyncStorage.getItem('budgets');
      if (stored) {
        setBudgets(JSON.parse(stored));
      }
    } catch (error) {
      console.error('Failed to load budgets:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadBudgets();
  }, []);

  // Save budgets to AsyncStorage
  const saveBudgets = async (budgets: Budget[]) => {
    try {
      await AsyncStorage.setItem('budgets', JSON.stringify(budgets));
      setBudgets(budgets);
    } catch (error) {
      console.error('Failed to save budgets:', error);
    }
  };

  const addBudget = async (budget: Omit<Budget, 'id' | 'createdAt' | 'updatedAt'>) => {
    const newBudget: Budget = {
      ...budget,
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await saveBudgets([...budgets, newBudget]);
  };

  const updateBudget = async (id: string, updates: Partial<Budget>) => {
    const updated = budgets.map(b =>
      b.id === id
        ? { ...b, ...updates, updatedAt: new Date().toISOString() }
        : b
    );
    await saveBudgets(updated);
  };

  const deleteBudget = async (id: string) => {
    await saveBudgets(budgets.filter(b => b.id !== id));
  };

  // Calculate budget usage statistics
  const getBudgetStats = (month: string): BudgetStats => {
    // Get active budgets for this month
    const monthBudgets = budgets.filter(b => b.month === month);
    
    // Calculate spending by category
    const spending: Record<Category | 'global', number> = {
      global: 0,
      salary: 0,
      food: 0,
      transport: 0,
      entertainment: 0,
      utilities: 0,
      healthcare: 0,
      shopping: 0,
      other: 0,
    };

    transactions.forEach(tx => {
      const [year, mon] = tx.date.split('-').slice(0, 2).join('-').split('-');
      const txMonth = `${year}-${mon}`;
      
      if (txMonth === month && tx.type === 'expense') {
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
      .filter(b => b.category !== 'global')
      .map(budget => {
        const catSpent = spending[budget.category as Category] || 0;
        const catPercentage = (catSpent / budget.limit) * 100;
        let catStatus: 'safe' | 'warning' | 'exceeded' = 'safe';
        if (catPercentage >= 90) catStatus = 'exceeded';
        else if (catPercentage >= 60) catStatus = 'warning';

        return {
          category: budget.category as Category,
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
      categoryBudgets,
    };
  };

  const value: BudgetContextType = {
    budgets,
    addBudget,
    updateBudget,
    deleteBudget,
    getBudgetStats,
    isLoading,
  };

  return (
    <BudgetContext.Provider value={value}>
      {children}
    </BudgetContext.Provider>
  );
};

export const useBudget = (): BudgetContextType => {
  const context = useContext(BudgetContext);
  if (context === undefined) {
    throw new Error('useBudget must be used within BudgetProvider');
  }
  return context;
};
