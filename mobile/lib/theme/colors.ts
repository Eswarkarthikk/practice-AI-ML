/**
 * Color System - EHK Finance Tracker
 * Soft fintech-style color palette
 */

export const COLORS = {
  // Primary
  purpleMain: "#6C63FF",
  purpleLight: "#8E7CFF",

  // Status
  successGreen: "#2ECC71",
  dangerRed: "#FF5A5F",

  // Backgrounds
  bgLight: "#F6F7FB",
  cardBg: "#FFFFFF",

  // Text
  textPrimary: "#1E1E2D",
  textSecondary: "#8A8FA3",

  // Borders
  borderColor: "#E6E8F0",
  // Warnings
  warningOrange: "#FFB84D",

  // Category Colors
  categories: {
    food: "#FF6B6B",
    transport: "#4ECDC4",
    entertainment: "#FFD93D",
    shopping: "#FF8BB1",
    bills: "#6C63FF",
    health: "#2ECC71",
    other: "#95A5A6",
  },
} as const;
