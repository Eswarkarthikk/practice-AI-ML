import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/budget.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_scaffold.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final categories =
        appState.categories.where((item) => item.id != 'salary').toList();
    _selectedCategoryId ??= categories.first.id;
    final breakdown = appState.expenseByCategory(thisMonth: true);
    final totalSpent = breakdown.values.fold(0.0, (sum, value) => sum + value);
    final totalBudget =
        appState.budgets.fold(0.0, (sum, budget) => sum + budget.amount);
    final overBudget = appState.budgets.where((budget) {
      return appState.spentForBudget(budget) > budget.amount;
    }).length;
    final remaining = (totalBudget - totalSpent).clamp(0, double.infinity);
    final used = totalBudget <= 0 ? 0 : (totalSpent / totalBudget * 100);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          children: [
            Row(
              children: [
                const Expanded(
                  child: SplitTitle(
                    first: 'My ',
                    second: 'Budget',
                    color: AppColors.purple,
                    size: 38,
                  ),
                ),
                _MonthPill(date: DateTime.now()),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.purple),
                SizedBox(width: 8),
                Text('All Sources Budget',
                    style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 19,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text('All Sources',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 142,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.sourceBalances().length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = appState.sourceBalances()[index];
                  return SourceBalanceCard(
                    label: '${item.source.type} source',
                    maskedName: item.source.name,
                    balance: appState.formatCurrency(item.balance),
                    width: 190,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 330,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(292, 292),
                    painter: _BudgetDonutPainter(
                      entries: breakdown.entries.map((entry) {
                        final category = appState.categoryById(entry.key);
                        return _DonutEntry(entry.value, category.color);
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('TOTAL SPENT',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                              letterSpacing: 2)),
                      const SizedBox(height: 14),
                      Text(appState.formatCurrency(totalSpent),
                          style: const TextStyle(
                              fontSize: 38, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text('of ${appState.formatCurrency(totalBudget)} budget',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: categories.take(5).map((category) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: category.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(category.name,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _BudgetStat(
                        value: appState.formatCurrency(remaining.toDouble()),
                        label: 'REMAINING',
                        color: AppColors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _BudgetStat(
                        value: '$overBudget',
                        label: 'OVER BUDGET',
                        color: AppColors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _BudgetStat(
                        value: '${used.toStringAsFixed(0)}%',
                        label: 'USED',
                        color: AppColors.purple)),
              ],
            ),
            const SizedBox(height: 26),
            FinanceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  FinanceSelectField<String>(
                    label: 'Category',
                    value: _selectedCategoryId,
                    items: categories
                        .map((category) => DropdownMenuItem(
                            value: category.id, child: Text(category.name)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                  ),
                  const SizedBox(height: 14),
                  FinanceTextField(
                    controller: _amountController,
                    label: 'Budget amount',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  GradientActionButton(
                      label: 'Save Budget', onPressed: () => _save(appState)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Row(
              children: [
                Icon(Icons.pie_chart_outline, color: Color(0xFFFFD44D)),
                SizedBox(width: 8),
                Text('CATEGORIES',
                    style: TextStyle(
                        color: Color(0xFFFFD44D),
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            ...categories.map((category) {
              final budget = appState.budgets.where((item) {
                return item.categoryId == category.id &&
                    item.period == 'monthly';
              }).firstOrNull;
              final spent = breakdown[category.id] ?? 0;
              final budgetAmount = budget?.amount ?? 0;
              final percent = budgetAmount <= 0
                  ? 0.0
                  : (spent / budgetAmount).clamp(0, 1).toDouble();
              return FinanceCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    _CategoryIcon(category.id, category.color),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 18),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              backgroundColor: AppColors.darkBorder,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(appState.formatCurrency(spent),
                            style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text('${(percent * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                            const SizedBox(width: 10),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppStateModel appState) async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedCategoryId == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid budget')));
      return;
    }
    await appState.addBudget(
      BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: _selectedCategoryId!,
        amount: amount,
        period: 'monthly',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _amountController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Budget saved')));
  }
}

class _MonthPill extends StatelessWidget {
  final DateTime date;

  const _MonthPill({required this.date});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          Text('${months[date.month - 1]} ${date.year}',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800)),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _BudgetStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 30, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String id;
  final Color color;

  const _CategoryIcon(this.id, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(_emoji(id), style: const TextStyle(fontSize: 26)),
    );
  }
}

String _emoji(String id) {
  return switch (id) {
    'food' => '🍔',
    'transport' => '🚗',
    'entertainment' => '🎬',
    'shopping' => '🛍️',
    'bills' => '📄',
    'health' => '🏥',
    _ => '📦',
  };
}

class _DonutEntry {
  final double value;
  final Color color;

  const _DonutEntry(this.value, this.color);
}

class _BudgetDonutPainter extends CustomPainter {
  final List<_DonutEntry> entries;

  const _BudgetDonutPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round;
    final total = entries.fold(0.0, (sum, item) => sum + item.value);
    if (total <= 0) {
      const fallback = [
        _DonutEntry(35, Color(0xFFFF5B7F)),
        _DonutEntry(20, Color(0xFFFFD44D)),
        _DonutEntry(16, AppColors.green),
        _DonutEntry(8, AppColors.purple),
      ];
      _paintEntries(canvas, rect, stroke, fallback);
      return;
    }
    _paintEntries(canvas, rect, stroke, entries);
  }

  void _paintEntries(
      Canvas canvas, Rect rect, Paint stroke, List<_DonutEntry> data) {
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    var start = -math.pi / 2;
    for (final item in data) {
      final sweep = item.value / total * math.pi * 2;
      stroke.color = item.color;
      canvas.drawArc(rect.deflate(18), start, sweep - 0.04, false, stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _BudgetDonutPainter oldDelegate) =>
      oldDelegate.entries != entries;
}
