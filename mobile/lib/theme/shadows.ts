/**
 * Shadow System - EHK Finance Tracker
 * Soft shadows: opacity 0.05, radius 12, elevation 5
 */

import { StyleSheet } from "react-native";

export const SHADOWS = {
  // Default soft shadow for cards
  soft: {
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 5,
  },

  // Medium shadow for elevated content
  medium: {
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 8,
  },

  // Minimal shadow for subtle elements
  minimal: {
    shadowColor: "#000",
    shadowOpacity: 0.03,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
} as const;

export const SHADOW_STYLES = StyleSheet.create({
  soft: {
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 5,
  },
  medium: {
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 8,
  },
  minimal: {
    shadowColor: "#000",
    shadowOpacity: 0.03,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
});
