import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class AppLockSetupScreen extends StatefulWidget {
  const AppLockSetupScreen({super.key});

  @override
  State<AppLockSetupScreen> createState() => _AppLockSetupScreenState();
}

class _AppLockSetupScreenState extends State<AppLockSetupScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;

  void _onKeyPress(String val) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += val;
    });

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        if (!_confirming) {
          setState(() {
            _firstPin = _pin;
            _pin = '';
            _confirming = true;
          });
        } else {
          if (_pin == _firstPin) {
            final appState = context.read<AppStateModel>();
            appState.setAppLockPin(_pin);
            appState.setAppLockEnabled(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PINs do not match. Please start again.'),
                backgroundColor: AppColors.orange,
              ),
            );
            setState(() {
              _pin = '';
              _firstPin = '';
              _confirming = false;
            });
          }
        }
      });
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Responsive.constrained(
          context,
          Column(
            children: [
              const Spacer(),
              Icon(
                Icons.lock_outline,
                size: 58.r(context),
                color: _confirming ? AppColors.green : AppColors.blue,
              ),
              SizedBox(height: 24.r(context)),
              Text(
                _confirming ? 'Confirm your PIN' : 'Create a 4-digit PIN',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.r(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.r(context)),
              Text(
                _confirming
                    ? 'Re-enter your 4-digit fallback PIN'
                    : 'This PIN will be used as a fallback for app access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.r(context),
                ),
              ),
              SizedBox(height: 38.r(context)),
              _PinDots(length: _pin.length),
              const Spacer(),
              _Keypad(
                onKeyPress: _onKeyPress,
                onBackspace: _onBackspace,
                showBiometricButton: false,
              ),
              SizedBox(height: 32.r(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  String _pin = '';
  bool _biometricChecking = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    if (_biometricChecking) return;
    _biometricChecking = true;

    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (isSupported && canCheck) {
        final authenticated = await _auth.authenticate(
          localizedReason: 'Authenticate to access your wallet tracker',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (authenticated) {
          widget.onUnlocked();
        }
      }
    } catch (_) {
      // Fail silently and rely on PIN fallback
    } finally {
      _biometricChecking = false;
    }
  }

  void _onKeyPress(String val) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += val;
      _isError = false;
    });

    if (_pin.length == 4) {
      final appState = context.read<AppStateModel>();
      if (_pin == appState.appLockPin) {
        Future.delayed(const Duration(milliseconds: 150), () {
          widget.onUnlocked();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _pin = '';
            _isError = true;
          });
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Responsive.constrained(
          context,
          Column(
            children: [
              const Spacer(),
              Icon(
                Icons.lock_person_outlined,
                size: 58.r(context),
                color: AppColors.blue,
              ),
              SizedBox(height: 24.r(context)),
              Text(
                'App Locked',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.r(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.r(context)),
              Text(
                _isError ? 'Incorrect PIN, please try again' : 'Enter your 4-digit PIN to unlock',
                style: TextStyle(
                  color: _isError ? AppColors.orange : AppColors.textSecondary,
                  fontSize: 13.r(context),
                  fontWeight: _isError ? FontWeight.w800 : FontWeight.normal,
                ),
              ),
              SizedBox(height: 38.r(context)),
              _PinDots(length: _pin.length, isError: _isError),
              const Spacer(),
              _Keypad(
                onKeyPress: _onKeyPress,
                onBackspace: _onBackspace,
                showBiometricButton: true,
                onBiometricTap: _checkBiometrics,
              ),
              SizedBox(height: 32.r(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  final bool isError;

  const _PinDots({required this.length, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: 12.r(context)),
          width: 16.r(context),
          height: 16.r(context),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? AppColors.orange
                : (filled ? AppColors.blue : Colors.transparent),
            border: Border.all(
              color: isError
                  ? AppColors.orange
                  : (filled ? AppColors.blue : AppColors.textSecondary.withValues(alpha: 0.5)),
              width: 2.r(context),
            ),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final bool showBiometricButton;
  final VoidCallback? onBiometricTap;

  const _Keypad({
    required this.onKeyPress,
    required this.onBackspace,
    required this.showBiometricButton,
    this.onBiometricTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 320.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.r(context)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['1', '2', '3'].map((digit) => _KeypadButton(label: digit, onTap: () => onKeyPress(digit))).toList(),
              ),
              SizedBox(height: 18.r(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['4', '5', '6'].map((digit) => _KeypadButton(label: digit, onTap: () => onKeyPress(digit))).toList(),
              ),
              SizedBox(height: 18.r(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['7', '8', '9'].map((digit) => _KeypadButton(label: digit, onTap: () => onKeyPress(digit))).toList(),
              ),
              SizedBox(height: 18.r(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBiometricButton)
                    _KeypadButton(
                      icon: Icons.fingerprint,
                      iconColor: AppColors.green,
                      onTap: onBiometricTap,
                    )
                  else
                    SizedBox(width: 70.r(context), height: 70.r(context)),
                  _KeypadButton(label: '0', onTap: () => onKeyPress('0')),
                  _KeypadButton(
                    icon: Icons.backspace_outlined,
                    iconColor: AppColors.textSecondary,
                    onTap: onBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _KeypadButton({
    this.label,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35.r(context)),
      child: Container(
        width: 70.r(context),
        height: 70.r(context),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: label != null || icon != null
                ? AppColors.darkBorder
                : Colors.transparent,
            width: 1,
          ),
          color: label != null || icon != null
              ? AppColors.darkCard.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 26.r(context))
            : (label != null
                ? Text(
                    label!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24.r(context),
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null),
      ),
    );
  }
}
