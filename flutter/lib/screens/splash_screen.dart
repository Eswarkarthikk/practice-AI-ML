import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SplashMark(),
            SizedBox(height: 22.r(context)),
            Text.rich(
              const TextSpan(
                text: 'Finance ',
                children: [
                  TextSpan(
                    text: 'Tracker',
                    style: TextStyle(color: AppColors.blue),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 30.r(context),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.r(context)),
            Text(
              'Loading your money space',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15.r(context),
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 26.r(context)),
            SizedBox(
              width: 180.r(context),
              child: LinearProgressIndicator(
                minHeight: 5.r(context),
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
      width: 92.r(context),
      height: 92.r(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r(context)),
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.blue],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.38),
            blurRadius: 34.r(context),
            offset: Offset(0, 16.r(context)),
          ),
        ],
      ),
      child: Icon(Icons.account_balance_wallet_outlined,
          size: 44.r(context), color: AppColors.textPrimary),
    );
  }
}
