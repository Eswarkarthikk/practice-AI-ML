/**
 * Spacing System - EHK Finance Tracker
 * Consistent spacing scale: 4, 8, 16, 24, 32
 */

export const SPACING = {
  xs: 4,      // Extra small
  sm: 8,      // Small
  md: 16,     // Medium (default)
  lg: 24,     // Large
  xl: 32,     // Extra Large
} as const;

export const PADDING = {
  horizontal: 20,           // Screen horizontal padding
  vertical: SPACING.lg,     // Standard vertical
  card: SPACING.lg,         // Inside cards
  button: {
    horizontal: SPACING.lg,
    vertical: SPACING.md,
  },
  input: {
    horizontal: SPACING.md,
    vertical: SPACING.sm,
  },
} as const;
