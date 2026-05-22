import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/add_source_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/animated_loading_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/responsive.dart';
import 'widgets/finance_scaffold.dart';
import 'widgets/app_lock_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppStateModel();
  await NotificationService.initialize();
  runApp(TransactionApp(appState: appState));
  appState.load();
}

class TransactionApp extends StatelessWidget {
  final AppStateModel appState;

  const TransactionApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Finance Tracker',
            theme: AppTheme.light(context),
            darkTheme: AppTheme.dark(context),
            themeMode: context.watch<AppStateModel>().themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const AppShell(),
              '/analytics': (_) => const AnalyticsScreen(),
              '/budget': (_) => const BudgetScreen(),
              '/cart': (_) => const CartScreen(),
              '/transactions': (_) => const TransactionsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/add-transaction') {
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddTransactionScreen(),
                  opaque: false,
                  barrierColor: Colors.black.withValues(alpha: 0.55),
                  barrierDismissible: true,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    );
                  },
                  settings: settings,
                );
              }
              if (settings.name == '/add-source') {
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddSourceScreen(),
                  opaque: false,
                  barrierColor: Colors.black.withValues(alpha: 0.55),
                  barrierDismissible: true,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    );
                  },
                  settings: settings,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isAppUnlocked = false;
  bool _showSplashAnimation = true;
  bool _startedOnboarding = false;

  static const List<Widget> _tabs = [
    HomeScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() {
        _isAppUnlocked = false;
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();

    if (!appState.isLoaded) {
      return const SplashScreen();
    }

    if (_showSplashAnimation) {
      return AnimatedLoadingScreen(
        onFinished: () {
          setState(() {
            _showSplashAnimation = false;
          });
        },
      );
    }

    if (!appState.initialized || appState.sources.isEmpty) {
      if (!_startedOnboarding) {
        return WelcomeScreen(
          onGetStarted: () {
            setState(() {
              _startedOnboarding = true;
            });
          },
        );
      }
      return const AddSourceScreen();
    }

    if (appState.requiresInitialLockSetup) {
      return const AppLockSetupScreen();
    }

    if (appState.shouldProtectApp && !_isAppUnlocked) {
      return AppLockScreen(
        onUnlocked: () {
          setState(() {
            _isAppUnlocked = true;
          });
        },
      );
    }

    if (Responsive.isLandscape(context)) {
      return Scaffold(
        body: Row(
          children: [
            FinanceNavigationRail(
              activeIndex: _selectedIndex,
              onTabSelected: _onItemTapped,
            ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _tabs),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Responsive.constrained(
        context,
        Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _tabs),
            FinanceFooter(
                activeIndex: _selectedIndex, onTabSelected: _onItemTapped),
          ],
        ),
      ),
    );
  }
}
