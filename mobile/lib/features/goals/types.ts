// Savings Goals Types

export interface SavingsGoal {
  id: string;
  title: string;
  description?: string;
  targetAmount: number;
  savedAmount: number;
  deadline: string; // ISO format: YYYY-MM-DD
  category?: string;
  color?: string; // HEX color for UI
  createdAt: string;
  updatedAt: string;
}

export interface GoalStats {
  goal: SavingsGoal;
  percentageComplete: number; // 0-100
  remainingAmount: number;
  remainingDays: number;
  requiredMonthlySaving: number;
  onTrack: boolean;
  estimatedCompletionDate: string;
}

export interface GoalContextType {
  goals: SavingsGoal[];
  addGoal: (goal: Omit<SavingsGoal, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateGoal: (id: string, updates: Partial<SavingsGoal>) => Promise<void>;
  deleteGoal: (id: string) => Promise<void>;
  contributeToGoal: (id: string, amount: number) => Promise<void>;
  getGoalStats: (id: string) => GoalStats | null;
  isLoading: boolean;
  calculateRequiredMonthly?: (goal: SavingsGoal) => number;
}

