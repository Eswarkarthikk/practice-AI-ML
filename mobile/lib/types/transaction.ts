// Transaction Types
export type TransactionType = 'income' | 'expense';
export type SourceType = 'Bank' | 'Cash' | 'Other';

export interface Transaction {
  id: string;
  amount: number;
  category: string;
  subcategory?: string;
  type: TransactionType;
  source: string; // ID of the source
  description: string;
  date: string; // ISO format (YYYY-MM-DD)
  timestamp: number;
  note?: string;
}

export interface Source {
  id: string;
  name: string;
  type: SourceType;
  startingAmount: number;
  createdAt: number;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  color?: string;
}

export interface Subcategory {
  id: string;
  name: string;
  categoryId: string;
}

export interface Budget {
  id: string;
  category: string;
  amount: number;
  spentAmount: number;
  period: 'weekly' | 'monthly'; // Default: monthly
  createdAt: number;
}

export interface Goal {
  id: string;
  name: string;
  targetAmount: number;
  currentAmount: number;
  deadline: string; // ISO format
  createdAt: number;
  completed: boolean;
}

export interface AppProfile {
  name: string;
  createdAt: number;
  lastUpdated: number;
}

export interface AppState {
  profile: AppProfile | null;
  sources: Source[];
  transactions: Transaction[];
  categories: Category[];
  budgets: Budget[];
  goals: Goal[];
  initialized: boolean;
}
