/**
 * Add Credit Card Screen
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, Pressable, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { ScreenWrapper } from '@/components/ScreenWrapper';
import { GradientCard } from '@/components/GradientCard';
import { COLORS, SPACING } from '@/lib/theme';

export default function AddCreditCardScreen() {
  const router = useRouter();
  const [cardNumber, setCardNumber] = useState('');
  const [cardholderName, setCardholderName] = useState('');
  const [expiryDate, setExpiryDate] = useState('');
  const [cvv, setCvv] = useState('');

  const handleAddCard = () => {
    if (!cardNumber || !cardholderName || !expiryDate || !cvv) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    // Validate card number (basic check)
    if (cardNumber.length < 13) {
      Alert.alert('Error', 'Please enter a valid card number');
      return;
    }

    Alert.alert('Success', 'Card added successfully!', [
      {
        text: 'OK',
        onPress: () => router.back(),
      },
    ]);
  };

  const formatCardNumber = (text: string) => {
    const cleaned = text.replace(/\s+/g, '');
    const chunks = cleaned.match(/.{1,4}/g) || [];
    return chunks.join(' ').substring(0, 19);
  };

  return (
    <ScreenWrapper>
      <Text style={styles.title}>Add Credit Card</Text>

      {/* Card Preview */}
      <GradientCard
        label="New Card"
        amount=""
        cardNumber={
          cardNumber
            ? `**** **** **** ${cardNumber.slice(-4)}`
            : '**** **** **** ****'
        }
        expiryDate={expiryDate || 'MM/YY'}
        cardholderName={cardholderName || 'CARDHOLDER'}
      />

      {/* Form Inputs */}
      <View style={styles.form}>
        <TextInput
          style={styles.input}
          placeholder="Card Holder Name"
          placeholderTextColor={COLORS.textSecondary}
          value={cardholderName}
          onChangeText={setCardholderName}
        />

        <TextInput
          style={styles.input}
          placeholder="Card Number"
          placeholderTextColor={COLORS.textSecondary}
          value={cardNumber}
          onChangeText={(text) => setCardNumber(formatCardNumber(text))}
          keyboardType="numeric"
          maxLength={19}
        />

        <View style={styles.row}>
          <TextInput
            style={[styles.input, styles.halfInput]}
            placeholder="MM/YY"
            placeholderTextColor={COLORS.textSecondary}
            value={expiryDate}
            onChangeText={(text) => {
              // Auto-format MM/YY
              const cleaned = text.replace(/\D/g, '');
              if (cleaned.length >= 2) {
                setCvv(cleaned.substring(0, 2) + '/' + cleaned.substring(2, 4));
              } else {
                setExpiryDate(cleaned);
              }
            }}
            keyboardType="numeric"
            maxLength={5}
          />

          <TextInput
            style={[styles.input, styles.halfInput]}
            placeholder="CVV"
            placeholderTextColor={COLORS.textSecondary}
            value={cvv}
            onChangeText={setCvv}
            keyboardType="numeric"
            maxLength={4}
            secureTextEntry
          />
        </View>
      </View>

      {/* Continue Button */}
      <Pressable
        style={styles.button}
        onPress={handleAddCard}
        android_ripple={{ color: 'rgba(255,255,255,0.3)' }}
      >
        <Text style={styles.buttonText}>Add Card</Text>
      </Pressable>
    </ScreenWrapper>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: SPACING.lg,
  },
  form: {
    marginBottom: SPACING.xl,
  },
  input: {
    height: 50,
    borderRadius: 14,
    backgroundColor: '#F2F3F8',
    paddingHorizontal: SPACING.md,
    marginBottom: SPACING.md,
    fontSize: 14,
    color: COLORS.textPrimary,
    fontWeight: '500',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: SPACING.md,
  },
  halfInput: {
    flex: 1,
  },
  button: {
    height: 50,
    borderRadius: 18,
    backgroundColor: COLORS.purpleMain,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: SPACING.lg,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
});
