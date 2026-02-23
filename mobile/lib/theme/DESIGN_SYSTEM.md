/**
 * DESIGN SYSTEM DOCUMENTATION
 * "Soft Neumorphic Fintech Minimal" Style Guide
 * 
 * This file documents all design decisions and provides examples for consistency.
 */

/** ============================================================================
 * 1. COLOR SYSTEM
 * ============================================================================ */

/**
 * Primary Colors:
 * - primary: #6C63FF (Main Purple) - Use for primary CTAs, highlights
 * - secondary: #4ECDC4 (Teal Accent) - Secondary actions, decorative elements
 * 
 * Status Colors:
 * - success: #2ECC71 (Green) - Income, positive actions
 * - danger: #FF5A5F (Red) - Expenses, warnings, deletions
 * - warning: #F5A623 (Orange) - Alerts, cautions
 * 
 * Background:
 * - background: #F6F7FB (Light Gray) - Screen backgrounds
 * - card: #FFFFFF (White) - Card and surface backgrounds
 * 
 * Text:
 * - textPrimary: #1E1E2D (Dark) - Primary text
 * - textSecondary: #7A7A8C (Gray) - Secondary text, labels
 * 
 * Other:
 * - border: #E6E8F0 (Light Gray) - Borders and dividers
 * 
 * Dark Mode:
 * - background: #121212
 * - card: #1E1E2D
 * - textPrimary: #FFFFFF
 * - textSecondary: #B0B0B0
 * 
 * Usage:
 * import { Colors } from '@/lib/theme';
 * backgroundColor: Colors.primary
 * color: Colors.textPrimary
 */

/** ============================================================================
 * 2. SPACING SYSTEM (8px Base Unit)
 * ============================================================================ */

/**
 * xs: 4px - Extra small
 * sm: 8px - Small
 * md: 16px - Medium (default padding)
 * lg: 24px - Large
 * xl: 32px - Extra Large
 * xxl: 40px - 2X Large
 * 
 * RULES:
 * - Never use random numbers for spacing
 * - Always use spacing constants
 * - Default screen padding: md (16px)
 * 
 * Usage:
 * import { Spacing } from '@/lib/theme';
 * paddingHorizontal: Spacing.md,
 * marginVertical: Spacing.lg,
 */

/** ============================================================================
 * 3. TYPOGRAPHY SYSTEM
 * ============================================================================ */

/**
 * Font: Inter (install via expo-font)
 * 
 * Sizes:
 * - largeNumber: 28px - Big balance amounts, totals (bold)
 * - title: 24px - Screen titles (semibold)
 * - subtitle: 18px - Section headers (semibold)
 * - body: 14px - Body text (regular)
 * - caption: 12px - Labels, captions (regular)
 * 
 * Font Weights:
 * - regular: 400
 * - medium: 500
 * - semibold: 600
 * - bold: 700
 * 
 * Usage:
 * import { Typography } from '@/lib/theme';
 * 
 * <Text style={{ fontSize: Typography.title, fontWeight: '600' }}>
 *   Title
 * </Text>
 * 
 * Or use presets:
 * <Text style={Typography.styles.title}>Title</Text>
 */

/** ============================================================================
 * 4. SHADOWS (Soft Only - Never Heavy)
 * ============================================================================ */

/**
 * Rules:
 * - shadowOpacity: max 0.12
 * - shadowRadius: 6-16px
 * - elevation: 2-12
 * - Always soft and subtle
 * 
 * Levels:
 * - minimal: Very subtle (elevation: 2)
 * - soft: Default for cards (elevation: 5)
 * - medium: Elevated content (elevation: 8)
 * - large: Modals, overlays (elevation: 12)
 * 
 * Usage:
 * import { Shadows } from '@/lib/theme';
 * ...Shadows.soft
 */

/** ============================================================================
 * 5. BORDER RADIUS RULES
 * ============================================================================ */

/**
 * - Small elements: 12px
 * - Buttons & Inputs: 16px
 * Cards: 20px (VERY IMPORTANT)
 * - Large sections: 24px
 * - Circles: 9999px
 * 
 * Usage:
 * import { BorderRadius } from '@/lib/theme';
 * borderRadius: BorderRadius.card
 */

/** ============================================================================
 * 6. CARD DESIGN SYSTEM (CORE)
 * ============================================================================ */

/**
 * Every card must have:
 * {
 *   backgroundColor: Colors.card,       // #FFFFFF
 *   borderRadius: 20,                  // IMPORTANT
 *   padding: 20,                       // Spacing.lg
 *   shadowColor: "#000",
 *   shadowOpacity: 0.05,               // Soft
 *   shadowRadius: 10,
 *   elevation: 5
 * }
 * 
 * This creates the "floating card" effect
 * 
 * Usage:
 * import { CardStyle } from '@/lib/theme';
 * <View style={CardStyle}>
 *   {/* content */}
 * </View>
 */

/** ============================================================================
 * 7. COMPONENT STYLES
 * ============================================================================ */

