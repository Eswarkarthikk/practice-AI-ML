import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SplashMark(),
            SizedBox(height: 22),
            Text.rich(
              TextSpan(
                text: 'Finance ',
                children: [
                  TextSpan(
                    text: 'Tracker',
                    style: TextStyle(color: AppColors.blue),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading your money space',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 26),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                minHeight: 5,
                color: AppColors.purple,
                backgroundColor: AppColors.darkBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.blue],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.38),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Icon(Icons.account_balance_wallet_outlined,
          size: 44, color: AppColors.textPrimary),
    );
  }
}
