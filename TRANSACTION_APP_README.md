# 💰 Transaction Tracker - AI-Powered Finance App

A beautiful, user-friendly mobile app built with **React Native & Expo** that helps you track every transaction, analyze your spending patterns, and get AI-powered financial insights!

## ✨ Features

### 📱 **Dashboard (Home Screen)**
- **Quick Overview**: See your balance, total income, and expenses at a glance
- **Recent Transactions**: Display your latest 5 transactions
- **Quick Actions**: Fast access to all main features
- **Pro Tips**: Helpful budgeting advice

### ➕ **Add Transactions**
- **Easy Recording**: Record income and expenses in seconds
- **Smart Categories**: Pre-defined categories like Food, Transport, Shopping, etc.
- **Custom Descriptions**: Add notes for each transaction
- **Real-time Sync**: Automatically saved to your device storage

### 📝 **Transaction History**
- **Full List**: View all your transactions chronologically
- **Filter Options**: Filter by All, Income, or Expenses
- **Delete Function**: Long-press on any transaction to delete it
- **Date-Time Display**: See exactly when each transaction occurred

### 📊 **Analytics Dashboard**
- **Summary Cards**: Income, Expenses, and Balance at a glance
- **Key Metrics**: Daily average spending and transaction count
- **Category Breakdown**: See where your money goes with percentage breakdown
- **Monthly Trends**: Track income vs expenses month by month
- **🤖 AI Insights**: Smart recommendations based on your spending patterns

### 🤖 **Finance AI Assistant**
- **Smart Queries**: Ask questions about your spending like:
  - "How much have I spent?"
  - "What's my balance?"
  - "Where do I spend the most?"
  - "How can I save money?"
  - "Show me my trends"
- **Conversational Chat**: Natural language queries
- **Suggested Questions**: Quick access to common queries
- **AI Insights**: Get personalized financial advice

## 🏗️ App Architecture

```
/app
├── /types
│   └── transaction.ts         # Transaction & Category types
├── /context
│   └── TransactionContext.tsx # State management with AsyncStorage
├── /utils
│   └── analytics.ts           # Analytics calculations & AI insights
├── /(tabs)
│   ├── index.tsx              # Dashboard/Home
│   ├── add.tsx                # Add Transaction
│   ├── history.tsx            # View History
│   ├── analytics.tsx          # Analytics Dashboard
│   ├── chat.tsx               # AI Chat Assistant
│   └── _layout.tsx            # Bottom tab navigation
├── _layout.tsx                # Root layout with TransactionProvider
└── modal.tsx                  # Modal screens
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16+)
- npm or yarn

### Installation

1. **Navigate to the mobile directory**:
   ```bash
   cd /workspaces/practice-AI-ML/mobile
   ```

2. **Start the development server**:
   ```bash
   npm run web
   ```

3. **Open in browser**:
   The app will be available at `http://localhost:8081`

### Other Commands

```bash
# Start iOS development
npm run ios

# Start Android development (requires Android SDK)
npm run android

# Lint the code
npm run lint

# Reset project to original state
npm run reset-project
```

## 💾 Data Storage

All transactions are automatically **saved locally** on your device using **AsyncStorage**. This means:
- ✅ Your data persists even after closing the app
- ✅ No internet required for basic usage
- ✅ Your financial data stays private on your device

## 🤖 AI Features

### Smart Analytics
The app automatically generates insights like:
- Total balance and spending summaries
- Highest spending category alerts
- Daily/monthly spending trends
- Saving opportunities
- Budget recommendations

### Natural Language Chat
Ask the assistant anything about your finances:
- Income/expense totals
- Spending by category
- Monthly comparing
- Budget recommendations
- Trend analysis

## 🎨 UI/UX Design

- **Clean & Modern**: Minimalist design with intuitive navigation
- **Color-Coded**: Income (Green), Expenses (Red), Neutral (Blue)
- **Category Emojis**: Quick visual recognition of transaction types
- **Responsive**: Works great on phones, tablets, and web
- **Accessible**: Large text, clear buttons, good contrast

