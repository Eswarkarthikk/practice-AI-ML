import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  Pressable,
  FlatList,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useTransactions } from '@/lib/context/TransactionContext';
import { calculateAnalytics } from '@/lib/utils/analytics';

interface Message {
  id: string;
  type: 'user' | 'ai';
  text: string;
}

interface QueryResponse {
  answer: string;
  icon: string;
}

const generateAIResponse = (query: string, analytics: any, transactions: any[]): QueryResponse => {
  const lowerQuery = query.toLowerCase();

  // Simple AI response logic based on keywords
  if (lowerQuery.includes('how much') || lowerQuery.includes('total')) {
    if (lowerQuery.includes('spend') || lowerQuery.includes('expense')) {
      return {
        answer: `You've spent a total of ₹${analytics.totalExpense.toFixed(2)} across all transactions.`,
        icon: '💸',
      };
    }
    if (lowerQuery.includes('earn') || lowerQuery.includes('income')) {
      return {
        answer: `You've earned a total of ₹${analytics.totalIncome.toFixed(2)} from all income sources.`,
        icon: '💰',
      };
    }
    if (lowerQuery.includes('balance')) {
      return {
        answer: `Your current balance is ₹${analytics.balance.toFixed(2)}. ${
          analytics.balance > 0 ? '📈 You are in profit!' : '📉 You are in deficit.'
        }`,
        icon: '💳',
      };
    }
  }

  if (lowerQuery.includes('where') || lowerQuery.includes('spending')) {
    if (analytics.highestSpendingCategory) {
      return {
        answer: `Your highest spending is in ${analytics.highestSpendingCategory} with ₹${analytics.categoryBreakdown[analytics.highestSpendingCategory].toFixed(2)}.`,
        icon: '📊',
      };
    }
  }

  if (lowerQuery.includes('average') || lowerQuery.includes('daily')) {
    return {
      answer: `You spend an average of ₹${analytics.dailyAverage.toFixed(2)} per day.`,
      icon: '📈',
    };
  }

  if (lowerQuery.includes('how many') || lowerQuery.includes('count')) {
    return {
      answer: `You have recorded ${analytics.transactionCount} transactions in total.`,
      icon: '📝',
    };
  }

  if (lowerQuery.includes('save') || lowerQuery.includes('budget')) {
    const monthlySavingsPotential = (analytics.dailyAverage * 30 * 0.1).toFixed(2);
    return {
      answer: `By reducing spending by 10%, you could save approximately ₹${monthlySavingsPotential} per month. Consider reducing expenses in your highest spending categories.`,
      icon: '💡',
    };
  }

  if (lowerQuery.includes('category')) {
    const categories = Object.keys(analytics.categoryBreakdown);
    if (categories.length > 0) {
      return {
        answer: `You spend on these categories: ${categories.join(', ')}. Your biggest category is ${analytics.highestSpendingCategory}.`,
        icon: '🏷️',
      };
    }
  }

  if (lowerQuery.includes('trend') || lowerQuery.includes('month')) {
    if (analytics.monthlyTrend.length > 1) {
      const latestMonth = analytics.monthlyTrend[analytics.monthlyTrend.length - 1];
      const previousMonth = analytics.monthlyTrend[analytics.monthlyTrend.length - 2];
      const change = latestMonth.expense - previousMonth.expense;
      const trend = change > 0 ? '📈 increasing' : '📉 decreasing';
      return {
        answer: `Your spending is ${trend}. Last month: ₹${previousMonth.expense.toFixed(2)}, This month: ₹${latestMonth.expense.toFixed(2)}`,
        icon: '📊',
      };
    }
  }

  // Default responses
  const defaultResponses = [
    {
      answer: `I can help you understand your finances! Try asking me questions like: "How much have I spent?", "What's my balance?", "Where do I spend the most?", "What's my daily average?", "How can I save money?"`,
      icon: '🤖',
    },
  ];

  return defaultResponses[Math.floor(Math.random() * defaultResponses.length)];
};

