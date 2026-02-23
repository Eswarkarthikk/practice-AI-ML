// Haptic Feedback Utilities

import * as Haptics from 'expo-haptics';

export const HapticFeedback = {
  /**
   * Light tap feedback
   */
  light: async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Medium impact feedback
   */
  medium: async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Heavy impact feedback
   */
  heavy: async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Success feedback
   */
  success: async () => {
    try {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Warning feedback
   */
  warning: async () => {
    try {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Error feedback
   */
  error: async () => {
    try {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Selection feedback (light)
   */
  selection: async () => {
    try {
      await Haptics.selectionAsync();
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },

  /**
   * Impact with intensity
   */
  impact: async (style: 'light' | 'medium' | 'heavy' = 'medium') => {
    try {
      const styleMap = {
        light: Haptics.ImpactFeedbackStyle.Light,
        medium: Haptics.ImpactFeedbackStyle.Medium,
        heavy: Haptics.ImpactFeedbackStyle.Heavy,
      };
      await Haptics.impactAsync(styleMap[style]);
    } catch (error) {
      console.warn('Haptic feedback not available:', error);
    }
  },
};
