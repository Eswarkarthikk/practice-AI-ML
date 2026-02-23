/**
 * Bill Pay Screen - Swipe to pay functionality
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, Pressable, Alert, Animated, PanResponder } from 'react-native';
import { useRouter } from 'expo-router';
import { ScreenWrapper } from '@/components/ScreenWrapper';
import { GradientCard } from '@/components/GradientCard';
import { COLORS, SPACING, SHADOWS } from '@/lib/theme';
import { Ionicons } from '@expo/vector-icons';

export default function BillPayScreen() {
  const router = useRouter();
  const [selectedProvider, setSelectedProvider] = useState('');
  const [amount, setAmount] = useState('');
  const pan = new Animated.ValueXY();

  const panResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => true,
    onMoveShouldSetPanResponder: () => true,
    onPanResponderMove: (evt, gestureState) => {
      if (gestureState.dx > 0) {
        pan.x.setValue(gestureState.dx);
      }
    },
    onPanResponderRelease: (evt, gestureState) => {
      if (gestureState.dx > 150) {
        handlePayBill();
        pan.x.setValue(0);
      } else {
        Animated.spring(pan.x, { toValue: 0, useNativeDriver: false }).start();
      }
    },
  });

  const providers = [
    { id: 'electric', name: 'Electricity', icon: 'flash' as const },
    { id: 'water', name: 'Water', icon: 'water' as const },
    { id: 'internet', name: 'Internet', icon: 'wifi' as const },
    { id: 'mobile', name: 'Mobile', icon: 'call' as const },
  ];

  const handlePayBill = () => {
    if (!selectedProvider || !amount) {
      Alert.alert('Error', 'Please select provider and enter amount');
      return;
    }

    const provider = providers.find(p => p.id === selectedProvider);
    Alert.alert(
      'Payment Successful',
      `${provider?.name} bill paid: $${amount}`,
      [{ text: 'OK', onPress: () => router.back() }]
    );
  };

  return (
    <ScreenWrapper>
      <Text style={styles.title}>Pay Bills</Text>

      {/* Balance Card */}
      <GradientCard
        label="Available Balance"
        amount="$5,450.00"
        cardNumber="**** **** **** 3456"
        expiryDate="12/28"
        cardholderName="John Doe"
      />

      {/* Select Provider */}
      <Text style={styles.sectionTitle}>Select Provider</Text>
      <View style={styles.providersGrid}>
        {providers.map((provider) => (
          <Pressable
            key={provider.id}
            style={[
              styles.providerCard,
              selectedProvider === provider.id && styles.providerCardActive,
            ]}
            onPress={() => setSelectedProvider(provider.id)}
          >
            <View
              style={[
                styles.providerIcon,
                selectedProvider === provider.id && styles.providerIconActive,
              ]}
            >
              <Ionicons
                name={provider.icon}
                size={24}
                color={selectedProvider === provider.id ? '#FFFFFF' : COLORS.purpleMain}
              />
            </View>
            <Text
              style={[
                styles.providerName,
                selectedProvider === provider.id && styles.providerNameActive,
              ]}
            >
              {provider.name}
            </Text>
          </Pressable>
        ))}
      </View>

      {/* Amount Field */}
      <Text style={styles.sectionTitle}>Amount</Text>
      <View style={styles.amountInputContainer}>
        <Text style={styles.currencySymbol}>$</Text>
        <TextInput
          style={styles.amountInput}
          placeholder="0.00"
          placeholderTextColor={COLORS.textSecondary}
          value={amount}
          onChangeText={setAmount}
          keyboardType="decimal-pad"
        />
      </View>

      {/* Swipe to Pay Button */}
      <Animated.View
        style={[
          styles.swipeContainer,
          { transform: [{ translateX: pan.x }] },
        ]}
        {...panResponder.panHandlers}
      >
        <View style={styles.swipeButtonBackground} />
        <View style={styles.swipeContent}>
          <Ionicons name="arrow-forward" size={24} color="#FFFFFF" />
          <Text style={styles.swipeText}>Swipe for Payment</Text>
        </View>
      </Animated.View>

      <Text style={styles.hint}>← Swipe right to complete payment →</Text>
    </ScreenWrapper>
  );
}

import { TextInput } from 'react-native';

const styles = StyleSheet.create({
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.lg,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    marginTop: SPACING.lg,
  },
  providersGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: SPACING.xl,
  },
  providerCard: {
    width: '48%',
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    padding: SPACING.md,
    alignItems: 'center',
    marginBottom: SPACING.md,
    ...SHADOWS.soft,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  providerCardActive: {
    borderColor: COLORS.purpleMain,
    backgroundColor: 'rgba(108, 99, 255, 0.05)',
  },
  providerIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(108, 99, 255, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  providerIconActive: {
    backgroundColor: COLORS.purpleMain,
  },
  providerName: {
    fontSize: 12,
    fontWeight: '600',
    color: COLORS.textPrimary,
    textAlign: 'center',
  },
  providerNameActive: {
    color: COLORS.purpleMain,
  },
  amountInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.cardBg,
    borderRadius: 14,
    paddingHorizontal: SPACING.md,
    marginBottom: SPACING.xl,
    ...SHADOWS.soft,
  },
  currencySymbol: {
    fontSize: 24,
    fontWeight: '600',
    color: COLORS.purpleMain,
    marginRight: SPACING.sm,
  },
  amountInput: {
    flex: 1,
    height: 50,
    fontSize: 28,
    fontWeight: '600',
    color: COLORS.textPrimary,
  },
  swipeContainer: {
    height: 56,
    borderRadius: 28,
    overflow: 'hidden',
    marginBottom: SPACING.lg,
  },
  swipeButtonBackground: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: COLORS.purpleMain,
  },
  swipeContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: SPACING.md,
  },
  swipeText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  hint: {
    textAlign: 'center',
    fontSize: 12,
    color: COLORS.textSecondary,
    marginTop: SPACING.sm,
  },
});
