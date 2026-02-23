import React, { useEffect, useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Modal,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import DateTimePicker from '@react-native-community/datetimepicker';
import { Screen } from '@/components/shared/Screen';
import { Input } from '@/components/shared/Input';
import { PrimaryButton } from '@/components/shared/PrimaryButton';
import { Card } from '@/components/shared/CardComponent';
import { useApp } from '@/lib/context/AppContext';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS } from '@/lib/theme';

type TransactionType = 'income' | 'expense';

const INCOME_SOURCES = ['salary', 'friend', 'freelance'];

export default function AddTransactionScreen() {
  const router = useRouter();
  const { addTransaction, updateTransaction, sources, categories, transactions } = useApp();
  const { id } = useLocalSearchParams();

  const [type, setType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState(categories[0]?.id || 'food');
  const [source, setSource] = useState(sources[0]?.id || '');
  const [date, setDate] = useState<Date>(new Date());
  const [note, setNote] = useState('');
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [showSourceModal, setShowSourceModal] = useState(false);

  const handleAddTransaction = async () => {
    if (!amount.trim() || !source) {
      alert('Please fill in all required fields');
      return;
    }

    const parsed = parseFloat(amount);
    if (Number.isNaN(parsed) || parsed <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    setLoading(true);
    const payload = {
      amount: parsed,
      category,
      type,
      source,
      description: note?.trim() ? note.trim() : category,
      // store date as YYYY-MM-DD to match Transaction type expectations
      date: date.toISOString().split('T')[0],
      note,
    } as any;

    try {
      if (isEditMode && editingId) {
        await updateTransaction(editingId, payload);
        alert('Transaction updated successfully!');
      } else {
        await addTransaction(payload);
        alert('Transaction added successfully!');
      }
      router.back();
    } catch (error) {
      console.error('Error saving transaction:', error);
      alert('Error saving transaction');
    } finally {
      setLoading(false);
    }
  };

  const getCategoryName = (id: string) => {
    const cat = categories.find((c) => c.id === id);
    return cat ? `${cat.icon} ${cat.name}` : 'Select category';
  };

  const getSourceName = (id: string) => {
    const src = sources.find((s) => s.id === id);
    return src ? src.name : 'Select source';
  };

  const formattedDate = date.toISOString().split('T')[0];

  useEffect(() => {
    if (id) {
      const tx = transactions.find((t) => t.id === id);
      if (tx) {
        setIsEditMode(true);
        setEditingId(tx.id);
        setAmount(String(tx.amount));
        setType(tx.type as TransactionType);
        setCategory(tx.category || categories[0]?.id || '');
        setSource(tx.source || sources[0]?.id || '');
        setDate(tx.date ? new Date(tx.date) : new Date());
        setNote(tx.note || '');
      }
    }
  }, [id, transactions]);

  useEffect(() => {
    // ensure category state aligns with selected type
    if (type === 'income') {
      setCategory((prev) => (INCOME_SOURCES.includes(prev) ? prev : INCOME_SOURCES[0]));
    } else {
      setCategory((prev) => (categories.find((c) => c.id === prev) ? prev : categories[0]?.id || ''));
    }
  }, [type, categories]);

  return (
    <Screen scroll>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Ionicons name="chevron-back" size={28} color={COLORS.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.title}>Add Transaction</Text>
        <View style={{ width: 28 }} />
      </View>

      {/* Transaction Type Selector */}
      <View style={styles.typeSelector}>
        <TouchableOpacity
          onPress={() => setType('expense')}
          style={[
            styles.typeButton,
            type === 'expense' && styles.typeButtonActive,
          ]}
        >
          <Text
            style={[
              styles.typeButtonText,
              type === 'expense' && styles.typeButtonTextActive,
            ]}
          >
            Expense
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => setType('income')}
          style={[
            styles.typeButton,
            type === 'income' && styles.typeButtonActive,
          ]}
        >
          <Text
            style={[
              styles.typeButtonText,
              type === 'income' && styles.typeButtonTextActive,
            ]}
          >
            Income
          </Text>
        </TouchableOpacity>
      </View>

      {/* Amount Input */}
      <Input
        label="Amount"
        placeholder="0.00"
        value={amount}
        onChangeText={setAmount}
        keyboardType="numeric"
        style={{ marginBottom: SPACING.lg }}
      />

      {/* Conditional fields */}
      {type === 'income' ? (
        <>
          <View style={{ marginBottom: SPACING.lg }}>
            <Text style={styles.label}>Income Source*</Text>
            <TouchableOpacity
              onPress={() => setShowCategoryModal(true)}
              style={styles.selectButton}
            >
              <Text style={styles.selectButtonText}>{category || 'Select source'}</Text>
              <Ionicons name="chevron-down" size={20} color={COLORS.textSecondary} />
            </TouchableOpacity>
          </View>

          <View style={{ marginBottom: SPACING.lg }}>
            <Text style={styles.label}>Deposit To*</Text>
            <TouchableOpacity
              onPress={() => setShowSourceModal(true)}
              style={styles.selectButton}
            >
              <Text style={styles.selectButtonText}>{getSourceName(source)}</Text>
              <Ionicons name="chevron-down" size={20} color={COLORS.textSecondary} />
            </TouchableOpacity>
          </View>
        </>
      ) : (
        <>
          <View style={{ marginBottom: SPACING.lg }}>
            <Text style={styles.label}>Category*</Text>
            <TouchableOpacity
              onPress={() => setShowCategoryModal(true)}
              style={styles.selectButton}
            >
              <Text style={styles.selectButtonText}>{getCategoryName(category)}</Text>
              <Ionicons name="chevron-down" size={20} color={COLORS.textSecondary} />
            </TouchableOpacity>
          </View>

          <View style={{ marginBottom: SPACING.lg }}>
            <Text style={styles.label}>From*</Text>
            <TouchableOpacity
              onPress={() => setShowSourceModal(true)}
              style={styles.selectButton}
            >
              <Text style={styles.selectButtonText}>{getSourceName(source)}</Text>
              <Ionicons name="chevron-down" size={20} color={COLORS.textSecondary} />
            </TouchableOpacity>
          </View>
        </>
      )}

      {/* Date Input with calendar icon */}
      <View style={{ marginBottom: SPACING.lg, position: 'relative' }}>
        <Input
          label="Date"
          placeholder="YYYY-MM-DD"
          value={formattedDate}
          editable={false}
          style={{ paddingRight: 48 }}
        />

        <TouchableOpacity
          style={styles.dateIcon}
          onPress={() => setShowDatePicker(true)}
        >
          <Ionicons name="calendar-outline" size={22} color={COLORS.purpleMain} />
        </TouchableOpacity>
      </View>

      {showDatePicker && (
        <DateTimePicker
          value={date}
          mode="date"
          display="default"
          onChange={(event: any, selectedDate?: Date) => {
            setShowDatePicker(false);
            if (selectedDate) setDate(selectedDate);
          }}
        />
      )}

      {/* Note Input */}
      <Input
        label="Note"
        placeholder="Add a note (optional)"
        value={note}
        onChangeText={setNote}
        multiline
        numberOfLines={3}
        style={{ marginBottom: SPACING.xl }}
      />

      {/* Add Button */}
      <PrimaryButton
        title={isEditMode ? 'Update Transaction' : 'Add Transaction'}
        onPress={handleAddTransaction}
        loading={loading}
        gradient
        style={{ marginBottom: SPACING.lg }}
      />

      {/* Category Modal */}
      <Modal
        visible={showCategoryModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowCategoryModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Category</Text>
              <TouchableOpacity onPress={() => setShowCategoryModal(false)}>
                <Ionicons name="close" size={24} color={COLORS.textPrimary} />
              </TouchableOpacity>
            </View>
            <ScrollView style={styles.modalList}>
              {type === 'income'
                ? INCOME_SOURCES.map((s) => (
                    <TouchableOpacity
                      key={s}
                      onPress={() => {
                        setCategory(s);
                        setShowCategoryModal(false);
                      }}
                      style={[
                        styles.modalItem,
                        category === s && styles.modalItemActive,
                      ]}
                    >
                      <Text
                        style={[
                          styles.modalItemText,
                          category === s && styles.modalItemTextActive,
                        ]}
                      >
                        {s}
                      </Text>
                    </TouchableOpacity>
                  ))
                : categories.map((cat) => (
                    <TouchableOpacity
                      key={cat.id}
                      onPress={() => {
                        setCategory(cat.id);
                        setShowCategoryModal(false);
                      }}
                      style={[
                        styles.modalItem,
                        category === cat.id && styles.modalItemActive,
                      ]}
                    >
                      <Text style={styles.modalItemIcon}>{cat.icon}</Text>
                      <Text
                        style={[
                          styles.modalItemText,
                          category === cat.id && styles.modalItemTextActive,
                        ]}
                      >
                        {cat.name}
                      </Text>
                    </TouchableOpacity>
                  ))}
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Source Modal */}
      <Modal
        visible={showSourceModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowSourceModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Source</Text>
              <TouchableOpacity onPress={() => setShowSourceModal(false)}>
                <Ionicons name="close" size={24} color={COLORS.textPrimary} />
              </TouchableOpacity>
            </View>
            <ScrollView style={styles.modalList}>
              {sources.map((src) => (
                <TouchableOpacity
                  key={src.id}
                  onPress={() => {
                    setSource(src.id);
                    setShowSourceModal(false);
                  }}
                  style={[
                    styles.modalItem,
                    source === src.id && styles.modalItemActive,
                  ]}
                >
                  <Ionicons
                    name="wallet-outline"
                    size={20}
                    color={source === src.id ? COLORS.purpleMain : COLORS.textSecondary}
                  />
                  <Text
                    style={[
                      styles.modalItemText,
                      source === src.id && styles.modalItemTextActive,
                    ]}
                  >
                    {src.name} ({src.type})
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        </View>
      </Modal>
    </Screen>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.lg,
  },
  title: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    fontSize: 24,
  },
  typeSelector: {
    flexDirection: 'row',
    gap: SPACING.md,
    marginBottom: SPACING.lg,
  },
  typeButton: {
    flex: 1,
    paddingVertical: SPACING.md,
    borderRadius: BORDER_RADIUS.medium,
    borderWidth: 1.5,
    borderColor: COLORS.borderColor,
    justifyContent: 'center',
    alignItems: 'center',
  },
  typeButtonActive: {
    backgroundColor: COLORS.purpleMain,
    borderColor: COLORS.purpleMain,
  },
  typeButtonText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textSecondary,
    fontWeight: '600',
  },
  typeButtonTextActive: {
    color: COLORS.cardBg,
  },
  label: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
    fontWeight: '600',
  },
  selectButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: COLORS.bgLight,
    borderRadius: BORDER_RADIUS.medium,
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.md,
    borderColor: COLORS.borderColor,
    borderWidth: 1,
  },
  selectButtonText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: COLORS.cardBg,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: '70%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: PADDING.horizontal,
    paddingVertical: SPACING.lg,
    borderBottomColor: COLORS.borderColor,
    borderBottomWidth: 1,
  },
  modalTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
  },
  modalList: {
    paddingHorizontal: PADDING.horizontal,
  },
  modalItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.md,
    borderBottomColor: COLORS.borderColor,
    borderBottomWidth: 1,
  },
  modalItemActive: {},
  modalItemIcon: {
    fontSize: 24,
    marginRight: SPACING.md,
  },
  modalItemText: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    flex: 1,
  },
  modalItemTextActive: {
    color: COLORS.purpleMain,
    fontWeight: '600',
  },
  dateIcon: {
    position: 'absolute',
    right: 15,
    top: 40,
  },
});
