import React from 'react';
import {
  View,
  StyleSheet,
  TouchableOpacity,
  Text,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { COLORS, FOOTER, FAB, ICON_SIZES, TYPOGRAPHY, BORDER_RADIUS, SHADOWS } from '@/lib/theme';

interface FooterNavigationProps {
  activeTab?: 'home' | 'settings';
}

export const FooterNavigation: React.FC<FooterNavigationProps> = ({ activeTab = 'home' }) => {
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const handleHomePress = () => {
    router.push('/(tabs)');
  };

  const handleSettingsPress = () => {
    router.push('/(tabs)/settings');
  };

  const handleAIPress = () => {
    // TODO: implement AI action (analytics, insights, or shortcut)
  };

  return (
    <View style={[styles.container, { paddingBottom: insets.bottom }]}>
      {/* Footer Background */}
      <View style={styles.footerBar}>
        {/* Home Button */}
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={handleHomePress}
          style={styles.navButton}
        >
          <Ionicons
            name="home-outline"
            size={ICON_SIZES.tab}
            color={
              activeTab === 'home' ? COLORS.purpleMain : COLORS.textSecondary
            }
          />
          {activeTab === 'home' && <Text style={styles.activeIndicator}>●</Text>}
        </TouchableOpacity>

        {/* Spacer for AI button */}
        <View style={{ flex: 1 }} />

        {/* Settings Button */}
        <TouchableOpacity
          activeOpacity={0.7}
          onPress={handleSettingsPress}
          style={styles.navButton}
        >
          <Ionicons
            name="settings-outline"
            size={ICON_SIZES.tab}
            color={
              activeTab === 'settings' ? COLORS.purpleMain : COLORS.textSecondary
            }
          />
          {activeTab === 'settings' && <Text style={styles.activeIndicator}>●</Text>}
        </TouchableOpacity>
      </View>

      {/* Floating AI Button */}
      <TouchableOpacity
        activeOpacity={0.8}
        onPress={handleAIPress}
        style={[styles.fabButton, SHADOWS.medium]}
      >
        <MaterialCommunityIcons
          name="brain"
          size={FAB.iconSize}
          color={FAB.iconColor}
        />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  footerBar: {
    flexDirection: 'row',
    height: FOOTER.height,
    backgroundColor: FOOTER.backgroundColor,
    width: '100%',
    borderTopLeftRadius: FOOTER.borderTopRadius,
    borderTopRightRadius: FOOTER.borderTopRadius,
    alignItems: 'center',
    paddingHorizontal: 20,
    ...SHADOWS.soft,
  },
  navButton: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 12,
  },
  activeIndicator: {
    marginTop: 4,
    fontSize: 8,
    color: COLORS.purpleMain,
  },
  fabButton: {
    position: 'absolute',
    bottom: FOOTER.height / 2 - FAB.size / 2,
    width: FAB.size,
    height: FAB.size,
    borderRadius: FAB.borderRadius,
    backgroundColor: FAB.backgroundColor,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
