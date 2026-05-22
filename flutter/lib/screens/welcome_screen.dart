import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Responsive.constrained(
          context,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r(context)),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    // Large custom app icon logo
                    Container(
                      width: 100.r(context),
                      height: 100.r(context),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.r(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30.r(context),
                            offset: Offset(0, 14.r(context)),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32.r(context)),
                        child: Image.asset(
                          'assets/images/icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Welcome Title
                    Text.rich(
                      const TextSpan(
                        text: 'Welcome to\n',
                        children: [
                          TextSpan(text: 'Finance ', style: TextStyle(color: Colors.white)),
                          TextSpan(
                            text: 'Tracker',
                            style: TextStyle(color: AppColors.blue),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 36.r(context) : 30.r(context),
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18.r(context)),
                    // Tagline / description
                    Text(
                      'Take control of your money with our smart, AI-powered budgeting assistant and spending tracker.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 16.r(context) : 14.r(context),
                        height: 1.45,
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Get Started Button
                    GradientActionButton(
                      label: 'Get Started',
                      onPressed: widget.onGetStarted,
                    ),
                    SizedBox(height: 32.r(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
