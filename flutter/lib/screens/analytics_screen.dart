import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
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
  String _selectedSourceId = 'all';

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

  ChartModel _buildChartModel(List<TransactionModel> debitTransactions) {
    if (_rangeType == 'year') {
      final buckets = List<double>.filled(12, 0.0);
      for (final t in debitTransactions) {
        final parsed = DateTime.tryParse(t.date);
        if (parsed != null && parsed.year == _toDate.year) {
          buckets[parsed.month - 1] += t.amount;
        }
      }
      return ChartModel(
        points: buckets,
        labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      );
    }

    final totalDays = _toDate.difference(_fromDate).inDays + 1;

    if (_rangeType == 'month') {
      final weekCount = (totalDays / 7.0).ceil().clamp(1, 6);
      final weekBuckets = List<double>.filled(weekCount, 0.0);
      final rangeStart = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);

      for (final t in debitTransactions) {
        final txDate = DateTime.tryParse(t.date);
        if (txDate != null) {
          final cleanTxDate = DateTime(txDate.year, txDate.month, txDate.day);
          final dayDiff = cleanTxDate.difference(rangeStart).inDays;
          final weekIndex = (dayDiff / 7).floor().clamp(0, weekCount - 1);
          weekBuckets[weekIndex] += t.amount;
        }
      }

      final labels = List.generate(weekCount, (i) => 'W${i + 1}');
      return ChartModel(points: weekBuckets, labels: labels);
    }

    // Default: 'week' or custom
    final labels = <String>[];
    final points = List<double>.filled(totalDays.clamp(1, 31), 0.0);
    final rangeStart = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var i = 0; i < points.length; i++) {
      final d = rangeStart.add(Duration(days: i));
      if (totalDays <= 7) {
        labels.add(weekdayNames[d.weekday - 1]);
      } else {
        labels.add(d.day.toString());
      }
    }

    for (final t in debitTransactions) {
      final txDate = DateTime.tryParse(t.date);
      if (txDate != null) {
        final cleanTx = DateTime(txDate.year, txDate.month, txDate.day);
        final diff = cleanTx.difference(rangeStart).inDays;
        if (diff >= 0 && diff < points.length) {
          points[diff] += t.amount;
        }
      }
    }

    return ChartModel(points: points, labels: labels);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final isAllSelected = _selectedSourceId == 'all';

    // Calculate source balances
    final Map<String, double> balances = {};
    for (final source in appState.sources) {
      final sourceTx = appState.transactions.where((t) => t.source == source.id);
      var bal = source.startingAmount;
      for (final tx in sourceTx) {
        if (tx.isCredit) bal += tx.amount;
        if (tx.isDebit) bal -= tx.amount;
      }
      balances[source.id] = bal;
    }

    // Filter transactions based on date range and source
    final filteredTransactions = appState.transactions.where((t) {
      final parsedDate = DateTime.tryParse(t.date);
      if (parsedDate == null) return false;
      final start = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
      final end = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);
      final isMonth = !parsedDate.isBefore(start) && !parsedDate.isAfter(end);
      final isSource = isAllSelected ? true : t.source == _selectedSourceId;
      return isMonth && isSource;
    }).toList();

    final debitTransactions = filteredTransactions.where((t) => t.isDebit).toList();

    final expense = debitTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final daysCount = _toDate.difference(_fromDate).inDays + 1;
    final dailyAverage = daysCount <= 0 ? expense : expense / daysCount;

    final breakdown = <String, double>{};
    for (final transaction in debitTransactions) {
      breakdown[transaction.category] =
          (breakdown[transaction.category] ?? 0) + transaction.amount;
    }
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final chartModel = _buildChartModel(debitTransactions);
    final maxVal = chartModel.points.isEmpty ? 10.0 : chartModel.points.reduce(math.max);
    final chartMax = maxVal <= 0 ? 10.0 : maxVal * 1.15;

    final isLandscape = Responsive.isLandscape(context);

    if (isLandscape) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 12.r(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.w900),
                        children: const [
                          TextSpan(text: 'Spend ', style: TextStyle(color: AppColors.textPrimary)),
                          TextSpan(text: 'Analytics', style: TextStyle(color: AppColors.blue)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(22.r(context)),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 12.r(context)),
                          SizedBox(width: 6.r(context)),
                          Text(
                            '${_toDate.year}',
                            style: GoogleFonts.spaceMono(
                              color: AppColors.textSecondary,
                              fontSize: 12.r(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.r(context)),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(right: 12.r(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedSourceId = 'all'),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
                                      decoration: BoxDecoration(
                                        color: isAllSelected ? AppColors.blue : AppColors.darkCard,
                                        borderRadius: BorderRadius.circular(22.r(context)),
                                        border: Border.all(
                                          color: isAllSelected ? AppColors.blue : AppColors.darkBorder,
                                        ),
                                      ),
                                      child: Text(
                                        'All Sources',
                                        style: TextStyle(
                                          color: isAllSelected ? Colors.white : AppColors.textSecondary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.r(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.r(context)),
                              SizedBox(
                                height: 110.r(context),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: appState.sources.length,
                                  separatorBuilder: (_, __) => SizedBox(width: 10.r(context)),
                                  itemBuilder: (context, index) {
                                    final source = appState.sources[index];
                                    final isSelected = _selectedSourceId == source.id;
                                    final bal = balances[source.id] ?? 0.0;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedSourceId = source.id),
                                      child: Container(
                                        width: 150.r(context),
                                        padding: EdgeInsets.all(12.r(context)),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkCard,
                                          borderRadius: BorderRadius.circular(12.r(context)),
                                          border: Border.all(
                                            color: isSelected ? AppColors.blue : AppColors.darkBorder,
                                            width: 1.5.r(context),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              source.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13.r(context),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Balance',
                                              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.r(context)),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                appState.formatCurrency(bal),
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 16.r(context),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 18.r(context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RangeChip(
                                      label: 'Week',
                                      active: _rangeType == 'week',
                                      onTap: () => setState(() => _setToCurrentWeek()),
                                    ),
                                  ),
                                  SizedBox(width: 8.r(context)),
                                  Expanded(
                                    child: _RangeChip(
                                      label: 'Month',
                                      active: _rangeType == 'month',
                                      onTap: () => setState(() => _setToCurrentMonth()),
                                    ),
                                  ),
                                  SizedBox(width: 8.r(context)),
                                  Expanded(
                                    child: _RangeChip(
                                      label: 'Year',
                                      active: _rangeType == 'year',
                                      onTap: () => setState(() => _setToCurrentYear()),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.r(context)),
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
                                  SizedBox(width: 8.r(context)),
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
                              SizedBox(height: 8.r(context)),
                              GestureDetector(
                                onTap: () => setState(() => _setToCurrentWeek()),
                                child: Text(
                                  'Use current week range',
                                  style: GoogleFonts.spaceMono(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.r(context),
                                  ),
                                ),
                              ),
                              SizedBox(height: 18.r(context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'TOTAL EXPENSE',
                                      value: appState.formatCurrency(expense),
                                      color: AppColors.orange,
                                    ),
                                  ),
                                  SizedBox(width: 8.r(context)),
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'DAILY AVERAGE',
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
                        flex: 5,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(left: 12.r(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FinanceCard(
                                padding: EdgeInsets.fromLTRB(12.r(context), 16.r(context), 12.r(context), 16.r(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total spending',
                                      style: TextStyle(fontSize: 16.r(context), fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(height: 16.r(context)),
                                    SizedBox(
                                      height: 160.r(context),
                                      child: CustomPaint(
                                        painter: _LineChartPainter(
                                          context: context,
                                          values: chartModel.points,
                                          labels: chartModel.labels,
                                          maxValue: chartMax,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 18.r(context)),
                              Row(
                                children: [
                                  Icon(Icons.pie_chart_outline, color: const Color(0xFFFFD44D), size: 16.r(context)),
                                  SizedBox(width: 8.r(context)),
                                  Text(
                                    'CATEGORIES',
                                    style: TextStyle(
                                      color: const Color(0xFFFFD44D),
                                      fontSize: 14.r(context),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.r(context)),
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
                                    margin: EdgeInsets.only(bottom: 10.r(context)),
                                    padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 12.r(context)),
                                    child: Row(
                                      children: [
                                        _CategoryIcon(category.id, category.color),
                                        SizedBox(width: 12.r(context)),
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: TextStyle(fontSize: 15.r(context), fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Text(
                                          appState.formatCurrency(entry.value),
                                          style: TextStyle(
                                            color: AppColors.orange,
                                            fontSize: 15.r(context),
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Responsive.constrained(
          context,
          ListView(
            padding: EdgeInsets.fromLTRB(20.r(context), 22.r(context), 20.r(context), 110.r(context)),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.w900),
                      children: const [
                        TextSpan(text: 'Spend ', style: TextStyle(color: AppColors.textPrimary)),
                        TextSpan(text: 'Analytics', style: TextStyle(color: AppColors.blue)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(22.r(context)),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 12.r(context)),
                        SizedBox(width: 6.r(context)),
                        Text(
                          '${_toDate.year}',
                          style: GoogleFonts.spaceMono(
                            color: AppColors.textSecondary,
                            fontSize: 12.r(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.r(context)),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSourceId = 'all'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 22.r(context), vertical: 12.r(context)),
                    decoration: BoxDecoration(
                      color: isAllSelected ? AppColors.blue : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(22.r(context)),
                      border: Border.all(
                        color: isAllSelected ? AppColors.blue : AppColors.darkBorder,
                      ),
                    ),
                    child: Text(
                      'All Sources',
                      style: TextStyle(
                        color: isAllSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.r(context),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.r(context)),
              SizedBox(
                height: 142.r(context),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: appState.sources.length,
                  separatorBuilder: (_, __) => SizedBox(width: 14.r(context)),
                  itemBuilder: (context, index) {
                    final source = appState.sources[index];
                    final isSelected = _selectedSourceId == source.id;
                    final bal = balances[source.id] ?? 0.0;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSourceId = source.id),
                      child: Container(
                        width: 182.r(context),
                        padding: EdgeInsets.all(16.r(context)),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(16.r(context)),
                          border: Border.all(
                            color: isSelected ? AppColors.blue : AppColors.darkBorder,
                            width: 1.5.r(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${source.type} source',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.r(context)),
                            ),
                            SizedBox(height: 4.r(context)),
                            Text(
                              source.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16.r(context),
                                fontWeight: FontWeight.w800,
                                  ),
                                ),
                            const Spacer(),
                            Text(
                              'Current balance',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.r(context)),
                            ),
                            SizedBox(height: 4.r(context)),
                            FittedBox(
                              child: Text(
                                appState.formatCurrency(bal),
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 20.r(context),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.r(context)),
              Row(
                children: [
                  Expanded(
                    child: _RangeChip(
                      label: 'Week',
                      active: _rangeType == 'week',
                      onTap: () => setState(() => _setToCurrentWeek()),
                    ),
                  ),
                  SizedBox(width: 10.r(context)),
                  Expanded(
                    child: _RangeChip(
                      label: 'Month',
                      active: _rangeType == 'month',
                      onTap: () => setState(() => _setToCurrentMonth()),
                    ),
                  ),
                  SizedBox(width: 10.r(context)),
                  Expanded(
                    child: _RangeChip(
                      label: 'Year',
                      active: _rangeType == 'year',
                      onTap: () => setState(() => _setToCurrentYear()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.r(context)),
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
                  SizedBox(width: 12.r(context)),
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
              SizedBox(height: 12.r(context)),
              GestureDetector(
                onTap: () => setState(() => _setToCurrentWeek()),
                child: Text(
                  'Use current week range',
                  style: GoogleFonts.spaceMono(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.r(context),
                  ),
                ),
              ),
              SizedBox(height: 24.r(context)),
              FinanceCard(
                padding: EdgeInsets.fromLTRB(16.r(context), 20.r(context), 16.r(context), 20.r(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total spending',
                      style: TextStyle(fontSize: 18.r(context), fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 20.r(context)),
                    SizedBox(
                      height: 220.r(context),
                      child: CustomPaint(
                        painter: _LineChartPainter(
                          context: context,
                          values: chartModel.points,
                          labels: chartModel.labels,
                          maxValue: chartMax,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.r(context)),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'TOTAL EXPENSE',
                      value: appState.formatCurrency(expense),
                      color: AppColors.orange,
                    ),
                  ),
                  SizedBox(width: 12.r(context)),
                  Expanded(
                    child: _MetricTile(
                      label: 'DAILY AVERAGE',
                      value: appState.formatCurrency(dailyAverage),
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.r(context)),
              Row(
                children: [
                  Icon(Icons.pie_chart_outline, color: const Color(0xFFFFD44D), size: 18.r(context)),
                  SizedBox(width: 8.r(context)),
                  Text(
                    'CATEGORIES',
                    style: TextStyle(
                      color: const Color(0xFFFFD44D),
                      fontSize: 16.r(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.r(context)),
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
                    margin: EdgeInsets.only(bottom: 12.r(context)),
                    padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 16.r(context)),
                    child: Row(
                      children: [
                        _CategoryIcon(category.id, category.color),
                        SizedBox(width: 14.r(context)),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(fontSize: 17.r(context), fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          appState.formatCurrency(entry.value),
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 17.r(context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartModel {
  final List<double> points;
  final List<String> labels;
  ChartModel({required this.points, required this.labels});
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
        height: 48.r(context),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(color: active ? AppColors.blue : AppColors.darkBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 14.r(context),
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _DateBox({required this.label, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: EdgeInsets.symmetric(horizontal: 14.r(context), vertical: 12.r(context)),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceMono(color: AppColors.textSecondary, fontSize: 11.r(context)),
                ),
                SizedBox(height: 4.r(context)),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r(context), fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Icon(Icons.calendar_month_outlined, color: color, size: 18.r(context)),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: EdgeInsets.symmetric(vertical: 18.r(context), horizontal: 10.r(context)),
      child: Column(
        children: [
          FittedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.r(context)),
              child: Text(
                value,
                style: TextStyle(color: color, fontSize: 22.r(context), fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(height: 6.r(context)),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              color: AppColors.textSecondary,
              fontSize: 10.r(context),
              letterSpacing: 1.2.r(context),
            ),
          ),
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
      width: 50.r(context),
      height: 50.r(context),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14.r(context)),
      ),
      child: Text(_emoji(id), style: TextStyle(fontSize: 24.r(context))),
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
  final BuildContext context;
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  const _LineChartPainter({required this.context, required this.values, required this.labels, required this.maxValue});

  String _formatShortCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(0)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(0)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return '₹${value.toStringAsFixed(0)}';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final leftMargin = 45.0.r(context);
    final bottomMargin = 20.0.r(context);
    final rightMargin = 10.0.r(context);
    final topMargin = 10.0.r(context);

    final chartRect = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    final gridPaint = Paint()
      ..color = AppColors.darkBorder.withValues(alpha: 0.35)
      ..strokeWidth = 1.r(context);

    final textStyle = GoogleFonts.spaceMono(
      color: AppColors.textSecondary,
      fontSize: 9.r(context),
    );

    // Draw Y-axis gridlines and labels
    const ySegments = 4;
    for (var i = 0; i <= ySegments; i++) {
      final y = chartRect.bottom - (chartRect.height * i / ySegments);
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);

      final val = maxValue * i / ySegments;
      final textPainter = TextPainter(
        text: TextSpan(text: _formatShortCurrency(val), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(chartRect.left - textPainter.width - 6.r(context), y - textPainter.height / 2),
      );
    }

    if (values.isEmpty) return;

    // Draw X-axis gridlines and labels
    final xSegments = values.length - 1;
    final skipMod = (values.length > 15)
        ? 4
        : (values.length > 7)
            ? 2
            : 1;

    for (var i = 0; i < values.length; i++) {
      final x = xSegments == 0
          ? chartRect.left
          : chartRect.left + (chartRect.width * i / xSegments);

      // Draw gridline
      if (xSegments > 0) {
        canvas.drawLine(Offset(x, chartRect.top), Offset(x, chartRect.bottom), gridPaint);
      }

      // Draw label
      if (i % skipMod == 0 && i < labels.length) {
        final textPainter = TextPainter(
          text: TextSpan(text: labels[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, chartRect.bottom + 6.r(context)),
        );
      }
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = xSegments == 0
          ? chartRect.left
          : chartRect.left + (chartRect.width * i / xSegments);
      final y = chartRect.bottom - (values[i] / maxValue).clamp(0.0, 1.0) * chartRect.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill path
    if (xSegments > 0) {
      final fill = Path.from(path)
        ..lineTo(chartRect.right, chartRect.bottom)
        ..lineTo(chartRect.left, chartRect.bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0x40FFD44D), Color(0x00FFD44D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(chartRect),
      );
    }

    // Draw Line
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD44D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.r(context)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels || oldDelegate.maxValue != maxValue;
}
