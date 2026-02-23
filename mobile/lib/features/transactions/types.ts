// Enhanced Transaction Types with Recurring Support

export type TransactionType = 'income' | 'expense';
export type Category = 'salary' | 'food' | 'transport' | 'entertainment' | 'utilities' | 'healthcare' | 'shopping' | 'other';
export type RecurrenceType = 'daily' | 'weekly' | 'monthly' | 'yearly' | 'none';

export interface Transaction {
  id: string;
  amount: number;
  date: string; // ISO format: YYYY-MM-DD
  category: Category;
  type: TransactionType;
  note?: string;
  description?: string; // Alias for note
  source?: string;
  subcategory?: string;
  timestamp?: number;
  
  // Recurring transaction fields
  isRecurring?: boolean;
  recurrenceType?: RecurrenceType;
  lastGeneratedDate?: string;
  recurrenceEndDate?: string; // Optional: when to stop recurring
  
  // Editable transaction
  isEditable?: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface TransactionContextType {
  transactions: Transaction[];
  addTransaction: (transaction: Partial<Omit<Transaction, 'id' | 'createdAt' | 'updatedAt'>>) => Promise<void>;
  deleteTransaction: (id: string) => Promise<void>;
  editTransaction: (id: string, updates: Partial<Transaction>) => Promise<void>;
  loadTransactions: () => Promise<void>;
  isLoading: boolean;
  subcategories?: any[];
  addSubcategory?: (name: string, category: string) => Promise<void>;
}

// Statistics types
export interface TransactionStats {
  totalIncome: number;
  totalExpense: number;
  balance: number;
  categoryBreakdown: Record<Category, number>;
  dailyAverage: number;
  monthlyTrend: { month: string; income: number; expense: number }[];
}
