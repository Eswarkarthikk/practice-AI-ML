/**
 * Utility functions for EHK Finance Tracker
 */

export const generateId = () => {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

export const formatCurrency = (amount: number): string => {
  return `$${amount.toFixed(2)}`;
};

export const formatDate = (dateString: string): string => {
  const date = new Date(dateString);
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  if (date.toDateString() === today.toDateString()) {
    return 'Today';
  }
  if (date.toDateString() === yesterday.toDateString()) {
    return 'Yesterday';
  }

  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  });
};

export const formatDateFull = (dateString: string): string => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

export const getWeekStartDate = (): Date => {
  const today = new Date();
  const day = today.getDay();
  const diff = today.getDate() - day;
  return new Date(today.setDate(diff));
};

export const getMonthStartDate = (): Date => {
  const today = new Date();
  return new Date(today.getFullYear(), today.getMonth(), 1);
};

export const isSameDay = (date1: string, date2: string): boolean => {
  return new Date(date1).toDateString() === new Date(date2).toDateString();
};

export const isThisWeek = (dateString: string): boolean => {
  const date = new Date(dateString);
  const weekStart = getWeekStartDate();
  const weekEnd = new Date(weekStart);
  weekEnd.setDate(weekEnd.getDate() + 7);
  return date >= weekStart && date < weekEnd;
};

export const isThisMonth = (dateString: string): boolean => {
  const date = new Date(dateString);
  const today = new Date();
  return (
    date.getMonth() === today.getMonth() &&
    date.getFullYear() === today.getFullYear()
  );
};

export const calculateBalance = (
  startingAmount: number,
  transactions: Array<{ type: 'income' | 'expense'; amount: number; source: string }>
): number => {
  let balance = startingAmount;
  transactions.forEach((transaction) => {
    if (transaction.type === 'income') {
      balance += transaction.amount;
    } else {
      balance -= transaction.amount;
    }
  });
  return balance;
};

export const groupTransactionsByDate = (
  transactions: Array<{ date: string; [key: string]: any }>
) => {
  const grouped: { [key: string]: any[] } = {};
  transactions.forEach((transaction) => {
    const date = transaction.date;
    if (!grouped[date]) {
      grouped[date] = [];
    }
    grouped[date].push(transaction);
  });
  return grouped;
};

export const getWeeklyData = (
  transactions: Array<{ date: string; amount: number; type: 'income' | 'expense' }>
) => {
  const weekStart = getWeekStartDate();
  const weekEnd = new Date(weekStart);
  weekEnd.setDate(weekEnd.getDate() + 7);

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const data: { [key: string]: number } = {};

  days.forEach((_, index) => {
    const date = new Date(weekStart);
    date.setDate(date.getDate() + index);
    data[days[index]] = 0;
  });

  transactions.forEach((transaction) => {
    const date = new Date(transaction.date);
    if (date >= weekStart && date < weekEnd) {
      const dayIndex = date.getDay() === 0 ? 6 : date.getDay() - 1;
      const day = days[dayIndex];
      if (transaction.type === 'expense') {
        data[day] += transaction.amount;
      }
    }
  });

  return data;
};

export const getCategoryTotals = (
  transactions: Array<{ category: string; amount: number; type: 'income' | 'expense' }>
) => {
  const totals: { [key: string]: number } = {};
  transactions.forEach((transaction) => {
    if (!totals[transaction.category]) {
      totals[transaction.category] = 0;
    }
    if (transaction.type === 'expense') {
      totals[transaction.category] += transaction.amount;
    }
  });
  return totals;
};

export const getDefaultCategories = () => {
  return [
    { id: 'food', name: 'Food', icon: '🍔', color: '#FF6B6B' },
    { id: 'transport', name: 'Transport', icon: '🚗', color: '#4ECDC4' },
    { id: 'entertainment', name: 'Entertainment', icon: '🎬', color: '#FFD93D' },
    { id: 'shopping', name: 'Shopping', icon: '🛍️', color: '#FF8BB1' },
    { id: 'bills', name: 'Bills', icon: '📄', color: '#6C63FF' },
    { id: 'health', name: 'Health', icon: '🏥', color: '#2ECC71' },
    { id: 'other', name: 'Other', icon: '📦', color: '#95A5A6' },
  ];
};
