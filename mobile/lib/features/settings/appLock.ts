// App Lock/Authentication utilities

import * as LocalAuthentication from 'expo-local-authentication';
import AsyncStorage from '@react-native-async-storage/async-storage';

const APP_LOCK_KEY = 'app_lock_enabled';
const PIN_KEY = 'app_pin';

export const AppLock = {
  /**
   * Check if device supports biometric authentication
   */
  isBiometricAvailable: async (): Promise<boolean> => {
    try {
      const compatible = await LocalAuthentication.hasHardwareAsync();
      const enrolled = await LocalAuthentication.isEnrolledAsync();
      return compatible && enrolled;
    } catch (error) {
      console.error('Error checking biometric:', error);
      return false;
    }
  },

  /**
   * Get available authentication types on device
   */
  getAvailableAuthTypes: async (): Promise<LocalAuthentication.AuthenticationType[]> => {
    try {
      return await LocalAuthentication.supportedAuthenticationTypesAsync();
    } catch (error) {
      console.error('Error getting auth types:', error);
      return [];
    }
  },

  /**
   * Enable app lock with biometric or PIN
   */
  enableLock: async (useBiometric: boolean = true): Promise<boolean> => {
    try {
      if (useBiometric) {
        const isBioAvailable = await AppLock.isBiometricAvailable();
        if (!isBioAvailable) {
          // Cannot use biometric, fall back to PIN
          return false;
        }
      }
      await AsyncStorage.setItem(APP_LOCK_KEY, 'true');
      return true;
    } catch (error) {
      console.error('Error enabling lock:', error);
      return false;
    }
  },

  /**
   * Disable app lock
   */
  disableLock: async (): Promise<void> => {
    try {
      await AsyncStorage.removeItem(APP_LOCK_KEY);
      await AsyncStorage.removeItem(PIN_KEY);
    } catch (error) {
      console.error('Error disabling lock:', error);
    }
  },

  /**
   * Check if app lock is enabled
   */
  isLockEnabled: async (): Promise<boolean> => {
    try {
      const enabled = await AsyncStorage.getItem(APP_LOCK_KEY);
      return enabled === 'true';
    } catch (error) {
      console.error('Error checking lock status:', error);
      return false;
    }
  },

  /**
   * Set PIN for fallback authentication
   */
  setPIN: async (pin: string): Promise<void> => {
    try {
      // In production, hash the PIN
      await AsyncStorage.setItem(PIN_KEY, pin);
    } catch (error) {
      console.error('Error setting PIN:', error);
    }
  },

  /**
   * Authenticate with biometric
   */
  authenticateBiometric: async (): Promise<boolean> => {
    try {
      const result = await LocalAuthentication.authenticateAsync({
        disableDeviceFallback: false,
      });
      return result.success;
    } catch (error) {
      console.error('Biometric authentication failed:', error);
      return false;
    }
  },

  /**
   * Verify PIN
   */
  verifyPIN: async (pin: string): Promise<boolean> => {
    try {
      const stored = await AsyncStorage.getItem(PIN_KEY);
      return stored === pin;
    } catch (error) {
      console.error('Error verifying PIN:', error);
      return false;
    }
  },
};
