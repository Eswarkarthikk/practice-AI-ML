import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  StatusBar,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Screen } from '@/components/shared/Screen';
import { Input } from '@/components/shared/Input';
import { PrimaryButton } from '@/components/shared/PrimaryButton';
import { useApp } from '@/lib/context/AppContext';
import { COLORS, TYPOGRAPHY, SPACING, PADDING } from '@/lib/theme';

export default function ProfileSetupScreen() {
  const router = useRouter();
  const { setProfile } = useApp();
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSave = async () => {
    if (!name.trim()) {
      alert('Please enter your name');
      return;
    }

    setLoading(true);
    try {
      await setProfile({
        name: name.trim(),
        createdAt: Date.now(),
        lastUpdated: Date.now(),
      });
      router.push('/add-source' as any);
    } catch (error) {
      console.error('Error saving profile:', error);
      alert('Error saving profile');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Screen>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <View style={styles.content}>
        {/* Avatar Placeholder */}
        <View style={styles.avatarContainer}>
          <Text style={styles.avatarEmoji}>👤</Text>
        </View>

        {/* Name Input */}
        <View style={styles.formContainer}>
          <Text style={styles.label}>What's your name?</Text>
          <Input
            placeholder="Enter your full name"
            value={name}
            onChangeText={setName}
            style={{ marginBottom: SPACING.lg }}
          />

          {/* Save Button */}
          <PrimaryButton
            title="Continue"
            onPress={handleSave}
            loading={loading}
            gradient
          />
        </View>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: COLORS.cardBg,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  avatarEmoji: {
    fontSize: 40,
  },
  formContainer: {
    width: '100%',
  },
  label: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.lg,
    textAlign: 'center',
  },
});
