import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Modal,
  TextInput,
  FlatList,
} from 'react-native';
import { useGoal } from '@/lib/context/GoalContext';
import { COLORS, SPACING, SHADOWS } from '@/lib/theme';
import * as Haptics from 'expo-haptics';

export default function GoalsScreen() {
  const { goals, addGoal, deleteGoal, calculateRequiredMonthly } = useGoal();
  const [showModal, setShowModal] = useState(false);
  const [title, setTitle] = useState('');
  const [targetAmount, setTargetAmount] = useState('');
  const [deadline, setDeadline] = useState('');

  const handleAddGoal = async () => {
    if (title && targetAmount && deadline) {
      await addGoal({
        title,
        targetAmount: parseFloat(targetAmount),
        savedAmount: 0,
        deadline,
      });
      setTitle('');
      setTargetAmount('');
      setDeadline('');
      setShowModal(false);
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
  };

  const handleDeleteGoal = async (id: string) => {
    await deleteGoal(id);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const renderGoalItem = ({ item }: { item: any }) => {
    const progress = (item.savedAmount / item.targetAmount) * 100;
    const requiredMonthly = calculateRequiredMonthly ? calculateRequiredMonthly(item) : 0;

    return (
      <Pressable
        style={styles.goalCard}
        onLongPress={() => handleDeleteGoal(item.id)}
      >
        <View style={styles.goalHeader}>
          <View>
            <Text style={styles.goalTitle}>{item.title}</Text>
            <Text style={styles.goalDeadline}>By {formatDate(item.deadline)}</Text>
          </View>
          <Text style={styles.goalAmount}>₹{item.targetAmount.toFixed(0)}</Text>
        </View>

        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            <View
              style={[
                styles.progressFill,
                { width: `${Math.min(progress, 100)}%` },
              ]}
            />
          </View>
          <Text style={styles.progressText}>{progress.toFixed(0)}%</Text>
        </View>

        <View style={styles.goalStats}>
          <View>
            <Text style={styles.statLabel}>Saved</Text>
            <Text style={styles.statValue}>₹{item.savedAmount.toFixed(0)}</Text>
          </View>
          <View>
            <Text style={styles.statLabel}>Monthly Target</Text>
            <Text style={[styles.statValue, { color: '#F59E0B' }]}>
              ₹{requiredMonthly}
            </Text>
          </View>
        </View>

        <Text style={styles.hint}>Long press to delete</Text>
      </Pressable>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>🎯 Financial Goals</Text>
        <Text style={styles.headerSubtitle}>Track your savings targets</Text>
      </View>

      {goals.length === 0 ? (
        <ScrollView style={styles.scrollView} contentContainerStyle={styles.emptyContainer}>
          <Text style={styles.emptyIcon}>🎯</Text>
          <Text style={styles.emptyTitle}>No goals yet</Text>
          <Text style={styles.emptySubtitle}>
            Create a goal to start tracking your savings
          </Text>
          <Pressable
            style={styles.createButton}
            onPress={() => setShowModal(true)}
          >
            <Text style={styles.createButtonText}>+ Create First Goal</Text>
          </Pressable>
        </ScrollView>
      ) : (
        <FlatList
          data={goals}
          renderItem={renderGoalItem}
          keyExtractor={item => item.id}
          scrollEnabled={true}
          contentContainerStyle={styles.listContainer}
          ListHeaderComponent={
            <Pressable
              style={styles.addButton}
              onPress={() => setShowModal(true)}
            >
              <Text style={styles.addButtonText}>+ Add New Goal</Text>
            </Pressable>
          }
        />
      )}

      <Modal
        visible={showModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Create New Goal</Text>

            <TextInput
              style={styles.input}
              placeholder="Goal name (e.g., Emergency Fund)"
              value={title}
              onChangeText={setTitle}
              placeholderTextColor="#999"
            />

            <TextInput
              style={styles.input}
              placeholder="Target amount (₹)"
              keyboardType="decimal-pad"
              value={targetAmount}
              onChangeText={setTargetAmount}
              placeholderTextColor="#999"
            />

            <TextInput
              style={styles.input}
              placeholder="Target date (YYYY-MM-DD)"
              value={deadline}
              onChangeText={setDeadline}
              placeholderTextColor="#999"
            />

            <View style={styles.buttonGroup}>
              <Pressable
                style={styles.cancelButton}
                onPress={() => setShowModal(false)}
              >
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </Pressable>
              <Pressable
                style={styles.submitButton}
                onPress={handleAddGoal}
              >
                <Text style={styles.submitButtonText}>Create Goal</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  header: {
    backgroundColor: COLORS.purpleMain,
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 30,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#E2E8F0',
  },
  scrollView: {
    flex: 1,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  emptyIcon: {
    fontSize: 60,
    marginBottom: 20,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1E293B',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#64748B',
    textAlign: 'center',
    marginBottom: 24,
  },
  createButton: {
    backgroundColor: COLORS.purpleMain,
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 12,
  },
  createButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
  listContainer: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 20,
  },
  addButton: {
    backgroundColor: COLORS.purpleMain,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
    marginBottom: 16,
  },
  addButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
  goalCard: {
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
  },
  goalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  goalTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#1E293B',
    marginBottom: 4,
  },
  goalDeadline: {
    fontSize: 12,
    color: '#94A3B8',
  },
  goalAmount: {
    fontSize: 18,
    fontWeight: '700',
    color: COLORS.purpleMain,
  },
  progressContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    gap: 12,
  },
  progressBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#E2E8F0',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: COLORS.successGreen,
    borderRadius: 4,
  },
  progressText: {
    fontSize: 12,
    fontWeight: '700',
    color: COLORS.successGreen,
    minWidth: 30,
  },
  goalStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E2E8F0',
  },
  statLabel: {
    fontSize: 11,
    color: '#94A3B8',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 14,
    fontWeight: '700',
    color: '#1E293B',
  },
  hint: {
    fontSize: 11,
    color: '#CBD5E1',
    textAlign: 'center',
    marginTop: 12,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: COLORS.cardBg,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1E293B',
    marginBottom: 16,
  },
  input: {
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 14,
    marginBottom: 12,
    color: '#1E293B',
  },
  buttonGroup: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 16,
  },
  cancelButton: {
    flex: 1,
    borderWidth: 1,
    borderColor: COLORS.purpleMain,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: COLORS.purpleMain,
    fontSize: 14,
    fontWeight: '700',
  },
  submitButton: {
    flex: 1,
    backgroundColor: COLORS.purpleMain,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center',
  },
  submitButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
});
