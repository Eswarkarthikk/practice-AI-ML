# 👨‍💻 Developer Guide - Transaction Tracker App

This guide helps you understand and modify the app's codebase.

---

## 📁 Project Structure

```
mobile/
├── app/
│   ├── types/
│   │   └── transaction.ts              # TypeScript types & interfaces
│   │
│   ├── context/
│   │   └── TransactionContext.tsx      # Global state management
│   │
│   ├── utils/
│   │   └── analytics.ts                # Analytics logic & AI insights
│   │
│   ├── (tabs)/
│   │   ├── index.tsx                   # Dashboard screen
│   │   ├── add.tsx                     # Add transaction screen
│   │   ├── history.tsx                 # Transaction history screen
│   │   ├── analytics.tsx               # Analytics dashboard screen
│   │   ├── chat.tsx                    # AI chatbot screen
│   │   └── _layout.tsx                 # Tab navigation config
│   │
│   ├── _layout.tsx                     # Root layout with providers
│   └── modal.tsx                       # Modal components
│
├── components/                         # Reusable components
├── constants/                          # App constants
├── hooks/                              # Custom React hooks
├── assets/                             # Images & media
└── package.json                        # Dependencies
```

---

## 🏗️ Core Architecture

### **1. Type System** (`app/types/transaction.ts`)

Define your data structures:

```typescript
export interface Transaction {
  id: string;                // Unique ID
  amount: number;            // Transaction amount
  category: Category;        // Category name
  type: TransactionType;     // 'income' or 'expense'
  description: string;       // User description
  date: string;              // ISO date string
  timestamp: number;         // Milliseconds since epoch
}

export type TransactionType = 'income' | 'expense';

export type Category = 
  | 'food' 
  | 'transport' 
  | 'entertainment' 
  | 'shopping' 
  | 'utilities' 
  | 'health' 
  | 'salary' 
  | 'investment' 
  | 'other';
```

**To add a new category:**

1. Add to `Category` type:
```typescript
export type Category = 
  | 'food' 
  | 'transport' 
  | 'entertainment' 
  | 'shopping' 
  | 'utilities' 
  | 'health' 
  | 'salary' 
  | 'investment' 
  | 'insurance'  // NEW
  | 'other';
```

2. Add emoji in components:
```typescript
const CATEGORY_ICONS: Record<Category, string> = {
  // ... existing
  insurance: '🛡️',
};
```

3. Add to category list in `add.tsx`:
```typescript
const CATEGORIES: Record<TransactionType, Category[]> = {
  expense: ['food', 'transport', 'insurance', ...], // Add here
  income: ['salary', 'investment', 'other'],
};
```

### **2. State Management** (`app/context/TransactionContext.tsx`)

Uses React Context + AsyncStorage for data persistence:

```typescript
interface TransactionContextType {
  transactions: Transaction[];
  addTransaction: (transaction: Omit<Transaction, 'id' | 'timestamp'>) => void;
  deleteTransaction: (id: string) => void;
  loading: boolean;
}
```

**Key functions:**
- `addTransaction()` - Add new transaction
- `deleteTransaction()` - Remove transaction
- `useTransactions()` - Hook to access context

**To add new context methods:**

```typescript
// In TransactionContext.tsx
const updateTransaction = (id: string, updates: Partial<Transaction>) => {
  setTransactions(prev => 
    prev.map(t => t.id === id ? { ...t, ...updates } : t)
  );
};

// Add to context value
{ transactions, addTransaction, deleteTransaction, updateTransaction, loading }
```

### **3. Analytics Engine** (`app/utils/analytics.ts`)

Calculates statistics and generates AI insights:

```typescript
export const calculateAnalytics = (transactions: Transaction[]): Analytics => {
  // Returns: totalIncome, totalExpense, balance, categoryBreakdown, 
  //          dailyAverage, highestSpendingCategory, monthlyTrend
};

export const generateAIInsights = (analytics: Analytics, transactions: Transaction[]): string[] => {
  // Returns array of insight strings based on spending patterns
};
```

