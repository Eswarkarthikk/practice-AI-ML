/**
 * Verification Screen - OTP/Verification UI
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, Pressable, TextInput } from 'react-native';
import { useRouter } from 'expo-router';
import { ScreenWrapper } from '@/components/ScreenWrapper';
import { COLORS, SPACING } from '@/lib/theme';
import { Ionicons } from '@expo/vector-icons';

export default function VerificationScreen() {
  const router = useRouter();
  const [otp, setOtp] = useState(['', '', '', '']);

  const handleOtpChange = (text: string, index: number) => {
    const newOtp = [...otp];
    newOtp[index] = text;
    setOtp(newOtp);
  };

  const handleVerify = () => {
    const otpCode = otp.join('');
    if (otpCode.length !== 4) {
      alert('Please enter all digits');
      return;
    }
    alert('Verified successfully!');
    router.back();
  };

  return (
    <ScreenWrapper scrollEnabled={false}>
      <View style={styles.container}>
        {/* Illustration */}
        <View style={styles.illustrationContainer}>
          <Ionicons
            name="shield-checkmark"
            size={80}
            color={COLORS.purpleMain}
          />
        </View>

        {/* Title */}
        <Text style={styles.title}>Verify Your Identity</Text>

        {/* Description */}
        <Text style={styles.description}>
          We've sent a 4-digit code to your registered email. Please enter it below to verify.
        </Text>

        {/* OTP Input Fields */}
        <View style={styles.otpContainer}>
          {otp.map((digit, index) => (
            <TextInput
              key={index}
              style={styles.otpInput}
              placeholder="0"
              placeholderTextColor={COLORS.textSecondary}
              maxLength={1}
              keyboardType="numeric"
              value={digit}
              onChangeText={(text) => handleOtpChange(text, index)}
              textAlign="center"
            />
          ))}
        </View>

        {/* Resend Code Link */}
        <View style={styles.resendContainer}>
          <Text style={styles.resendText}>Didn't receive code?</Text>
          <Pressable onPress={() => alert('Code resent!')}>
            <Text style={styles.resendLink}>Resend</Text>
          </Pressable>
        </View>

        {/* Verify Button */}
        <Pressable
          style={styles.button}
          onPress={handleVerify}
          android_ripple={{ color: 'rgba(255,255,255,0.3)' }}
        >
          <Text style={styles.buttonText}>Verify</Text>
        </Pressable>
      </View>
    </ScreenWrapper>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: SPACING.lg,
  },
  illustrationContainer: {
    marginBottom: SPACING.xl,
    padding: SPACING.xl,
    backgroundColor: 'rgba(108, 99, 255, 0.1)',
    borderRadius: 50,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    textAlign: 'center',
  },
  description: {
    fontSize: 14,
    color: COLORS.textSecondary,
    textAlign: 'center',
    marginBottom: SPACING.xl,
    lineHeight: 20,
  },
  otpContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: SPACING.md,
    marginBottom: SPACING.xl,
  },
  otpInput: {
    width: 50,
    height: 50,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: COLORS.purpleMain,
    fontSize: 24,
    fontWeight: '600',
    color: COLORS.textPrimary,
    backgroundColor: COLORS.cardBg,
  },
  resendContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: SPACING.sm,
    marginBottom: SPACING.xl,
  },
  resendText: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  resendLink: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.purpleMain,
  },
  button: {
    width: '100%',
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
