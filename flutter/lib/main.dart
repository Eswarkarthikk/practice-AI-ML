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
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/finance_scaffold.dart';

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
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: context.watch<AppStateModel>().themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const AppShell(),
              '/add-transaction': (_) => const AddTransactionScreen(),
              '/add-source': (_) => const AddSourceScreen(),
              '/analytics': (_) => const AnalyticsScreen(),
              '/budget': (_) => const BudgetScreen(),
              '/cart': (_) => const CartScreen(),
              '/transactions': (_) => const TransactionsScreen(),
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

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();

    if (!appState.isLoaded) {
      return const SplashScreen();
    }

    if (!appState.initialized || appState.sources.isEmpty) {
      return const AddSourceScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _tabs),
          FinanceFooter(
              activeIndex: _selectedIndex, onTabSelected: _onItemTapped),
        ],
      ),
    );
  }
}
