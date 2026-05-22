import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

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
      padding: EdgeInsets.symmetric(vertical: 8.r(context)),
      child: Row(
        children: [
          Container(
            width: 40.r(context),
            height: 40.r(context),
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
              size: 22.r(context),
            ),
          ),
          SizedBox(width: 14.r(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.r(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.r(context)),
                Text(
                  transaction.date,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.r(context)),
                ),
                if ((transaction.note ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: 3.r(context)),
                  Text(
                    transaction.note!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: const Color(0xFF8E97B5), fontSize: 11.r(context)),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.r(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${appState.formatCurrency(transaction.amount)}',
                style: TextStyle(
                    color: amountColor,
                    fontSize: 14.r(context),
                    fontWeight: FontWeight.w800),
              ),
              if (onEdit != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: Icon(Icons.edit,
                      color: AppColors.textSecondary, size: 16.r(context)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
