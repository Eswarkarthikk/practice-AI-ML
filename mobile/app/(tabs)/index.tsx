import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { useTransactions } from '@/lib/context/TransactionContext';
import { calculateAnalytics } from '@/lib/utils/analytics';

export default function HomeScreen() {
  const { transactions, loading } = useTransactions();
  const analytics = calculateAnalytics(transactions);
  const router = useRouter();

  const recentTransactions = transactions.slice(0, 5);

  const quickStats = [
    {
      label: 'Balance',
      value: `₹${analytics.balance.toFixed(2)}`,
      color: '#2196F3',
      icon: '💳',
    },
    {
      label: 'Income',
      value: `₹${analytics.totalIncome.toFixed(2)}`,
      color: '#4CAF50',
      icon: '💰',
    },
    {
      label: 'Expenses',
      value: `₹${analytics.totalExpense.toFixed(2)}`,
      color: '#f44336',
      icon: '💸',
    },
  ];

  const shortcuts = [
    { label: 'Add', icon: '➕', action: () => router.push('/(tabs)/add') },
    { label: 'History', icon: '📝', action: () => router.push('/(tabs)/history') },
    { label: 'Analytics', icon: '📈', action: () => router.push('/(tabs)/analytics') },
    { label: 'Ask AI', icon: '🤖', action: () => router.push('/(tabs)/chat') },
  ];

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.greeting}>Welcome Back! 👋</Text>
        <Text style={styles.date}>
          {new Date().toLocaleDateString('en-IN', { weekday: 'long', month: 'long', day: 'numeric' })}
        </Text>
      </View>

      {/* Quick Stats */}
      <View style={styles.statsContainer}>
        {quickStats.map((stat, index) => (
          <View key={index} style={[styles.statCard, { borderLeftColor: stat.color }]}>
            <Text style={styles.statIcon}>{stat.icon}</Text>
            <Text style={styles.statLabel}>{stat.label}</Text>
            <Text style={[styles.statValue, { color: stat.color }]}>{stat.value}</Text>
          </View>
        ))}
      </View>

      {/* Quick Shortcuts */}
      <View style={styles.shortcutsSection}>
        <Text style={styles.sectionTitle}>Quick Actions</Text>
        <View style={styles.shortcutsGrid}>
          {shortcuts.map((shortcut, index) => (
            <Pressable
              key={index}
              style={styles.shortcutButton}
              onPress={shortcut.action}
            >
              <Text style={styles.shortcutIcon}>{shortcut.icon}</Text>
              <Text style={styles.shortcutLabel}>{shortcut.label}</Text>
            </Pressable>
          ))}
        </View>
      </View>

      {/* Recent Transactions */}
      <View style={styles.recentSection}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recent Transactions</Text>
          <Pressable onPress={() => router.push('/(tabs)/history')}>
            <Text style={styles.seeAllLink}>See All</Text>
          </Pressable>
        </View>

        {recentTransactions.length === 0 ? (
          <View style={styles.emptyStateCard}>
            <Text style={styles.emptyStateIcon}>📝</Text>
            <Text style={styles.emptyStateText}>No transactions yet</Text>
            <Text style={styles.emptyStateSubtext}>Start by adding your first transaction</Text>
            <Pressable style={styles.emptyStateButton} onPress={() => router.push('/(tabs)/add')}>
              <Text style={styles.emptyStateButtonText}>Add Transaction</Text>
            </Pressable>
          </View>
        ) : (
          recentTransactions.map(transaction => (
            <View key={transaction.id} style={styles.transactionItem}>
              <View style={styles.transactionInfo}>
                <Text style={styles.transactionEmoji}>
                  {getCategoryEmoji(transaction.category)}
                </Text>
                <View>
                  <Text style={styles.transactionName}>{transaction.description}</Text>
                  <Text style={styles.transactionTime}>
                    {new Date(transaction.date).toLocaleTimeString('en-IN', {
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </Text>
                </View>
              </View>
              <Text
                style={[
                  styles.transactionAmount,
                  transaction.type === 'income' ? styles.incomeText : styles.expenseText,
                ]}
              >
                {transaction.type === 'income' ? '+' : '-'}₹{transaction.amount.toFixed(2)}
              </Text>
            </View>
          ))
        )}
      </View>

      {/* Info Section */}
      <View style={styles.infoCard}>
        <Text style={styles.infoTitle}>💡 Pro Tips</Text>
        <Text style={styles.infoText}>
          • Track every transaction to get accurate insights{'\n'}
          • Use categories to understand spending patterns{'\n'}
          • Check analytics regularly to optimize your budget
        </Text>
      </View>

      <View style={styles.spacer} />
    </ScrollView>
  );
}

function getCategoryEmoji(category: string): string {
  const emojis: Record<string, string> = {
    food: '🍔',
    transport: '🚗',
    entertainment: '🎬',
    shopping: '🛍️',
    utilities: '💡',
    health: '🏥',
    salary: '💵',
    investment: '📈',
    other: '📌',
  };
  return emojis[category] || '📌';
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 20,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  greeting: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  date: {
    fontSize: 14,
    color: '#999',
  },
  statsContainer: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 16,
    gap: 10,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 12,
    borderLeftWidth: 4,
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  statIcon: {
    fontSize: 24,
    marginBottom: 8,
  },
  statLabel: {
    fontSize: 12,
    color: '#999',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  shortcutsSection: {
    paddingHorizontal: 16,
    marginBottom: 20,
  },
  shortcutsGrid: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 12,
  },
  shortcutButton: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
    elevation: 2,
  },
  shortcutIcon: {
    fontSize: 28,
    marginBottom: 8,
  },
  shortcutLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#333',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  recentSection: {
    paddingHorizontal: 16,
    marginBottom: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  seeAllLink: {
    fontSize: 14,
    color: '#2196F3',
    fontWeight: '600',
  },
  emptyStateCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingVertical: 32,
    alignItems: 'center',
    marginBottom: 12,
  },
  emptyStateIcon: {
    fontSize: 48,
    marginBottom: 12,
  },
  emptyStateText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  emptyStateSubtext: {
    fontSize: 14,
    color: '#999',
    marginBottom: 16,
  },
  emptyStateButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 8,
  },
  emptyStateButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
  transactionItem: {
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    marginBottom: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    boxShadow: '0px 1px 2px rgba(0,0,0,0.08)',
    elevation: 1,
  },
  transactionInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flex: 1,
  },
  transactionEmoji: {
    fontSize: 24,
  },
  transactionName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    textTransform: 'capitalize',
  },
  transactionTime: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
  transactionAmount: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  incomeText: {
    color: '#4CAF50',
  },
  expenseText: {
    color: '#f44336',
  },
  infoCard: {
    marginHorizontal: 16,
    backgroundColor: '#E3F2FD',
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 16,
    marginBottom: 20,
  },
  infoTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2196F3',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 12,
    color: '#1976D2',
    lineHeight: 18,
  },
  spacer: {
    height: 40,
  },
});
