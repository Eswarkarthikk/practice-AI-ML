import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_scaffold.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _rangeType = 'week';
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _setToCurrentWeek();
  }

  void _setToCurrentWeek() {
    _rangeType = 'week';
    final now = DateTime.now();
    _fromDate = now.subtract(Duration(days: now.weekday - 1));
    _toDate = _fromDate.add(const Duration(days: 6));
  }

  void _setToCurrentMonth() {
    _rangeType = 'month';
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month + 1, 0);
  }

  void _setToCurrentYear() {
    _rangeType = 'year';
    final now = DateTime.now();
    _fromDate = DateTime(now.year, 1, 1);
    _toDate = DateTime(now.year, 12, 31);
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate.add(const Duration(days: 1));
          }
        } else {
          _toDate = picked;
          if (_fromDate.isAfter(_toDate)) {
            _fromDate = _toDate.subtract(const Duration(days: 1));
          }
        }
        _rangeType = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    
    // Filter transactions based on selected range
    final filteredTransactions = appState.transactions.where((t) {
      final parsedDate = DateTime.tryParse(t.date);
      if (parsedDate == null) return false;
      final start = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
      final end = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);
      return !parsedDate.isBefore(start) && !parsedDate.isAfter(end);
    }).toList();

    final expense = filteredTransactions
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final daysCount = _toDate.difference(_fromDate).inDays + 1;
    final dailyAverage = daysCount <= 0 ? expense : expense / daysCount;

    final breakdown = <String, double>{};
    for (final transaction in filteredTransactions.where((item) => item.isDebit)) {
      breakdown[transaction.category] =
          (breakdown[transaction.category] ?? 0) + transaction.amount;
    }
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
          children: [
            Row(
              children: [
                const Expanded(
                  child: SplitTitle(
                    first: 'Spend ',
                    second: 'Analytics',
                    color: AppColors.blue,
                    icon: Icons.bar_chart_rounded,
                    size: 30,
                  ),
                ),
                _YearPill(year: _toDate.year),
              ],
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: _FilterPill(label: 'All Sources', active: true),
            ),
            const SizedBox(height: 20),
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
            Row(
              children: [
                Expanded(
                  child: _RangeChip(
                    label: 'Week',
                    active: _rangeType == 'week',
                    onTap: () => setState(() => _setToCurrentWeek()),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _RangeChip(
                    label: 'Month',
                    active: _rangeType == 'month',
                    onTap: () => setState(() => _setToCurrentMonth()),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _RangeChip(
                    label: 'Year',
                    active: _rangeType == 'year',
                    onTap: () => setState(() => _setToCurrentYear()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DateBox(
                    label: 'From',
                    value: _formatDate(_fromDate),
                    color: AppColors.green,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DateBox(
                    label: 'To',
                    value: _formatDate(_toDate),
                    color: const Color(0xFFFFD44D),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _setToCurrentWeek()),
              child: const Text('Use current week range',
                  style: TextStyle(
                      color: AppColors.blue,
                      fontFamily: 'monospace',
                      fontSize: 15)),
            ),
            const SizedBox(height: 24),
            FinanceCard(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total spending',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 300,
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        values: _chartValues(filteredTransactions, _fromDate, _toDate),
                        maxValue: expense <= 0 ? 80000 : expense * 1.15,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'TOTAL EXPENSE',
                    value: appState.formatCurrency(expense),
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricTile(
                    label: 'DAILY AVERAGE',
                    value: appState.formatCurrency(dailyAverage),
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionHeader(),
            const SizedBox(height: 12),
            if (sorted.isEmpty)
              const EmptyFinanceState(
                icon: Icons.pie_chart_outline,
                title: 'No spending yet',
                message: 'Your category totals will appear here.',
              )
            else
              ...sorted.map((entry) {
                final category = appState.categoryById(entry.key);
                return FinanceCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Row(
                    children: [
                      _CategoryIcon(category.id, category.color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(category.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      Text(appState.formatCurrency(entry.value),
                          style: const TextStyle(
                                color: AppColors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

List<double> _chartValues(List<TransactionModel> transactions, DateTime from, DateTime to) {
  final diffDays = to.difference(from).inDays;
  final numPoints = diffDays < 12 ? (diffDays + 1).clamp(2, 12) : 12;
  final points = List<double>.filled(numPoints, 0.0);
  if (diffDays <= 0) {
    return const [0, 80000, 4200, 9400, 1800, 3200, 0, 1200, 0, 0, 0, 0];
  }
  
  for (final t in transactions.where((item) => item.isDebit)) {
    final parsed = DateTime.tryParse(t.date);
    if (parsed == null) continue;
    final tDiff = parsed.difference(from).inDays;
    final percent = tDiff / diffDays;
    final index = (percent * (numPoints - 1)).round().clamp(0, numPoints - 1);
    points[index] += t.amount;
  }

  if (points.every((value) => value == 0)) {
    final defaultPoints = [0, 80000, 4200, 9400, 1800, 3200, 0, 1200, 0, 0, 0, 0];
    return List.generate(numPoints, (i) {
      final idx = (i / numPoints * defaultPoints.length).floor().clamp(0, defaultPoints.length - 1);
      return defaultPoints[idx].toDouble();
    });
  }
  return points;
}

class _YearPill extends StatelessWidget {
  final int year;

  const _YearPill({required this.year});

  @override
  Widget build(BuildContext context) {
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
          Text('$year',
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

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;

  const _FilterPill({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: active ? AppColors.blue : AppColors.darkCard,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(label,
          style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800)),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RangeChip({required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: active ? AppColors.blue : AppColors.darkBorder),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w900,
                fontSize: 16)),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _DateBox(
      {required this.label, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 15)),
              const SizedBox(height: 10),
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900)),
            ]),
          ),
          Icon(Icons.calendar_month_outlined, color: color),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      child: Column(
        children: [
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 28, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 14),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.pie_chart_outline, color: Color(0xFFFFD44D)),
        SizedBox(width: 8),
        Text('CATEGORIES',
            style: TextStyle(
                color: Color(0xFFFFD44D),
                fontSize: 22,
                fontWeight: FontWeight.w900)),
      ],
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
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(_emoji(id), style: const TextStyle(fontSize: 25)),
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

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;

  const _LineChartPainter({required this.values, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.darkBorder.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / maxValue).clamp(0, 1) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x66FFD44D), Color(0x00FFD44D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD44D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.maxValue != maxValue;
}
