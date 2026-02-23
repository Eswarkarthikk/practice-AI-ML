import React from 'react';
import {
  TextInput,
  StyleSheet,
  View,
  Text,
  ViewStyle,
  StyleProp,
} from 'react-native';
import { COLORS, SPACING, TYPOGRAPHY, BORDER_RADIUS } from '@/lib/theme';

interface InputProps {
  placeholder?: string;
  value: string;
  onChangeText?: (text: string) => void;
  keyboardType?: 'default' | 'numeric' | 'email-address' | 'phone-pad';
  secureTextEntry?: boolean;
  label?: string;
  style?: StyleProp<ViewStyle>;
  editable?: boolean;
  multiline?: boolean;
  numberOfLines?: number;
}

export const Input: React.FC<InputProps> = ({
  placeholder,
  value,
  onChangeText,
  keyboardType = 'default',
  secureTextEntry = false,
  label,
  style,
  multiline = false,
  numberOfLines = 1,
  editable = true,
}) => {
  return (
    <View style={style}>
      {label && <Text style={styles.label}>{label}</Text>}
      <TextInput
        placeholder={placeholder}
        placeholderTextColor={COLORS.textSecondary}
        value={value}
        onChangeText={onChangeText ?? (() => {})}
        keyboardType={keyboardType}
        secureTextEntry={secureTextEntry}
        editable={editable}
        style={styles.input}
        multiline={multiline}
        numberOfLines={numberOfLines}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  label: {
    ...TYPOGRAPHY.styles.small,
    color: COLORS.textPrimary,
    marginBottom: SPACING.sm,
    fontWeight: '600',
  },
  input: {
    backgroundColor: COLORS.bgLight,
    borderRadius: BORDER_RADIUS.medium,
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.md,
    borderColor: COLORS.borderColor,
    borderWidth: 1,
    color: COLORS.textPrimary,
    ...TYPOGRAPHY.styles.body,
  },
});
