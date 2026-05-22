import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          context,
          ListView(
            padding: EdgeInsets.fromLTRB(20.r(context), 24.r(context), 20.r(context), 28.r(context)),
            children: [
              SplitTitle(
                first: 'All ',
                second: 'Transactions',
                color: AppColors.blue,
                size: 32.r(context),
              ),
              SizedBox(height: 24.r(context)),
              Row(
                children: [
                  const Expanded(
                      child:
                          _FilterBox(label: 'Category', value: 'All Categories')),
                  SizedBox(width: 14.r(context)),
                  const Expanded(
                      child: _FilterBox(label: 'Source', value: 'All Sources')),
                ],
              ),
              SizedBox(height: 14.r(context)),
              Row(
                children: [
                  const Expanded(child: _FilterBox(label: 'Type', value: 'All Types')),
                  SizedBox(width: 14.r(context)),
                  const Expanded(
                      child: _FilterBox(
                          label: 'From',
                          value: 'Select date',
                          icon: Icons.calendar_month_outlined,
                          iconColor: AppColors.green)),
                ],
              ),
              SizedBox(height: 14.r(context)),
              const _FilterBox(
                label: 'To',
                value: 'Select date',
                icon: Icons.calendar_month_outlined,
                iconColor: Color(0xFFFFD44D),
              ),
              SizedBox(height: 18.r(context)),
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
                      padding: EdgeInsets.only(right: 20.r(context)),
                      margin: EdgeInsets.only(bottom: 14.r(context)),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24.r(context)),
                      ),
                      child:
                          Icon(Icons.delete_outline, color: AppColors.red, size: 24.r(context)),
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
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r(context))),
        title: Text(
          'Delete transaction?',
          style: TextStyle(
            fontSize: 18.r(context),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.r(context)),
          child: Text(
            'This removes it from your tracker.',
            style: TextStyle(
              fontSize: 13.r(context),
              color: AppColors.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 13.r(context), color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size(80.r(context), 38.r(context)),
              padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(fontSize: 13.r(context)),
            ),
          ),
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
      padding: EdgeInsets.all(18.r(context)),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15.r(context))),
              SizedBox(height: 10.r(context)),
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16.r(context), fontWeight: FontWeight.w900)),
            ]),
          ),
          Icon(icon, color: iconColor, size: 28.r(context)),
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
      margin: EdgeInsets.only(bottom: 14.r(context)),
      padding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 22.r(context)),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 12.r(context),
            height: 12.r(context),
            decoration:
                BoxDecoration(color: category.color, shape: BoxShape.circle),
          ),
          SizedBox(width: 16.r(context)),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 20.r(context), fontWeight: FontWeight.w800)),
              SizedBox(height: 6.r(context)),
              Text(
                  '${transaction.date} | ${source?.name ?? transaction.source}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15.r(context))),
              if ((transaction.note ?? transaction.description).isNotEmpty) ...[
                SizedBox(height: 6.r(context)),
                Text(transaction.note ?? transaction.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 15.r(context))),
              ],
            ]),
          ),
          SizedBox(width: 10.r(context)),
          Text('$amountPrefix${appState.formatCurrency(transaction.amount)}',
              style: TextStyle(
                  color: amountColor,
                  fontSize: 19.r(context),
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