export default function ChatScreen() {
  const { transactions } = useTransactions();
  const analytics = calculateAnalytics(transactions);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '0',
      type: 'ai',
      text: 'Hi! 👋 I\'m your finance assistant. Ask me anything about your spending, income, and budgeting!',
    },
  ]);
  const [inputValue, setInputValue] = useState('');

  const suggestedQueries = [
    "How much have I spent?",
    "What's my balance?",
    "Where do I spend the most?",
    "How can I save money?",
    "What's my daily spending?",
    "Show me my trends",
  ];

  const handleSendMessage = (query: string) => {
    if (!query.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      text: query,
    };

    setMessages(prev => [...prev, userMessage]);

    setTimeout(() => {
      const response = generateAIResponse(query, analytics, transactions);
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'ai',
        text: `${response.icon} ${response.answer}`,
      };
      setMessages(prev => [...prev, aiMessage]);
    }, 500);

    setInputValue('');
  };

  const renderMessage = ({ item }: any) => (
    <View
      style={[
        styles.messageBubble,
        item.type === 'user' ? styles.userMessage : styles.aiMessage,
      ]}
    >
      <Text style={[styles.messageText, item.type === 'user' && styles.userMessageText]}>
        {item.text}
      </Text>
    </View>
  );

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <View style={styles.header}>
        <Text style={styles.headerTitle}>🤖 Finance Assistant</Text>
        <Text style={styles.headerSubtitle}>Ask me anything about your finances</Text>
      </View>

      <FlatList
        data={messages}
        renderItem={renderMessage}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.messagesList}
        scrollEnabled={true}
      />

      {messages.length === 1 && (
        <ScrollView style={styles.suggestionsContainer} horizontal showsHorizontalScrollIndicator={false}>
          {suggestedQueries.map((query, index) => (
            <Pressable
              key={index}
              style={styles.suggestionChip}
              onPress={() => handleSendMessage(query)}
            >
              <Text style={styles.suggestionText}>{query}</Text>
            </Pressable>
          ))}
        </ScrollView>
      )}

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Ask about your spending..."
          value={inputValue}
          onChangeText={setInputValue}
          placeholderTextColor="#999"
          multiline
          maxLength={100}
        />
        <Pressable
          style={[styles.sendButton, !inputValue.trim() && styles.sendButtonDisabled]}
          onPress={() => handleSendMessage(inputValue)}
          disabled={!inputValue.trim()}
        >
          <Text style={styles.sendButtonText}>Send</Text>
        </Pressable>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#2196F3',
    paddingVertical: 16,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#1976D2',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
  },
  headerSubtitle: {
    fontSize: 12,
    color: '#E3F2FD',
    marginTop: 4,
  },
  messagesList: {
    paddingHorizontal: 12,
    paddingVertical: 12,
  },
  messageBubble: {
    marginBottom: 12,
    maxWidth: '80%',
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  userMessage: {
    alignSelf: 'flex-end',
    backgroundColor: '#2196F3',
  },
  aiMessage: {
    alignSelf: 'flex-start',
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#eee',
  },
  messageText: {
    fontSize: 14,
    color: '#333',
    lineHeight: 20,
  },
  userMessageText: {
    color: '#fff',
  },
  suggestionsContainer: {
    paddingHorizontal: 12,
    marginBottom: 12,
  },
  suggestionChip: {
    backgroundColor: '#E3F2FD',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 8,
    borderWidth: 1,
    borderColor: '#2196F3',
  },
  suggestionText: {
    fontSize: 12,
    color: '#2196F3',
    fontWeight: '500',
  },
  inputContainer: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 10,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#eee',
    gap: 8,
  },
  input: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 10,
    fontSize: 14,
    maxHeight: 100,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  sendButton: {
    backgroundColor: '#2196F3',
    paddingHorizontal: 20,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sendButtonDisabled: {
    backgroundColor: '#ccc',
  },
  sendButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 14,
  },
});
