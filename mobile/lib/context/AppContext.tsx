import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import {
  AppProfile,
  Source,
  Transaction,
  Category,
  Budget,
  Goal,
} from '@/lib/types/transaction';
import { storage } from '@/lib/utils/storage';
import { generateId, getDefaultCategories } from '@/lib/utils/helpers';

interface AppContextType {
  // State
  profile: AppProfile | null;
  sources: Source[];
  transactions: Transaction[];
  categories: Category[];
  budgets: Budget[];
  goals: Goal[];
  loading: boolean;

  // Profile
  setProfile: (profile: AppProfile) => Promise<void>;

  // Sources
  addSource: (name: string, type: 'Bank' | 'Cash' | 'Other', startingAmount: number) => Promise<string>;
  removeSource: (id: string) => Promise<void>;

  // Transactions
  addTransaction: (transaction: Omit<Transaction, 'id' | 'timestamp'>) => Promise<void>;
  removeTransaction: (id: string) => Promise<void>;
  updateTransaction: (id: string, transaction: Partial<Transaction>) => Promise<void>;

  // Categories
  addCategory: (name: string, icon: string) => Promise<void>;
  removeCategory: (id: string) => Promise<void>;

  // Budgets
  addBudget: (category: string, amount: number) => Promise<void>;
  removeBudget: (id: string) => Promise<void>;
  updateBudget: (id: string, budget: Partial<Budget>) => Promise<void>;

  // Goals
  addGoal: (name: string, targetAmount: number, deadline: string) => Promise<void>;
  removeGoal: (id: string) => Promise<void>;
  updateGoal: (id: string, goal: Partial<Goal>) => Promise<void>;

  // Data management
  resetAllData: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [profile, setProfileState] = useState<AppProfile | null>(null);
  const [sources, setSourcesState] = useState<Source[]>([]);
  const [transactions, setTransactionsState] = useState<Transaction[]>([]);
  const [categories, setCategoriesState] = useState<Category[]>([]);
  const [budgets, setBudgetsState] = useState<Budget[]>([]);
  const [goals, setGoalsState] = useState<Goal[]>([]);
  const [loading, setLoading] = useState(true);

  // Initialize
  useEffect(() => {
    const initializeApp = async () => {
      try {
        const [savedProfile, savedSources, savedTransactions, savedCategories, savedBudgets, savedGoals] =
          await Promise.all([
            storage.getProfile(),
            storage.getSources(),
            storage.getTransactions(),
            storage.getCategories(),
            storage.getBudgets(),
            storage.getGoals(),
          ]);

        setProfileState(savedProfile);
        setSourcesState(savedSources);
        setTransactionsState(savedTransactions);
        setCategoriesState(
          savedCategories.length > 0 ? savedCategories : getDefaultCategories()
        );
        setBudgetsState(savedBudgets);
        setGoalsState(savedGoals);

        if (savedCategories.length === 0) {
          await storage.saveCategories(getDefaultCategories());
        }
      } catch (error) {
        console.error('Error initializing app:', error);
      } finally {
        setLoading(false);
      }
    };

    initializeApp();
  }, []);

  // Profile
  const setProfile = async (newProfile: AppProfile) => {
    setProfileState(newProfile);
    await storage.saveProfile(newProfile);
  };

  // Sources
  const addSource = async (
    name: string,
    type: 'Bank' | 'Cash' | 'Other',
    startingAmount: number
  ) => {
    const newSource: Source = {
      id: generateId(),
      name,
      type,
      startingAmount,
      createdAt: Date.now(),
    };
    const updated = [...sources, newSource];
    setSourcesState(updated);
    await storage.saveSources(updated);
    return newSource.id;
  };

  const removeSource = async (id: string) => {
    const updated = sources.filter((s) => s.id !== id);
    setSourcesState(updated);
    await storage.saveSources(updated);
  };

  // Transactions
  const addTransaction = async (
    transaction: Omit<Transaction, 'id' | 'timestamp'>
  ) => {
    const newTransaction: Transaction = {
      ...transaction,
      id: generateId(),
      timestamp: Date.now(),
    };
    const updated = [...transactions, newTransaction];
    setTransactionsState(updated);
    await storage.saveTransactions(updated);
  };

  const removeTransaction = async (id: string) => {
    const updated = transactions.filter((t) => t.id !== id);
    setTransactionsState(updated);
    await storage.saveTransactions(updated);
  };

  const updateTransaction = async (
    id: string,
    transaction: Partial<Transaction>
  ) => {
    const updated = transactions.map((t) =>
      t.id === id ? { ...t, ...transaction } : t
    );
    setTransactionsState(updated);
    await storage.saveTransactions(updated);
  };

  // Categories
  const addCategory = async (name: string, icon: string) => {
    const newCategory: Category = {
      id: generateId(),
      name,
      icon,
    };
    const updated = [...categories, newCategory];
    setCategoriesState(updated);
    await storage.saveCategories(updated);
  };

  const removeCategory = async (id: string) => {
    const updated = categories.filter((c) => c.id !== id);
    setCategoriesState(updated);
    await storage.saveCategories(updated);
  };

  // Budgets
  const addBudget = async (category: string, amount: number) => {
    const newBudget: Budget = {
      id: generateId(),
      category,
      amount,
      spentAmount: 0,
      period: 'monthly',
      createdAt: Date.now(),
    };
    const updated = [...budgets, newBudget];
    setBudgetsState(updated);
    await storage.saveBudgets(updated);
  };

  const removeBudget = async (id: string) => {
    const updated = budgets.filter((b) => b.id !== id);
    setBudgetsState(updated);
    await storage.saveBudgets(updated);
  };

  const updateBudget = async (id: string, budget: Partial<Budget>) => {
    const updated = budgets.map((b) =>
      b.id === id ? { ...b, ...budget } : b
    );
    setBudgetsState(updated);
    await storage.saveBudgets(updated);
  };

  // Goals
  const addGoal = async (name: string, targetAmount: number, deadline: string) => {
    const newGoal: Goal = {
      id: generateId(),
      name,
      targetAmount,
      currentAmount: 0,
      deadline,
      createdAt: Date.now(),
      completed: false,
    };
    const updated = [...goals, newGoal];
    setGoalsState(updated);
    await storage.saveGoals(updated);
  };

  const removeGoal = async (id: string) => {
    const updated = goals.filter((g) => g.id !== id);
    setGoalsState(updated);
    await storage.saveGoals(updated);
  };

  const updateGoal = async (id: string, goal: Partial<Goal>) => {
    const updated = goals.map((g) =>
      g.id === id ? { ...g, ...goal } : g
    );
    setGoalsState(updated);
    await storage.saveGoals(updated);
  };

  // Reset all data
  const resetAllData = async () => {
    setProfileState(null);
    setSourcesState([]);
    setTransactionsState([]);
    setCategoriesState(getDefaultCategories());
    setBudgetsState([]);
    setGoalsState([]);
    await storage.resetAll();
    await storage.saveCategories(getDefaultCategories());
  };

  const value: AppContextType = {
    profile,
    sources,
    transactions,
    categories,
    budgets,
    goals,
    loading,
    setProfile,
    addSource,
    removeSource,
    addTransaction,
    removeTransaction,
    updateTransaction,
    addCategory,
    removeCategory,
    addBudget,
    removeBudget,
    updateBudget,
    addGoal,
    removeGoal,
    updateGoal,
    resetAllData,
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};
