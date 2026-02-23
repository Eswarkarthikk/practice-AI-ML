// Goals Context & State Management

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { SavingsGoal, GoalStats, GoalContextType } from './types';

const GoalContext = createContext<GoalContextType | undefined>(undefined);

interface GoalProviderProps {
  children: ReactNode;
}

export const GoalProvider: React.FC<GoalProviderProps> = ({ children }) => {
  const [goals, setGoals] = useState<SavingsGoal[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadGoals = async () => {
    try {
      setIsLoading(true);
      const stored = await AsyncStorage.getItem('savings_goals');
      if (stored) {
        setGoals(JSON.parse(stored));
      }
    } catch (error) {
      console.error('Failed to load goals:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadGoals();
  }, []);

  const saveGoals = async (goals: SavingsGoal[]) => {
    try {
      await AsyncStorage.setItem('savings_goals', JSON.stringify(goals));
      setGoals(goals);
    } catch (error) {
      console.error('Failed to save goals:', error);
    }
  };

  const addGoal = async (goal: Omit<SavingsGoal, 'id' | 'createdAt' | 'updatedAt'>) => {
    const newGoal: SavingsGoal = {
      ...goal,
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await saveGoals([...goals, newGoal]);
  };

  const updateGoal = async (id: string, updates: Partial<SavingsGoal>) => {
    const updated = goals.map(g =>
      g.id === id
        ? { ...g, ...updates, updatedAt: new Date().toISOString() }
        : g
    );
    await saveGoals(updated);
  };

  const deleteGoal = async (id: string) => {
    await saveGoals(goals.filter(g => g.id !== id));
  };

  const contributeToGoal = async (id: string, amount: number) => {
    const updated = goals.map(g =>
      g.id === id
        ? { ...g, savedAmount: g.savedAmount + amount, updatedAt: new Date().toISOString() }
        : g
    );
    await saveGoals(updated);
  };

  const getGoalStats = (id: string): GoalStats | null => {
    const goal = goals.find(g => g.id === id);
    if (!goal) return null;

    const today = new Date();
    const deadline = new Date(goal.deadline);
    const remainingDays = Math.ceil((deadline.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    const remainingAmount = Math.max(0, goal.targetAmount - goal.savedAmount);
    const remainingMonths = Math.max(1, Math.ceil(remainingDays / 30));
    const requiredMonthlySaving = remainingAmount / remainingMonths;
    const percentageComplete = (goal.savedAmount / goal.targetAmount) * 100;

    // Estimate completion based on required monthly saving
    const monthsNeeded = remainingAmount > 0 ? remainingAmount / (goal.savedAmount / (Math.max(1, Math.floor((today.getTime() - new Date(goal.createdAt).getTime()) / (1000 * 60 * 60 * 24))) / 30)) : 0;
    const estimatedCompletionDate = new Date(today.getTime() + monthsNeeded * 30 * 24 * 60 * 60 * 1000).toISOString();

    return {
      goal,
      percentageComplete: Math.min(100, percentageComplete),
      remainingAmount,
      remainingDays: Math.max(0, remainingDays),
      requiredMonthlySaving: Math.max(0, requiredMonthlySaving),
      onTrack: remainingAmount <= requiredMonthlySaving,
      estimatedCompletionDate,
    };
  };

  const value: GoalContextType = {
    goals,
    addGoal,
    updateGoal,
    deleteGoal,
    contributeToGoal,
    getGoalStats,
    isLoading,
  };

  return (
    <GoalContext.Provider value={value}>
      {children}
    </GoalContext.Provider>
  );
};

export const useGoals = (): GoalContextType => {
  const context = useContext(GoalContext);
  if (context === undefined) {
    throw new Error('useGoals must be used within GoalProvider');
  }
  return context;
};
