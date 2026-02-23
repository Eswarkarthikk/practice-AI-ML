import React from 'react';
import { View, Text, StyleSheet, Pressable, ScrollView, TextInput, Modal } from 'react-native';
import { useState } from 'react';
import { useTransactions } from '@/lib/context/TransactionContext';
import { useApp } from '@/lib/context/AppContext';
import type { TransactionType } from '@/lib/types/transaction';

const CATEGORIES: Record<TransactionType, string[]> = {
  expense: ['food', 'transport', 'entertainment', 'shopping', 'utilities', 'health', 'other'],
  income: ['salary', 'investment', 'other'],
};

const CATEGORY_ICONS: Record<string, string> = {
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
  const txContext = useTransactions();
  const { addTransaction: addAppTx, sources, addSource } = useApp();
  const { addTransaction, subcategories, addSubcategory } = txContext;
  const [type, setType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('food');
  const [selectedSubcategory, setSelectedSubcategory] = useState<string | null>(null);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [showSubcategoryModal, setShowSubcategoryModal] = useState(false);
  const [newSubcategoryName, setNewSubcategoryName] = useState('');
  const [showSourceModal, setShowSourceModal] = useState(false);
  const [selectedSourceId, setSelectedSourceId] = useState<string | null>(
    sources && sources.length > 0 ? sources[0].id : null
  );
  const [newSourceName, setNewSourceName] = useState('');
  const [newSourceType, setNewSourceType] = useState<'Bank' | 'Cash' | 'Other'>('Bank');

  const handleAddTransaction = () => {
    if (!amount || isNaN(Number(amount))) {
      alert('Please enter a valid amount');
      return;
    }

    const txPayload: any = {
      amount: Number(amount),
      category: selectedCategory,
      subcategory: selectedSubcategory || undefined,
      type,
      source: selectedSourceId || '',
      description: description || selectedCategory,
      date: new Date().toISOString(),
    };

    // Update both contexts/storage so UI using either context stays in sync
    try {
      addTransaction(txPayload);
    } catch (e) {
      console.warn('tx context add failed', e);
    }
    try {
      addAppTx(txPayload);
    } catch (e) {
      console.warn('app context add failed', e);
    }

    // Reset form
    setAmount('');
    setDescription('');
    setSelectedCategory(type === 'expense' ? 'food' : 'salary');
    setSelectedSubcategory(null);
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

        {/* Subcategory Selection */}
        <View style={{ marginTop: 12 }}>
          <Text style={styles.label}>Subcategory (optional)</Text>
          <Pressable style={styles.categoryButton} onPress={() => setShowSubcategoryModal(true)}>
            <Text style={styles.categoryButtonText}>
              {selectedSubcategory || 'Select or add subcategory'}
            </Text>
          </Pressable>
        </View>

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

        <Modal
          visible={showSubcategoryModal}
          transparent
          animationType="slide"
          onRequestClose={() => setShowSubcategoryModal(false)}
        >
          <View style={styles.modalOverlay}>
            <View style={styles.modalContent}>
              <Text style={styles.modalTitle}>Subcategories for {selectedCategory}</Text>
              <ScrollView style={styles.categoryGrid}>
                {(subcategories && subcategories.length > 0) ? (
                  subcategories
                    .filter((s: any) => s.categoryId === selectedCategory)
                    .map((s: any) => (
                      <Pressable
                        key={s.id}
                        style={[
                          styles.categoryOption,
                          selectedSubcategory === s.name && styles.categoryOptionSelected,
                        ]}
                        onPress={() => {
                          setSelectedSubcategory(s.name);
                          setShowSubcategoryModal(false);
                        }}
                      >
                        <Text style={styles.categoryOptionText}>{s.name}</Text>
                      </Pressable>
                    ))
                ) : null}

                <View style={{ marginTop: 12 }}>
                  <Text style={styles.label}>Add new subcategory</Text>
                  <TextInput
                    style={styles.input}
                    placeholder="Enter subcategory name"
                    value={newSubcategoryName}
                    onChangeText={setNewSubcategoryName}
                  />
                  <Pressable
                    style={[styles.addButton, { marginTop: 12 }]}
                    onPress={async () => {
                      if (!newSubcategoryName.trim()) return alert('Enter name');
                      if (addSubcategory) {
                        await addSubcategory(newSubcategoryName.trim(), selectedCategory);
                        setSelectedSubcategory(newSubcategoryName.trim());
                        setNewSubcategoryName('');
                        setShowSubcategoryModal(false);
                      }
                    }}
                  >
                    <Text style={styles.addButtonText}>Add Subcategory</Text>
                  </Pressable>
                </View>
              </ScrollView>
              <Pressable
                style={styles.closeButton}
                onPress={() => setShowSubcategoryModal(false)}
              >
                <Text style={styles.closeButtonText}>Close</Text>
              </Pressable>
            </View>
          </View>
        </Modal>

        {/* Source selection for income (and optional for expense) */}
        {type === 'income' && (
          <View style={{ marginTop: 12 }}>
            <Text style={styles.label}>Source</Text>
            <Pressable style={styles.categoryButton} onPress={() => setShowSourceModal(true)}>
              <Text style={styles.categoryButtonText}>{selectedSourceId ? sources.find(s => s.id === selectedSourceId)?.name : 'Select or add source'}</Text>
            </Pressable>

            <Modal
              visible={showSourceModal}
              transparent
              animationType="slide"
              onRequestClose={() => setShowSourceModal(false)}
            >
              <View style={styles.modalOverlay}>
                <View style={styles.modalContent}>
                  <Text style={styles.modalTitle}>Select or Add Source</Text>
                  <ScrollView style={styles.categoryGrid}>
                    {sources.map(src => (
                      <Pressable
                        key={src.id}
                        style={styles.categoryOption}
                        onPress={() => {
                          setSelectedSourceId(src.id);
                          setShowSourceModal(false);
                        }}
                      >
                        <Text style={styles.categoryOptionText}>{src.name} ({src.type})</Text>
                      </Pressable>
                    ))}

                    <View style={{ marginTop: 12 }}>
                      <Text style={styles.label}>New source name</Text>
                      <TextInput style={styles.input} value={newSourceName} onChangeText={setNewSourceName} placeholder="e.g., My Bank" />
                      <Text style={[styles.label, { marginTop: 8 }]}>Type</Text>
                      <View style={{ flexDirection: 'row', gap: 8 }}>
                        <Pressable style={[styles.typeButton, newSourceType === 'Bank' && styles.typeButtonActive]} onPress={() => setNewSourceType('Bank')}>
                          <Text style={[styles.typeButtonText, newSourceType === 'Bank' && styles.typeButtonTextActive]}>Bank</Text>
                        </Pressable>
                        <Pressable style={[styles.typeButton, newSourceType === 'Cash' && styles.typeButtonActive]} onPress={() => setNewSourceType('Cash')}>
                          <Text style={[styles.typeButtonText, newSourceType === 'Cash' && styles.typeButtonTextActive]}>Cash</Text>
                        </Pressable>
                        <Pressable style={[styles.typeButton, newSourceType === 'Other' && styles.typeButtonActive]} onPress={() => setNewSourceType('Other')}>
                          <Text style={[styles.typeButtonText, newSourceType === 'Other' && styles.typeButtonTextActive]}>Other</Text>
                        </Pressable>
                      </View>
                      <Pressable
                        style={[styles.addButton, { marginTop: 12 }]}
                        onPress={async () => {
                          if (!newSourceName.trim()) return alert('Enter source name');
                          try {
                            const id = await addSource(newSourceName.trim(), newSourceType, 0);
                            setSelectedSourceId(id);
                          } catch (e) {
                            console.warn('addSource failed', e);
                          }
                          setNewSourceName('');
                          setShowSourceModal(false);
                        }}
                      >
                        <Text style={styles.addButtonText}>Add Source</Text>
                      </Pressable>
                    </View>
                  </ScrollView>
                  <Pressable style={styles.closeButton} onPress={() => setShowSourceModal(false)}>
                    <Text style={styles.closeButtonText}>Close</Text>
                  </Pressable>
                </View>
              </View>
            </Modal>
          </View>
        )}
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
