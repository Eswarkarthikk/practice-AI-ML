import React from 'react';
import { View, Text, StyleSheet, Pressable, ScrollView, TextInput, Modal } from 'react-native';
import { useState } from 'react';
import { useTransactions } from '@/lib/context/TransactionContext';
import type { TransactionType, Category } from '@/lib/types/transaction';

const CATEGORIES: Record<TransactionType, Category[]> = {
  expense: ['food', 'transport', 'entertainment', 'shopping', 'utilities', 'health', 'other'],
  income: ['salary', 'investment', 'other'],
};

const CATEGORY_ICONS: Record<Category, string> = {
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

export default function AddTransactionScreen() {
  const { addTransaction } = useTransactions();
  const [type, setType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<Category>('food');
  const [showCategoryModal, setShowCategoryModal] = useState(false);

  const handleAddTransaction = () => {
    if (!amount || isNaN(Number(amount))) {
      alert('Please enter a valid amount');
      return;
    }

    addTransaction({
      amount: Number(amount),
      category: selectedCategory,
      type,
      description: description || selectedCategory,
      date: new Date().toISOString(),
    });

    // Reset form
    setAmount('');
    setDescription('');
    setSelectedCategory(type === 'expense' ? 'food' : 'salary');
    alert('Transaction recorded successfully! ✅');
  };

  const handleTypeChange = (newType: TransactionType) => {
    setType(newType);
    setSelectedCategory(newType === 'expense' ? 'food' : 'salary');
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Record Transaction</Text>

      {/* Type Selection */}
      <View style={styles.typeContainer}>
        <Pressable
          style={[styles.typeButton, type === 'expense' && styles.typeButtonActive]}
          onPress={() => handleTypeChange('expense')}
        >
          <Text style={[styles.typeButtonText, type === 'expense' && styles.typeButtonTextActive]}>
            💸 Expense
          </Text>
        </Pressable>
        <Pressable
          style={[styles.typeButton, type === 'income' && styles.typeButtonActive]}
          onPress={() => handleTypeChange('income')}
        >
          <Text style={[styles.typeButtonText, type === 'income' && styles.typeButtonTextActive]}>
            💰 Income
          </Text>
        </Pressable>
      </View>

      {/* Amount Input */}
      <View style={styles.section}>
        <Text style={styles.label}>Amount (₹)</Text>
        <TextInput
          style={styles.input}
          placeholder="0.00"
          keyboardType="decimal-pad"
          value={amount}
          onChangeText={setAmount}
          placeholderTextColor="#999"
        />
      </View>

      {/* Category Selection */}
      <View style={styles.section}>
        <Text style={styles.label}>Category</Text>
        <Pressable style={styles.categoryButton} onPress={() => setShowCategoryModal(true)}>
          <Text style={styles.categoryButtonText}>
            {CATEGORY_ICONS[selectedCategory]} {selectedCategory}
          </Text>
        </Pressable>

        <Modal
          visible={showCategoryModal}
          transparent
          animationType="slide"
          onRequestClose={() => setShowCategoryModal(false)}
        >
          <View style={styles.modalOverlay}>
            <View style={styles.modalContent}>
              <Text style={styles.modalTitle}>Select Category</Text>
              <ScrollView style={styles.categoryGrid}>
                {CATEGORIES[type].map(category => (
                  <Pressable
                    key={category}
                    style={[
                      styles.categoryOption,
                      selectedCategory === category && styles.categoryOptionSelected,
                    ]}
                    onPress={() => {
                      setSelectedCategory(category);
                      setShowCategoryModal(false);
                    }}
                  >
                    <Text style={styles.categoryOptionText}>
                      {CATEGORY_ICONS[category]} {category}
                    </Text>
                  </Pressable>
                ))}
              </ScrollView>
              <Pressable
                style={styles.closeButton}
                onPress={() => setShowCategoryModal(false)}
              >
                <Text style={styles.closeButtonText}>Close</Text>
              </Pressable>
            </View>
          </View>
        </Modal>
      </View>

      {/* Description Input */}
      <View style={styles.section}>
        <Text style={styles.label}>Description (Optional)</Text>
        <TextInput
          style={[styles.input, styles.descriptionInput]}
          placeholder="Add notes about this transaction..."
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={3}
          placeholderTextColor="#999"
        />
      </View>

      {/* Add Button */}
      <Pressable style={styles.addButton} onPress={handleAddTransaction}>
        <Text style={styles.addButtonText}>✅ Record Transaction</Text>
      </Pressable>

      <View style={styles.spacer} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 24,
    color: '#333',
  },
  typeContainer: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 24,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 12,
    backgroundColor: '#e0e0e0',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
  },
  typeButtonActive: {
    backgroundColor: '#ff6b6b',
    borderColor: '#c92a2a',
  },
  typeButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
  },
  typeButtonTextActive: {
    color: '#fff',
  },
  section: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 12,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  descriptionInput: {
    paddingVertical: 12,
    textAlignVertical: 'top',
  },
  categoryButton: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 12,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  categoryButtonText: {
    fontSize: 16,
    color: '#333',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  categoryGrid: {
    marginBottom: 16,
  },
  categoryOption: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 10,
    backgroundColor: '#f5f5f5',
    marginBottom: 8,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  categoryOptionSelected: {
    backgroundColor: '#ff6b6b',
    borderColor: '#c92a2a',
  },
  categoryOptionText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  addButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 20,
    boxShadow: '0px 2px 4px rgba(0,0,0,0.1)',
  },
  addButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  closeButton: {
    backgroundColor: '#f0f0f0',
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
  },
  closeButtonText: {
    color: '#333',
    fontSize: 16,
    fontWeight: '600',
  },
  spacer: {
    height: 40,
  },
});
