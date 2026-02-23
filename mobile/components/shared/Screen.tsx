import React from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  ViewStyle,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, PADDING } from '@/lib/theme';

interface ScreenProps {
  children: React.ReactNode;
  style?: ViewStyle;
  scroll?: boolean;
  noPadding?: boolean;
}

export const Screen: React.FC<ScreenProps> = ({
  children,
  style,
  scroll = false,
  noPadding = false,
}) => {
  const containerStyle = [
    styles.container,
    !noPadding && { paddingHorizontal: PADDING.horizontal },
    style,
  ];

  const content = (
    <View style={containerStyle}>
      {children}
    </View>
  );

  if (scroll) {
    return (
      <SafeAreaView style={styles.safeArea} edges={['top']}>
        <ScrollView
          contentContainerStyle={[
            !noPadding && { paddingHorizontal: PADDING.horizontal },
          ]}
          showsVerticalScrollIndicator={false}
        >
          <View style={containerStyle}>
            {children}
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      {content}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: COLORS.bgLight,
  },
  container: {
    flex: 1,
  },
});
