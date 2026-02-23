import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  StatusBar,
  TouchableOpacity,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Screen } from '@/components/shared/Screen';
import { Input } from '@/components/shared/Input';
import { PrimaryButton } from '@/components/shared/PrimaryButton';
import { Card } from '@/components/shared/CardComponent';
import { useApp } from '@/lib/context/AppContext';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS } from '@/lib/theme';

type SourceType = 'Bank' | 'Cash' | 'Other';

export default function AddSourceScreen() {
  const router = useRouter();
  const { addSource, sources } = useApp();
  const [sourceName, setSourceName] = useState('');
  const [startingAmount, setStartingAmount] = useState('');
  const [sourceType, setSourceType] = useState<SourceType>('Bank');
  const [loading, setLoading] = useState(false);

  const handleAddSource = async () => {
    if (!sourceName.trim() || !startingAmount.trim()) {
      alert('Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      await addSource(sourceName.trim(), sourceType, parseFloat(startingAmount));
      setSourceName('');
      setStartingAmount('');
      alert('Source added successfully!');
    } catch (error) {
      console.error('Error adding source:', error);
      alert('Error adding source');
    } finally {
      setLoading(false);
    }
  };

  const handleContinue = () => {
    if (sources.length === 0) {
      alert('Please add at least one source');
      return;
    }
    router.push('/(tabs)');
  };

  return (
    <Screen scroll>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <View style={styles.header}>
        <Text style={styles.title}>Add Your First Source</Text>
        <Text style={styles.subtitle}>
          Track your money from different sources
        </Text>
      </View>

      <View style={styles.content}>
        {/* Source Type Selector */}
        <Text style={styles.sectionTitle}>Source Type</Text>
        <View style={styles.typeSelector}>
          {(['Bank', 'Cash', 'Other'] as SourceType[]).map((type) => (
            <TouchableOpacity
              key={type}
              onPress={() => setSourceType(type)}
              style={[
                styles.typeButton,
                sourceType === type && styles.typeButtonActive,
              ]}
            >
              <Text
                style={[
                  styles.typeButtonText,
                  sourceType === type && styles.typeButtonTextActive,
                ]}
              >
                {type}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Source Name Input */}
        <Input
          label="Source Name"
          placeholder={`Enter ${sourceType.toLowerCase()} name`}
          value={sourceName}
          onChangeText={setSourceName}
          style={{ marginBottom: SPACING.lg }}
        />

        {/* Starting Amount Input */}
        <Input
          label="Starting Amount"
          placeholder="Enter amount"
          value={startingAmount}
          onChangeText={setStartingAmount}
          keyboardType="numeric"
          style={{ marginBottom: SPACING.lg }}
        />

        {/* Add Source Button */}
        <PrimaryButton
          title="Add Source"
          onPress={handleAddSource}
          loading={loading}
          gradient
          style={{ marginBottom: SPACING.lg }}
        />

        {/* Added Sources List */}
        {sources.length > 0 && (
          <View>
            <Text style={styles.sectionTitle}>Added Sources</Text>
            {sources.map((source) => (
              <Card key={source.id} style={{ marginBottom: SPACING.md }}>
                <View style={styles.sourceItem}>
                  <View>
                    <Text style={styles.sourceName}>{source.name}</Text>
                    <Text style={styles.sourceType}>{source.type}</Text>
                  </View>
                  <Text style={styles.sourceAmount}>
                    ${source.startingAmount.toFixed(2)}
                  </Text>
                </View>
              </Card>
            ))}
          </View>
        )}
      </View>

      {/* Continue Button */}
      {sources.length > 0 && (
        <View style={styles.continueButton}>
          <PrimaryButton
            title="Continue to Home"
            onPress={handleContinue}
            gradient
          />
        </View>
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  header: {
    marginBottom: SPACING.xl,
  },
  title: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
    fontSize: 26,
  },
  subtitle: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textSecondary,
  },
  content: {
    paddingBottom: SPACING.xl,
  },
  sectionTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
    marginTop: SPACING.lg,
  },
  typeSelector: {
    flexDirection: 'row',
    marginBottom: SPACING.lg,
    gap: SPACING.md,
  },
  typeButton: {
    flex: 1,
    paddingVertical: SPACING.md,
    paddingHorizontal: SPACING.md,
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
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    fontWeight: '600',
  },
  typeButtonTextActive: {
    color: COLORS.cardBg,
  },
  sourceItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  sourceName: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
    marginBottom: SPACING.sm,
  },
  sourceType: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  sourceAmount: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.purpleMain,
    fontWeight: '700',
  },
  continueButton: {
    paddingBottom: SPACING.xl,
  },
});
