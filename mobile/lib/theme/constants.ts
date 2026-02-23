/**
 * Design Constants - EHK Finance Tracker
 */

import { COLORS } from './colors';
import { SPACING } from './spacing';
import { SHADOWS } from './shadows';

export const BORDER_RADIUS = {
  small: 12,        // Small elements
  medium: 16,       // Buttons, inputs
  card: 24,         // Cards (large rounded)
  large: 24,        // Large sections
  full: 9999,       // Circles
} as const;

export const ICON_SIZES = {
  tab: 24,          // Navigation tabs
  fab: 28,          // FAB icon
  small: 16,
  medium: 24,
  large: 32,
} as const;

export const ANIMATION = {
  duration: {
    fast: 150,
    medium: 300,
    slow: 500,
  },
  scale: {
    press: 0.95,
  },
} as const;

export const FOOTER = {
  height: 70,
  borderTopRadius: 24,
  backgroundColor: COLORS.cardBg,
} as const;

export const FAB = {
  size: 60,
  borderRadius: 30,
  backgroundColor: COLORS.purpleMain,
  iconSize: ICON_SIZES.fab,
  iconColor: COLORS.cardBg,
} as const;

export const INPUT = {
  height: 50,
  borderRadius: BORDER_RADIUS.medium,
  paddingHorizontal: SPACING.md,
  backgroundColor: COLORS.bgLight,
  borderColor: COLORS.borderColor,
} as const;

export const BUTTON = {
  height: 50,
  borderRadius: 18,
  paddingHorizontal: SPACING.lg,
} as const;
