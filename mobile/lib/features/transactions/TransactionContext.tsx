// Enhanced Transaction Context with Recurring Support & AsyncStorage Persistence

import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Transaction, TransactionContextType, RecurrenceType } from './types';

const TransactionContext = createContext<TransactionContextType | undefined>(undefined);

interface TransactionProviderProps {
  children: ReactNode;
}

export const TransactionProvider: React.FC<TransactionProviderProps> = ({ children }) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Generate recurring transactions for given date
  const generateRecurringTransaction = useCallback((transaction: Transaction, forDate: string): Transaction => {
    return {
      ...transaction,
      id: `${transaction.id}_${forDate}`,
      date: forDate,
      lastGeneratedDate: forDate,
    };
  }, []);

  // Check and generate missing recurring transactions
  const processMissingRecurrences = useCallback((allTransactions: Transaction[]): Transaction[] => {
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    const newTransactions = [...allTransactions];

    allTransactions.forEach(tx => {
      if (!tx.isRecurring || tx.recurrenceType === 'none') return;

      const lastGen = new Date(tx.lastGeneratedDate || tx.date);
      let nextDate = new Date(lastGen);

      switch (tx.recurrenceType) {
        case 'daily':
          nextDate.setDate(nextDate.getDate() + 1);
          break;
        case 'weekly':
          nextDate.setDate(nextDate.getDate() + 7);
          break;
        case 'monthly':
          nextDate.setMonth(nextDate.getMonth() + 1);
          break;
        case 'yearly':
          nextDate.setFullYear(nextDate.getFullYear() + 1);
          break;
      }

      const nextDateStr = nextDate.toISOString().split('T')[0];

      // Check if we need to generate and if end date hasn't passed
      if (nextDateStr <= todayStr) {
        if (!tx.recurrenceEndDate || nextDateStr <= tx.recurrenceEndDate) {
          const generated = generateRecurringTransaction(tx, nextDateStr);
          newTransactions.push(generated);
        }
      }
    });

    return newTransactions;
  }, [generateRecurringTransaction]);

  // Load transactions from AsyncStorage
  const loadTransactions = useCallback(async () => {
    try {
      setIsLoading(true);
      const stored = await AsyncStorage.getItem('transactions');
      if (stored) {
        const parsed = JSON.parse(stored) as Transaction[];
        // Process missing recurring transactions
        const withRecurrences = processMissingRecurrences(parsed);
        setTransactions(withRecurrences);
        // Save updated list back
        await AsyncStorage.setItem('transactions', JSON.stringify(withRecurrences));
      }
    } catch (error) {
      console.error('Failed to load transactions:', error);
    } finally {
      setIsLoading(false);
    }
  }, [processMissingRecurrences]);

  useEffect(() => {
    loadTransactions();
  }, [loadTransactions]);

  // Save transactions to AsyncStorage
  const saveTransactions = async (txs: Transaction[]) => {
    try {
      await AsyncStorage.setItem('transactions', JSON.stringify(txs));
      setTransactions(txs);
    } catch (error) {
      console.error('Failed to save transactions:', error);
    }
  };

  const addTransaction = async (transaction: Partial<Omit<Transaction, 'id' | 'createdAt' | 'updatedAt'>>) => {
    const newTransaction: Transaction = {
      id: Date.now().toString(),
      amount: transaction.amount ?? 0,
      date: transaction.date ?? new Date().toISOString().split('T')[0],
      category: (transaction.category as any) ?? 'other',
      type: (transaction.type as any) ?? 'expense',
      note: transaction.note,
      description: transaction.description,
      source: transaction.source,
      timestamp: Date.now(),
      isRecurring: transaction.isRecurring,
      recurrenceType: transaction.recurrenceType,
      lastGeneratedDate: transaction.lastGeneratedDate,
      recurrenceEndDate: transaction.recurrenceEndDate,
      isEditable: transaction.isEditable,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    } as Transaction;
    const updated = [...transactions, newTransaction];
    await saveTransactions(updated);
  };

  const deleteTransaction = async (id: string) => {
    const updated = transactions.filter(tx => !tx.id.startsWith(id));
    await saveTransactions(updated);
  };

  const editTransaction = async (id: string, updates: Partial<Transaction>) => {
    const updated = transactions.map(tx =>
      tx.id === id || tx.id.startsWith(id + '_')
        ? { ...tx, ...updates, updatedAt: new Date().toISOString() }
        : tx
    );
    await saveTransactions(updated);
  };

  const value: TransactionContextType = {
    transactions,
    addTransaction,
    deleteTransaction,
    editTransaction,
    loadTransactions,
    isLoading,
  };

  return (
    <TransactionContext.Provider value={value}>
      {children}
    </TransactionContext.Provider>
  );
};

export const useTransactions = (): TransactionContextType => {
  const context = useContext(TransactionContext);
  if (context === undefined) {
    throw new Error('useTransactions must be used within TransactionProvider');
  }
  return context;
};

// Export context for wrapping
export { TransactionContext };
