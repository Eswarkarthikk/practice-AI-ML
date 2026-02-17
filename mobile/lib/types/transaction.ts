export type TransactionType = 'income' | 'expense';
export type Category = 'food' | 'transport' | 'entertainment' | 'shopping' | 'utilities' | 'health' | 'salary' | 'investment' | 'other';

export interface Transaction {
  id: string;
  amount: number;
  category: Category;
  type: TransactionType;
  description: string;
  date: string; // ISO format
  timestamp: number;
}

export interface CategoryColor {
  [key in Category]: string;
}
