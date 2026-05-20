import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_scaffold.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            const SplitTitle(
              first: 'All ',
              second: 'Transactions',
              color: AppColors.blue,
              size: 32,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(
                    child:
                        _FilterBox(label: 'Category', value: 'All Categories')),
                SizedBox(width: 14),
                Expanded(
                    child: _FilterBox(label: 'Source', value: 'All Sources')),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: _FilterBox(label: 'Type', value: 'All Types')),
                SizedBox(width: 14),
                Expanded(
                    child: _FilterBox(
                        label: 'From',
                        value: 'Select date',
                        icon: Icons.calendar_month_outlined,
                        iconColor: AppColors.green)),
              ],
            ),
            const SizedBox(height: 14),
            const _FilterBox(
              label: 'To',
              value: 'Select date',
              icon: Icons.calendar_month_outlined,
              iconColor: Color(0xFFFFD44D),
            ),
            const SizedBox(height: 18),
            if (appState.transactions.isEmpty)
              const EmptyFinanceState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                message: 'Add your first transaction to see it here.',
              )
            else
              ...appState.transactions.map(
                (transaction) => Dismissible(
                  key: ValueKey(transaction.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child:
                        const Icon(Icons.delete_outline, color: AppColors.red),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) =>
                      appState.removeTransaction(transaction.id),
                  child: _TransactionListCard(
                    transaction: transaction,
                    appState: appState,
                    onTap: () => Navigator.of(context).pushNamed(
                        '/add-transaction',
                        arguments: transaction.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This removes it from your tracker.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    return result ?? false;
  }
}

class _FilterBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _FilterBox({
    required this.label,
    required this.value,
    this.icon = Icons.keyboard_arrow_down,
    this.iconColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 10),
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          Icon(icon, color: iconColor, size: 28),
        ],
      ),
    );
  }
}

class _TransactionListCard extends StatelessWidget {
  final TransactionModel transaction;
  final AppStateModel appState;
  final VoidCallback onTap;

  const _TransactionListCard({
    required this.transaction,
    required this.appState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = appState.categoryById(transaction.category);
    final source = appState.sourceById(transaction.source);
    final amountPrefix = transaction.isCredit ? '+' : '-';
    final amountColor =
        transaction.isCredit ? AppColors.green : AppColors.orange;
    final title = transaction.type == 'borrow' || transaction.type == 'lend'
        ? '${transaction.type == 'borrow' ? 'Borrow' : 'Lend'} | ${transaction.counterparty ?? transaction.description}'
        : category.name;

    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: category.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                  '${transaction.date} | ${source?.name ?? transaction.source}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 15)),
              if ((transaction.note ?? transaction.description).isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(transaction.note ?? transaction.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 15)),
              ],
            ]),
          ),
          const SizedBox(width: 10),
          Text('$amountPrefix${appState.formatCurrency(transaction.amount)}',
              style: TextStyle(
                  color: amountColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
