// Backup & Restore Utilities

import * as Sharing from 'expo-sharing';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Transaction } from '../transactions/types';
import { Budget } from '../budgets/types';
import { SavingsGoal } from '../goals/types';

export interface BackupData {
  version: string;
  timestamp: string;
  transactions: Transaction[];
  budgets: Budget[];
  goals: SavingsGoal[];
}

/**
 * Create a backup of all app data and export as JSON
 */
export const createBackup = async (): Promise<BackupData> => {
  try {
    const [transactionsData, budgetsData, goalsData] = await Promise.all([
      AsyncStorage.getItem('transactions'),
      AsyncStorage.getItem('budgets'),
      AsyncStorage.getItem('savings_goals'),
    ]);

    const backup: BackupData = {
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      transactions: transactionsData ? JSON.parse(transactionsData) : [],
      budgets: budgetsData ? JSON.parse(budgetsData) : [],
      goals: goalsData ? JSON.parse(goalsData) : [],
    };

    return backup;
  } catch (error) {
    console.error('Failed to create backup:', error);
    throw error;
  }
};

/**
 * Export backup as JSON file and share
 */
export const exportBackup = async (): Promise<void> => {
  try {
    const backup = await createBackup();
    const filename = `transaction-backup-${new Date().toISOString().split('T')[0]}.json`;
    const backupJson = JSON.stringify(backup, null, 2);

    if (await Sharing.isAvailableAsync()) {
      // For web/mobile compatibility, create a data URI and share
      const dataUri = `data:application/json;base64,${Buffer.from(backupJson).toString('base64')}`;
      await Sharing.shareAsync(dataUri, {
        mimeType: 'application/json',
        dialogTitle: 'Share Backup',
      });
    } else {
      console.warn('Sharing not available on this platform');
    }
  } catch (error) {
    console.error('Failed to export backup:', error);
    throw error;
  }
};

/**
 * Restore data from backup
 */
export const restoreBackup = async (backupData: BackupData): Promise<void> => {
  try {
    // Validate backup structure
    if (!backupData.version || !backupData.transactions) {
      throw new Error('Invalid backup file');
    }

    // Restore all data
    await Promise.all([
      AsyncStorage.setItem('transactions', JSON.stringify(backupData.transactions)),
      AsyncStorage.setItem('budgets', JSON.stringify(backupData.budgets || [])),
      AsyncStorage.setItem('savings_goals', JSON.stringify(backupData.goals || [])),
    ]);
  } catch (error) {
    console.error('Failed to restore backup:', error);
    throw error;
  }
};

/**
 * Export transactions as CSV for spreadsheet use
 */
export const exportToCSV = async (transactions: Transaction[]): Promise<void> => {
  try {
    const headers = ['Date', 'Category', 'Type', 'Amount', 'Note'];
    const rows = transactions.map(tx => [
      tx.date,
      tx.category,
      tx.type,
      tx.amount.toString(),
      tx.note || '',
    ]);

    const csv = [headers, ...rows].map(row => row.join(',')).join('\n');
    const filename = `transactions-${new Date().toISOString().split('T')[0]}.csv`;

    if (await Sharing.isAvailableAsync()) {
      // For web/mobile compatibility, create a data URI and share
      const dataUri = `data:text/csv;base64,${Buffer.from(csv).toString('base64')}`;
      await Sharing.shareAsync(dataUri, {
        mimeType: 'text/csv',
        dialogTitle: 'Export Transactions',
      });
    } else {
      console.warn('Sharing not available on this platform');
    }
  } catch (error) {
    console.error('Failed to export CSV:', error);
    throw error;
  }
};