## 📊 Data Insights

The app tracks:
- **Transaction Types**: Income vs Expenses
- **Categories**: 9 predefined categories
- **Time Tracking**: Date, time, and timezone info
- **Amount Tracking**: Precise decimal amounts
- **Descriptions**: Custom notes for each transaction

### Analytics Calculations
- Total income and expenses
- Current balance
- Daily average spending
- Category-wise breakdown
- Monthly trends
- Spending patterns

## 🔐 Privacy & Security

- All data is stored **locally** on your device
- No cloud sync (can be added later)
- No personal data collection
- Your financial data never leaves your device

## 🚀 Future Enhancements

Ideas you can add:
1. **Cloud Backup**: Sync to cloud (Firebase, Supabase)
2. **Real AI Integration**: Connect with GPT-4 for smarter insights
3. **Budget Alerts**: Notify when exceeding budget
4. **Recurring Transactions**: Auto-add monthly bills
5. **Export Data**: Generate PDF/CSV reports
6. **Multi-currency**: Support different currencies
7. **Recurring Reminders**: Daily budget checks
8. **Charts & Graphs**: Visual data representation

## 📦 Dependencies

Key packages used:
- **expo-router**: Navigation
- **react-native**: Core framework
- **@react-native-async-storage/async-storage**: Data persistence
- **@react-navigation**: Navigation components
- **expo-blur**: UI effects

## 🐛 Troubleshooting

### App won't start?
```bash
# Clear cache and reinstall
npm install
npm run web
```

### AsyncStorage errors?
The app requires AsyncStorage to be working. Make sure dependencies are installed:
```bash
npm install @react-native-async-storage/async-storage
```

### Shadow style warnings?
These are expected on web. They don't affect functionality and use `boxShadow` which works fine in browsers.

## 📱 Testing the App

### Try these actions:
1. **Add a transaction**: Go to the "Add" tab and record a transaction
2. **View history**: Check the "History" tab to see all transactions
3. **Check analytics**: Visit "Analytics" to see spending breakdown
4. **Chat with AI**: Try asking "How much have I spent?" in the Chat tab
5. **See dashboard**: Overview all stats on the home screen

### Sample Data
Try adding these transactions:
- Breakfast: ₹300 (Food - Expense)
- Salary: ₹50,000 (Salary - Income)
- Uber: ₹150 (Transport - Expense)
- Netflix: ₹200 (Entertainment - Expense)

## 🎯 Project Structure

```
mobile/
├── app/                          # React Native app code
│   ├── types/                    # TypeScript types
│   ├── context/                  # React Context for state
│   ├── utils/                    # Utility functions
│   ├── (tabs)/                   # Tab screens
│   ├── _layout.tsx               # Root navigation
│   └── modal.tsx                 # Modal components
├── components/                   # Reusable components
├── constants/                    # App constants
├── hooks/                        # Custom React hooks
├── assets/                       # Images and media
├── package.json                  # Dependencies
└── tsconfig.json                 # TypeScript config
```

## 💡 Tips for Users

1. **Daily Tracking**: Log transactions immediately for accurate records
2. **Use Categories**: Be consistent with category selection
3. **Check Trends**: Review analytics monthly to optimize spending
4. **Ask Questions**: Use the AI chat to understand your spending patterns
5. **Set Goals**: Use insights to set realistic budgets

## 🤝 Contributing

To extend this project:
1. Add more categories
2. Implement cloud backup
3. Add budget limits with alerts
4. Integrate real AI API
5. Add data visualizations

## 📄 License

This project is open source and available for personal use.

## 🙏 Support

For issues or questions:
- Check the Troubleshooting section
- Review the code comments
- Check browser console for errors

---

**Happy tracking! Your financial data is now in your hands! 💰**

*Last Updated: February 2026*