/**
 * FAB (Floating Action Button):
 * - position: absolute, bottom: 30, right: 30
 * - size: 60x60
 * - borderRadius: 30
 * - backgroundColor: primary
 * - icon: white, 28px
 * - elevation: 8
 * 
 * Input Fields:
 * - height: 50px
 * - borderRadius: 14px
 * - paddingHorizontal: 16px
 * - backgroundColor: #F3F4F8
 * - active border: primary color
 * 
 * Buttons:
 * - height: 50px
 * - borderRadius: 16px
 * - Use gradient: #6C63FF -> #8E7CFF
 * - Text: white, semibold, 16px
 * 
 * Header:
 * - height: 60px
 * - paddingHorizontal: 20px
 * 
 * Tab Navigation:
 * - height: 70px
 * - borderTopLeftRadius: 24px
 * - borderTopRightRadius: 24px
 * - active icon: primary
 * - inactive icon: #A0A4B8
 * 
 * Transaction Item:
 * - height: 70px
 * - borderRadius: 16px
 * - padding: 20px
 * - amount text: green if income, red if expense
 * - fontWeight: 600
 */

/** ============================================================================
 * 8. ICON SIZES
 * ============================================================================ */

/**
 * - Navigation Tab: 24px
 * - Card Icons: 20px
 * - FAB Icon: 28px
 * - Profile Image: 40px
 * - Small: 16px
 * - Medium: 24px
 * - Large: 32px
 * 
 * Usage:
 * import { IconSizes } from '@/lib/theme';
 * size={IconSizes.fab}
 */

/** ============================================================================
 * 9. GRADIENT SYSTEM
 * ============================================================================ */

/**
 * Primary Gradient (Balance Card):
 * start: #6C63FF
 * end: #8E7CFF
 * text color: White
 * 
 * Button Gradient:
 * start: #6C63FF
 * end: #8E7CFF
 * 
 * Usage:
 * import LinearGradient from 'expo-linear-gradient';
 * import { Colors } from '@/lib/theme';
 * 
 * <LinearGradient
 *   colors={[Colors.primary, Colors.gradientPrimary.end]}
 *   start={{ x: 0, y: 0 }}
 *   end={{ x: 1, y: 1 }}
 * >
 *   {/* content */}
 * </LinearGradient>
 */

/** ============================================================================
 * 10. MICRO-INTERACTIONS
 * ============================================================================ */

/**
 * Install: react-native-reanimated
 * 
 * Card Press Animation:
 * - Scale: 0.98
 * - Duration: 150ms
 * - Easing: ease-out
 * 
 * Button Ripple:
 * - Opacity: 0.1
 * - Scale: Slight grow
 * 
 * List Entry Fade:
 * - Opacity: 0 -> 1
 * - Duration: 300ms
 * - Delay: staggered per item
 * 
 * Chart Animation:
 * - Duration: 500ms
 * - Easing: ease-out
 */

/** ============================================================================
 * 11. CHART SYSTEM
 * ============================================================================ */

/**
 * Library: react-native-chart-kit
 * 
 * Style:
 * - Soft donut charts
 * - Card styling with 24px borderRadius
 * - Padding: 24px
 * - Background: White
 * - Use primary gradient colors
 * 
 * Colors:
 * - Series: Use Colors.primary, Colors.secondary, Colors.success, etc.
 */

/** ============================================================================
 * 12. DARK MODE
 * ============================================================================ */

/**
 * Background: #121212
 * Card: #1E1E2D
 * Text (Primary): #FFFFFF
 * Text (Secondary): #B0B0B0
 * Border: #2A2A3E
 * Accent: Keep purple (#6C63FF)
 * 
 * Keep all radius and spacing the same.
 * Only change colors.
 */

/** ============================================================================
 * 13. REQUIRED INSTALLATIONS
 * ============================================================================ */

/**
 * expo-linear-gradient - For gradients
 * expo-font - For custom fonts (Inter)
 * react-native-reanimated - For animations
 * react-native-chart-kit - For charts
 * @expo/vector-icons - For icons
 * 
 * Instructions:
 * npx expo install expo-linear-gradient
 * npx expo install expo-font
 * npx expo install react-native-reanimated
 * npx expo install react-native-chart-kit
 */

/** ============================================================================
 * 14. DESIGN TOKENS SUMMARY
 * ============================================================================ */

/**
 * This design system uses design tokens organized into:
 * - Colors: Complete color palette
 * - Spacing: Consistent spacing intervals
 * - Typography: Font sizes and weights
 * - Shadows: Shadow depth levels
 * - Border Radius: Common radius values
 * - Animation: Duration and scale values
 * 
 * All tokens are centralized in:
 * /mobile/lib/theme/
 * 
 * Import everything from:
 * import { Colors, Spacing, Typography, ... } from '@/lib/theme';
 */

export const DesignSystem = {
  name: "Soft Neumorphic Fintech Minimal",
  version: "1.0.0",
  lastUpdated: "2026-02-20",
};
