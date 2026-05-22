import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final colors = Theme.of(context);
    final recentTransactions = appState.transactions.take(5).toList();
    final monthlyExpense = appState.totalExpense(thisMonth: true);
    final dailyAverage = monthlyExpense / DateTime.now().day;
    final isLandscape = Responsive.isLandscape(context);

    if (isLandscape) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 12.r(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(right: 16.r(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: colors.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      fontSize: 22.r(context),
                                    ),
                                    children: [
                                      const TextSpan(text: 'Hello, '),
                                      TextSpan(
                                        text: appState.profile?.name ?? 'User',
                                        style: const TextStyle(color: AppColors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.r(context)),
                                Text(
                                  DateTime.now().toLocal().toString().split(' ').first,
                                  style: TextStyle(
                                      color: AppColors.textSecondary, fontSize: 12.r(context)),
                                ),
                              ],
                            ),
                            Icon(Icons.notifications_outlined,
                                size: 24.r(context), color: AppColors.textSecondary),
                          ],
                        ),
                        SizedBox(height: 24.r(context)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.formatCurrency(appState.currentBalance()),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 36.r(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 6.r(context)),
                            Text(
                              'Total Balance',
                              style:
                                  TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.r(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Total Expense',
                                value: appState.formatCurrency(monthlyExpense),
                                color: AppColors.orange,
                              ),
                            ),
                            SizedBox(width: 12.r(context)),
                            Expanded(
                              child: _StatCard(
                                label: 'Daily Average',
                                value: appState.formatCurrency(dailyAverage),
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Vertical Divider
                Container(
                  width: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  margin: EdgeInsets.symmetric(horizontal: 4.r(context)),
                ),
                // Right Column
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16.r(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Sources',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.r(context),
                          ),
                        ),
                        SizedBox(height: 8.r(context)),
                        SizedBox(
                          height: 52.r(context),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: appState.sourceBalances().length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.r(context)),
                            itemBuilder: (context, index) {
                              final item = appState.sourceBalances()[index];
                              return FinanceCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.r(context), vertical: 6.r(context)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.source.name,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.r(context),
                                      ),
                                    ),
                                    SizedBox(width: 12.r(context)),
                                    Text(
                                      appState.formatCurrency(item.balance),
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.r(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.r(context)),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.r(context),
                          ),
                        ),
                        SizedBox(height: 8.r(context)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuickAction(
                              icon: Icons.add_circle_outline,
                              label: 'Add Trans.',
                              color: AppColors.blue,
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/add-transaction'),
                            ),
                            _QuickAction(
                              icon: Icons.bar_chart,
                              label: 'Analytics',
                              color: AppColors.green,
                              onTap: () => Navigator.of(context).pushNamed('/analytics'),
                            ),
                            _QuickAction(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Budget',
                              color: const Color(0xFFFFD44D),
                              onTap: () => Navigator.of(context).pushNamed('/budget'),
                            ),
                            _QuickAction(
                              icon: Icons.shopping_cart_outlined,
                              label: 'Cart',
                              color: const Color(0xFFFF5B7F),
                              onTap: () => Navigator.of(context).pushNamed('/cart'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.r(context)),
                        if (recentTransactions.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.r(context),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('/transactions'),
                                child: Text('View all',
                                    style: TextStyle(
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.r(context))),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.r(context)),
                          ...recentTransactions.map(
                            (transaction) => FinanceCard(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.r(context), vertical: 6.r(context)),
                              margin: EdgeInsets.only(bottom: 10.r(context)),
                              child: TransactionCard(transaction: transaction),
                            ),
                          ),
                        ] else
                          const _EmptyState(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.r(context), 12.r(context), 20.r(context), 112.r(context)),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: colors.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Hello, '),
                          TextSpan(
                            text: appState.profile?.name ?? 'User',
                            style: const TextStyle(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.r(context)),
                    Text(
                      DateTime.now().toLocal().toString().split(' ').first,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12.r(context)),
                    ),
                  ],
                ),
                Icon(Icons.notifications_outlined,
                    size: 24.r(context), color: AppColors.textSecondary),
              ],
            ),
            SizedBox(height: 28.r(context)),
            Column(
              children: [
                Text(
                  appState.formatCurrency(appState.currentBalance()),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 44.r(context),
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.r(context)),
                Text(
                  'Total Balance',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                ),
              ],
            ),
            SizedBox(height: 20.r(context)),
            SizedBox(
              height: 58.r(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.sourceBalances().length,
                separatorBuilder: (_, __) => SizedBox(width: 10.r(context)),
                itemBuilder: (context, index) {
                  final item = appState.sourceBalances()[index];
                  return FinanceCard(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.r(context), vertical: 8.r(context)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.source.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.r(context),
                          ),
                        ),
                        SizedBox(width: 18.r(context)),
                        Text(
                          appState.formatCurrency(item.balance),
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.r(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18.r(context)),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Expense',
                    value: appState.formatCurrency(monthlyExpense),
                    color: AppColors.orange,
                  ),
                ),
                SizedBox(width: 12.r(context)),
                Expanded(
                  child: _StatCard(
                    label: 'Daily Average',
                    value: appState.formatCurrency(dailyAverage),
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.r(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add Transaction',
                  color: AppColors.blue,
                  onTap: () =>
                      Navigator.of(context).pushNamed('/add-transaction'),
                ),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Analytics',
                  color: AppColors.green,
                  onTap: () => Navigator.of(context).pushNamed('/analytics'),
                ),
                _QuickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget',
                  color: const Color(0xFFFFD44D),
                  onTap: () => Navigator.of(context).pushNamed('/budget'),
                ),
                _QuickAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart',
                  color: const Color(0xFFFF5B7F),
                  onTap: () => Navigator.of(context).pushNamed('/cart'),
                ),
              ],
            ),
            SizedBox(height: 30.r(context)),
            if (recentTransactions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18.r(context),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/transactions'),
                    child: Text('View all',
                        style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.r(context))),
                  ),
                ],
              ),
              SizedBox(height: 10.r(context)),
              ...recentTransactions.map(
                (transaction) => FinanceCard(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.r(context), vertical: 6.r(context)),
                  margin: EdgeInsets.only(bottom: 12.r(context)),
                  child: TransactionCard(transaction: transaction),
                ),
              ),
            ] else
              const _EmptyState(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: EdgeInsets.all(16.r(context)),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.r(context))),
          SizedBox(height: 10.r(context)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 17.r(context))),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78.r(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r(context)),
        onTap: onTap,
        child: Column(
          children: [
            FinanceCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 48.r(context),
                height: 48.r(context),
                child: Icon(icon, color: color, size: 24.r(context)),
              ),
            ),
            SizedBox(height: 6.r(context)),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 10.r(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 42.r(context)),
      child: Column(
        children: [
          Icon(Icons.query_stats, size: 48.r(context), color: AppColors.blue),
          SizedBox(height: 14.r(context)),
          Text('No transactions yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.r(context))),
          SizedBox(height: 8.r(context)),
          Text(
            'Add your first transaction to get started',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
          ),
        ],
      ),
    );
  }
}
