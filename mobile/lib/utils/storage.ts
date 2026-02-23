import AsyncStorage from '@react-native-async-storage/async-storage';
import type {
  AppState,
  Transaction,
  Source,
  Budget,
  Goal,
  AppProfile,
  Category,
} from '@/lib/types/transaction';

const STORAGE_KEYS = {
  PROFILE: '@ehk_profile',
  SOURCES: '@ehk_sources',
  TRANSACTIONS: '@ehk_transactions',
  CATEGORIES: '@ehk_categories',
  BUDGETS: '@ehk_budgets',
  GOALS: '@ehk_goals',
  INITIALIZED: '@ehk_initialized',
};

// Profile
export const storage = {
  // Profile
  async getProfile(): Promise<AppProfile | null> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.PROFILE);
      return data ? JSON.parse(data) : null;
    } catch (error) {
      console.error('Error getting profile:', error);
      return null;
    }
  },

  async saveProfile(profile: AppProfile): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.PROFILE, JSON.stringify(profile));
    } catch (error) {
      console.error('Error saving profile:', error);
    }
  },

  // Sources
  async getSources(): Promise<Source[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.SOURCES);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error getting sources:', error);
      return [];
    }
  },

  async saveSources(sources: Source[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.SOURCES, JSON.stringify(sources));
    } catch (error) {
      console.error('Error saving sources:', error);
    }
  },

  async addSource(source: Source): Promise<void> {
    try {
      const sources = await this.getSources();
      sources.push(source);
      await this.saveSources(sources);
    } catch (error) {
      console.error('Error adding source:', error);
    }
  },

  // Transactions
  async getTransactions(): Promise<Transaction[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.TRANSACTIONS);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error getting transactions:', error);
      return [];
    }
  },

  async saveTransactions(transactions: Transaction[]): Promise<void> {
    try {
      await AsyncStorage.setItem(
        STORAGE_KEYS.TRANSACTIONS,
        JSON.stringify(transactions)
      );
    } catch (error) {
      console.error('Error saving transactions:', error);
    }
  },

  async addTransaction(transaction: Transaction): Promise<void> {
    try {
      const transactions = await this.getTransactions();
      transactions.push(transaction);
      await this.saveTransactions(transactions);
    } catch (error) {
      console.error('Error adding transaction:', error);
    }
  },

  // Categories
  async getCategories(): Promise<Category[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.CATEGORIES);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error getting categories:', error);
      return [];
    }
  },

  async saveCategories(categories: Category[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.CATEGORIES, JSON.stringify(categories));
    } catch (error) {
      console.error('Error saving categories:', error);
    }
  },

  async addCategory(category: Category): Promise<void> {
    try {
      const categories = await this.getCategories();
      categories.push(category);
      await this.saveCategories(categories);
    } catch (error) {
      console.error('Error adding category:', error);
    }
  },

  // Budgets
  async getBudgets(): Promise<Budget[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.BUDGETS);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error getting budgets:', error);
      return [];
    }
  },

  async saveBudgets(budgets: Budget[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.BUDGETS, JSON.stringify(budgets));
    } catch (error) {
      console.error('Error saving budgets:', error);
    }
  },

  async addBudget(budget: Budget): Promise<void> {
    try {
      const budgets = await this.getBudgets();
      budgets.push(budget);
      await this.saveBudgets(budgets);
    } catch (error) {
      console.error('Error adding budget:', error);
    }
  },

  // Goals
  async getGoals(): Promise<Goal[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.GOALS);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error getting goals:', error);
      return [];
    }
  },

  async saveGoals(goals: Goal[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.GOALS, JSON.stringify(goals));
    } catch (error) {
      console.error('Error saving goals:', error);
    }
  },

  async addGoal(goal: Goal): Promise<void> {
    try {
      const goals = await this.getGoals();
      goals.push(goal);
      await this.saveGoals(goals);
    } catch (error) {
      console.error('Error adding goal:', error);
    }
  },

  // Initialization
  async isInitialized(): Promise<boolean> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.INITIALIZED);
      return data === 'true';
    } catch (error) {
      console.error('Error checking initialization:', error);
      return false;
    }
  },

  async setInitialized(value: boolean): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.INITIALIZED, value.toString());
    } catch (error) {
      console.error('Error setting initialization:', error);
    }
  },

  // Reset all data
  async resetAll(): Promise<void> {
    try {
      await AsyncStorage.multiRemove(Object.values(STORAGE_KEYS));
    } catch (error) {
      console.error('Error resetting data:', error);
    }
  },

  // Export all data
  async exportData(): Promise<AppState> {
    try {
      const [
        profile,
        sources,
        transactions,
        categories,
        budgets,
        goals,
        initialized,
      ] = await Promise.all([
        this.getProfile(),
        this.getSources(),
        this.getTransactions(),
        this.getCategories(),
        this.getBudgets(),
        this.getGoals(),
        this.isInitialized(),
      ]);

      return {
        profile,
        sources,
        transactions,
        categories,
        budgets,
        goals,
        initialized,
      };
    } catch (error) {
      console.error('Error exporting data:', error);
      return {
        profile: null,
        sources: [],
        transactions: [],
        categories: [],
        budgets: [],
        goals: [],
        initialized: false,
      };
    }
  },

  // Import data
  async importData(data: AppState): Promise<void> {
    try {
      if (data.profile) await this.saveProfile(data.profile);
      if (data.sources) await this.saveSources(data.sources);
      if (data.transactions) await this.saveTransactions(data.transactions);
      if (data.categories) await this.saveCategories(data.categories);
      if (data.budgets) await this.saveBudgets(data.budgets);
      if (data.goals) await this.saveGoals(data.goals);
      await this.setInitialized(data.initialized);
    } catch (error) {
      console.error('Error importing data:', error);
    }
  },
};