**To add new analytics:**

```typescript
export const calculateMonthlyAverage = (transactions: Transaction[]): number => {
  const months = new Set(
    transactions.map(t => new Date(t.date).toISOString().slice(0, 7))
  );
  const totalExpense = transactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);
  return totalExpense / (months.size || 1);
};
```

---

## 🎨 UI Components & Screens

### **Dashboard** (`app/(tabs)/index.tsx`)

Shows overview with quick actions:

```typescript
// Key state
- transactions (from context)
- analytics (from utils)

// Key components
- Quick stats cards (balance, income, expenses)
- Recent transactions list
- Quick action buttons
- Empty state for new users
```

**Customize stats:**
```typescript
const quickStats = [
  { label: 'Balance', value: `₹${analytics.balance.toFixed(2)}` },
  // Add more stats
];
```

### **Add Transaction** (`app/(tabs)/add.tsx`)

Form to record transactions:

```typescript
// State
- type: 'income' | 'expense'
- amount: string
- category: Category
- description: string

// Handler
handleAddTransaction() - Validates and saves
```

**Add custom validation:**
```typescript
const handleAddTransaction = () => {
  if (Number(amount) < 0) {
    alert('Amount cannot be negative');
    return;
  }
  // ... rest of logic
};
```

### **History** (`app/(tabs)/history.tsx`)

Lists all transactions with filter:

```typescript
// State
- filterType: 'all' | 'income' | 'expense'

// Functions
- renderTransaction() - Display each item
- formatDate() - Format date/time
```

### **Analytics** (`app/(tabs)/analytics.tsx`)

Dashboard with insights:

```typescript
// Displays
- Summary cards
- Key metrics
- Category breakdown
- Monthly trends
- AI insights
```

**Add new chart:**
```typescript
<View style={styles.chartSection}>
  <Text style={styles.sectionTitle}>Your Chart</Text>
  {/* Render chart data */}
</View>
```

### **Chat** (`app/(tabs)/chat.tsx`)

AI chatbot interface:

```typescript
// State
- messages: Message[]
- inputValue: string

// Function
generateAIResponse() - Generates response based on query
```

**Enhance AI responses:**
```typescript
const generateAIResponse = (query: string, analytics: any): QueryResponse => {
  const lowerQuery = query.toLowerCase();
  
  if (lowerQuery.includes('budget')) {
    return {
      answer: `Your budget analysis: ...`,
      icon: '📊',
    };
  }
  
  // Add more conditions
};
```

---

## 🔌 Adding New Features

### **1. Add a New Category**

Files to modify:
- `app/types/transaction.ts` - Add to Category type
- `app/(tabs)/add.tsx` - Add to CATEGORIES & CATEGORY_ICONS
- `app/(tabs)/index.tsx` - Add emoji to getCategoryEmoji()
- `app/(tabs)/history.tsx` - Add emoji to CATEGORY_ICONS
- `app/(tabs)/analytics.tsx` - Add emoji to CATEGORY_ICONS

### **2. Add Budget Limit Feature**

1. Update Transaction type:
```typescript
interface BudgetLimit {
  category: Category;
  limit: number;
  month: string;
}
```

2. Add to context:
```typescript
const [budgets, setBudgets] = useState<BudgetLimit[]>([]);

const setBudgetLimit = (category: Category, amount: number) => {
  // Logic here
};
```

3. Create Budget screen in `app/(tabs)/budget.tsx`

4. Add notifications when exceeded

### **3. Add Export Feature**

```typescript
export const exportToCSV = (transactions: Transaction[]): string => {
  const header = 'Date,Type,Category,Amount,Description\n';
  const rows = transactions.map(t => 
    `${t.date},${t.type},${t.category},${t.amount},${t.description}`
  ).join('\n');
  return header + rows;
};
```

### **4. Integrate Real AI API**

