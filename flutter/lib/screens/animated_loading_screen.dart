import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class AnimatedLoadingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const AnimatedLoadingScreen({super.key, required this.onFinished});

  @override
  State<AnimatedLoadingScreen> createState() => _AnimatedLoadingScreenState();
}

class _AnimatedLoadingScreenState extends State<AnimatedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80.r(context),
            height: 80.r(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.r(context)),
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.blue],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.38),
                  blurRadius: 30.r(context),
                  offset: Offset(0, 12.r(context)),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 38.r(context),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
