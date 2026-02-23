import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  TouchableOpacity,
  Alert,
  StatusBar,
  Share,
} from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Card } from '@/components/shared/CardComponent';
import { FooterNavigation } from '@/components/FooterNavigation';
import { useApp } from '@/lib/context/AppContext';
import { storage } from '@/lib/utils/storage';
import { COLORS, TYPOGRAPHY, SPACING, PADDING, BORDER_RADIUS, SHADOWS } from '@/lib/theme';

export default function SettingsScreen() {
  const router = useRouter();
  const { resetAllData, transactions, budgets, goals } = useApp();
  const [loading, setLoading] = useState(false);

  const handleExportData = async () => {
    try {
      setLoading(true);
      const data = await storage.exportData();
      const jsonString = JSON.stringify(data, null, 2);

      await Share.share({
        message: jsonString,
        title: 'EHK Finance Backup',
      });

      Alert.alert('Success', 'Data exported successfully!');
    } catch (error) {
      console.error('Export error:', error);
      Alert.alert('Error', 'Failed to export data');
    } finally {
      setLoading(false);
    }
  };

  const handleResetData = () => {
    Alert.alert(
      'Reset All Data',
      'This will permanently delete all transactions, budgets, and goals. This action cannot be undone.',
      [
        {
          text: 'Cancel',
          onPress: () => {},
          style: 'cancel',
        },
        {
          text: 'Reset',
          onPress: async () => {
            try {
              setLoading(true);
              await resetAllData();
              router.replace('/(tabs)');
            } catch (error) {
              Alert.alert('Error', 'Failed to reset data');
            } finally {
              setLoading(false);
            }
          },
          style: 'destructive',
        },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.bgLight} />

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Settings & Data</Text>
        </View>

        {/* Data Management Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Data Management</Text>

          <SettingItem
            icon="download-outline"
            label="Export Data"
            description="Download all your data as JSON"
            onPress={handleExportData}
          />
        </View>

        {/* App Stats Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your Data</Text>

          <View style={styles.statsGrid}>
            <StatBox
              icon="swap-horizontal"
              label="Transactions"
              value={transactions.length.toString()}
            />
            <StatBox
              icon="wallet"
              label="Budgets"
              value={budgets.length.toString()}
            />
            <StatBox
              icon="flag"
              label="Goals"
              value={goals.length.toString()}
            />
          </View>
        </View>

        {/* About Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>About</Text>

          <Card style={styles.aboutCard}>
            <Text style={styles.aboutTitle}>EHK Finance Tracker</Text>
            <Text style={styles.aboutVersion}>Version 1.0.0</Text>
            <Text style={styles.aboutDescription}>
              A modern fintech-style personal finance app to help you track income, expenses, manage budgets, and reach your financial goals.
            </Text>
          </Card>
        </View>

        {/* Danger Zone Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: COLORS.dangerRed }]}>Danger Zone</Text>

          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleResetData}
            disabled={loading}
            style={styles.dangerButton}
          >
            <View style={styles.dangerContent}>
              <Ionicons name="trash-outline" size={20} color={COLORS.dangerRed} />
              <View style={styles.dangerTextContainer}>
                <Text style={styles.dangerLabel}>Reset All Data</Text>
                <Text style={styles.dangerDescription}>
                  Permanently delete all data
                </Text>
              </View>
            </View>
            <Ionicons name="chevron-forward" size={20} color={COLORS.dangerRed} />
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Footer Navigation */}
      <FooterNavigation activeTab="settings" />
    </View>
  );
}

interface SettingItemProps {
  icon: string;
  label: string;
  description: string;
  onPress: () => void;
}

const SettingItem: React.FC<SettingItemProps> = ({
  icon,
  label,
  description,
  onPress,
}) => {
  return (
    <TouchableOpacity activeOpacity={0.7} onPress={onPress} style={styles.settingItem}>
      <View style={styles.settingLeftContent}>
        <Ionicons name={icon as any} size={20} color={COLORS.purpleMain} style={styles.settingIcon} />
        <View>
          <Text style={styles.settingLabel}>{label}</Text>
          <Text style={styles.settingDescription}>{description}</Text>
        </View>
      </View>
      <Ionicons name="chevron-forward" size={20} color={COLORS.textSecondary} />
    </TouchableOpacity>
  );
};

interface StatBoxProps {
  icon: string;
  label: string;
  value: string;
}

const StatBox: React.FC<StatBoxProps> = ({ icon, label, value }) => {
  return (
    <Card style={{ ...styles.statBox, ...SHADOWS.soft }}>
      <Ionicons name={icon as any} size={24} color={COLORS.purpleMain} style={styles.statIcon} />
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </Card>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  scrollContent: {
    paddingHorizontal: PADDING.horizontal,
    paddingVertical: SPACING.lg,
    paddingBottom: 100,
  },
  header: {
    marginBottom: SPACING.lg,
  },
  title: {
    ...TYPOGRAPHY.styles.screenTitle,
    color: COLORS.textPrimary,
    fontSize: 26,
    fontWeight: '700',
  },
  section: {
    marginBottom: SPACING.xl,
  },
  sectionTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.md,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: COLORS.cardBg,
    borderRadius: BORDER_RADIUS.medium,
    padding: SPACING.md,
    marginBottom: SPACING.md,
    ...SHADOWS.soft,
  },
  settingLeftContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingIcon: {
    marginRight: SPACING.md,
  },
  settingLabel: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textPrimary,
    fontWeight: '600',
    marginBottom: SPACING.xs,
  },
  settingDescription: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
  },
  statsGrid: {
    flexDirection: 'row',
    gap: SPACING.md,
  },
  statBox: {
    flex: 1,
    padding: SPACING.md,
    alignItems: 'center',
  },
  statIcon: {
    marginBottom: SPACING.sm,
  },
  statValue: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.purpleMain,
    fontWeight: '700',
  },
  statLabel: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginTop: SPACING.xs,
  },
  aboutCard: {
    padding: SPACING.lg,
  },
  aboutTitle: {
    ...TYPOGRAPHY.styles.sectionTitle,
    color: COLORS.textPrimary,
    marginBottom: SPACING.xs,
  },
  aboutVersion: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textSecondary,
    marginBottom: SPACING.md,
  },
  aboutDescription: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.textSecondary,
    lineHeight: 20,
  },
  dangerButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: COLORS.dangerRed + '10',
    borderRadius: BORDER_RADIUS.medium,
    borderWidth: 1,
    borderColor: COLORS.dangerRed + '40',
    padding: SPACING.md,
  },
  dangerContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  dangerTextContainer: {
    marginLeft: SPACING.md,
    flex: 1,
  },
  dangerLabel: {
    ...TYPOGRAPHY.styles.body,
    color: COLORS.dangerRed,
    fontWeight: '600',
    marginBottom: SPACING.xs,
  },
  dangerDescription: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.dangerRed,
    opacity: 0.8,
  },
});
