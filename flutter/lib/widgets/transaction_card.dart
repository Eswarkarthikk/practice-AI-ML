import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;

  const TransactionCard({super.key, required this.transaction, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final category = appState.categoryById(transaction.category);
    final isCredit = transaction.isCredit;
    final isLoan = transaction.type == 'borrow' || transaction.type == 'lend';
    final title = isLoan
        ? '${transaction.type == 'borrow' ? 'Borrow' : 'Lend'}${transaction.counterparty == null ? '' : ' | ${transaction.counterparty}'}'
        : category.name;
    final amountColor = isCredit ? AppColors.green : AppColors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Icon(
              isCredit
                  ? Icons.account_balance_wallet_outlined
                  : Icons.credit_card_outlined,
              color: category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.date,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                if ((transaction.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    transaction.note!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Color(0xFF8E97B5), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${appState.formatCurrency(transaction.amount)}',
                style: TextStyle(
                    color: amountColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
              if (onEdit != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit,
                      color: AppColors.textSecondary, size: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