```typescript
import { ChatOpenAI } from "@langchain/openai";

const generateAIResponse = async (query: string, analytics: any) => {
  const llm = new ChatOpenAI({ apiKey: process.env.OPENAI_API_KEY });
  
  const prompt = `User is asking: "${query}"\n
                  Their spending data: ${JSON.stringify(analytics)}\n
                  Provide helpful financial advice.`;
  
  const response = await llm.invoke(prompt);
  return response;
};
```

### **5. Add Cloud Backup**

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const backupToCloud = async (transactions: Transaction[]) => {
  const response = await fetch('YOUR_API_ENDPOINT/backup', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ transactions }),
  });
  return response.json();
};
```

---

## 🎨 Styling Guide

All styles use React Native `StyleSheet`:

```typescript
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  // ... more styles
});
```

**Color scheme:**
```
- Income: #4CAF50 (Green)
- Expense: #f44336 (Red)
- Primary: #2196F3 (Blue)
- Background: #f5f5f5 (Light Gray)
- Text: #333 (Dark Gray)
- Hint: #999 (Medium Gray)
```

**To change theme:**
1. Edit `app/constants/theme.ts` for global colors
2. Or modify individual component styles

---

## 🧪 Testing

### Manual Testing Checklist

- [ ] Add transaction works
- [ ] Delete transaction works
- [ ] Filter works
- [ ] Analytics calculate correctly
- [ ] AI responds to queries
- [ ] Data persists after reload
- [ ] UI looks good on mobile
- [ ] No console errors

### Add Unit Tests

```typescript
// test/analytics.test.ts
import { calculateAnalytics } from '../app/utils/analytics';

test('calculates total income correctly', () => {
  const transactions = [
    { type: 'income', amount: 1000, ... },
    { type: 'income', amount: 500, ... },
  ];
  const result = calculateAnalytics(transactions);
  expect(result.totalIncome).toBe(1500);
});
```

---

## 🚀 Deployment

### Deploy to Expo Go (Mobile)

```bash
npm run android   # Android emulator
npm run ios       # iOS simulator
```

### Deploy to Web

```bash
npm run web       # Local web server
```

### Build APK (requires Android SDK)

```bash
eas build --platform android
```

---

## 🔍 Debugging

### Enable Debug Mode

```bash
# In terminal during npm run web
Press 'j' for debugger
Press 'm' for menu
```

### Check Logs

```bash
# Browser console
F12 in browser

# Terminal logs
Watch for printed errors
```

### Common Issues

**AsyncStorage not working:**
```bash
npm install @react-native-async-storage/async-storage
```

**Route not found:**
- File must be in `app/(tabs)/` for tab screens
- Must have default export

**Style not applied:**
- Check if wrapped in `StyleSheet.create()`
- Verify style name is spelled correctly

---

## 📚 Resources

- [React Native Docs](https://reactnative.dev/)
- [Expo Router](https://expo.dev/router)
- [AsyncStorage](https://react-native-async-storage.github.io/async-storage/)
- [React Navigation](https://reactnavigation.org/)

---

## 💼 Code Quality

### ESLint
```bash
npm run lint
```

### TypeScript
```bash
# Check for type errors
npx tsc --noEmit
```

### Format Code
```bash
npx prettier --write "app/**/*.{ts,tsx}"
```

---

## 🎯 Performance Tips

1. **Memoize expensive calculations**
   ```typescript
   const analytics = useMemo(() => calculateAnalytics(transactions), [transactions]);
   ```

2. **Lazy load screens**
   ```typescript
   const Analytics = lazy(() => import('./analytics'));
   ```

3. **Optimize renders**
   ```typescript
   <FlatList
     data={transactions}
     renderItem={renderTransaction}
     keyExtractor={item => item.id}
     getItemLayout={(data, index) => ({ length: 60, offset: 60 * index, index })}
   />
   ```

---

## 📝 Contributing Guidelines

1. Keep code clean and readable
2. Add comments for complex logic
3. Use TypeScript for type safety
4. Test before pushing changes
5. Follow existing code style

---

Happy coding! 💻✨
