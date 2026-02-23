/**
 * Typography System - EHK Finance Tracker
 * Primary Font: Inter
 * Install: expo-font
 */

export const TYPOGRAPHY = {
  // Font Sizes
  mainBalance: 28,    // Large balance display
  screenTitle: 22,    // Screen titles (SemiBold)
  sectionTitle: 18,   // Section headers (SemiBold)
  body: 14,           // Body text
  small: 12,          // Small labels

  // Font Weights
  weights: {
    regular: "400" as const,
    medium: "500" as const,
    semibold: "600" as const,
    bold: "700" as const,
  },

  // Common Text Styles
  styles: {
    screenTitle: {
      fontSize: 22,
      fontWeight: "600" as const,
      lineHeight: 28,
    },
    sectionTitle: {
      fontSize: 18,
      fontWeight: "600" as const,
      lineHeight: 24,
    },
    body: {
      fontSize: 14,
      fontWeight: "400" as const,
      lineHeight: 20,
    },
    small: {
      fontSize: 12,
      fontWeight: "400" as const,
      lineHeight: 16,
    },
    mainBalance: {
      fontSize: 28,
      fontWeight: "700" as const,
      lineHeight: 32,
    },
  },
} as const;
