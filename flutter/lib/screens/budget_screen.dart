import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _activeMonth = DateTime.now();
  String _selectedSourceId = 'all';

  void _prevMonth() {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + 1);
    });
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final categories = appState.categories;
    final isAllSelected = _selectedSourceId == 'all';

    final sourceNameById = {
      for (final s in appState.sources) s.id: s.name
    };

    // Calculate monthly cap
    final monthBudgetCap = isAllSelected
        ? appState.sources.fold(0.0, (sum, s) => sum + appState.getBudget(s.id).monthBudgetCap)
        : appState.getBudget(_selectedSourceId).monthBudgetCap;

    // Filter transactions to this month, source, and expense/debit
    final monthTransactions = appState.transactions.where((tx) {
      final parsedDate = DateTime.tryParse(tx.date);
      if (parsedDate == null) return false;
      final isMonth = parsedDate.year == _activeMonth.year && parsedDate.month == _activeMonth.month;
      final isSource = isAllSelected ? true : tx.source == _selectedSourceId;
      return isMonth && isSource && tx.isDebit;
    }).toList();

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

    // Build budget categories list
    final List<_BudgetCategoryView> budgetCategories = categories.map((cat) {
      final spent = monthTransactions
          .where((tx) => tx.category == cat.id)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final fallback = (monthBudgetCap / math.max(1, categories.length)).roundToDouble();
      final limit = isAllSelected
          ? appState.sources.fold(0.0, (sum, s) => sum + appState.getLimit(s.id, cat.id, fallback))
          : appState.getLimit(_selectedSourceId, cat.id, fallback);

      return _BudgetCategoryView(
        id: cat.id,
        name: cat.name,
        icon: cat.icon,
        color: cat.color,
        spent: spent,
        limit: limit,
      );
    }).toList();

    // Totals
    final totalSpent = budgetCategories.fold(0.0, (sum, c) => sum + c.spent);
    final remaining = math.max(0.0, monthBudgetCap - totalSpent);
    final overBudgetCount = budgetCategories.where((c) => c.spent > c.limit).length;
    final percentUsed = monthBudgetCap > 0 ? (totalSpent / monthBudgetCap * 100) : 0.0;
    final isLandscape = Responsive.isLandscape(context);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      floatingActionButton: !isAllSelected
          ? FloatingActionButton(
              onPressed: () => _openEditCapDialog(appState, budgetCategories, monthBudgetCap),
              backgroundColor: AppColors.purple,
              child: Icon(Icons.edit_outlined, color: Colors.white, size: 24.r(context)),
            )
          : null,
      body: SafeArea(
        child: Responsive.constrained(
          context,
          isLandscape
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 12.r(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.w900),
                              children: const [
                                TextSpan(text: 'My ', style: TextStyle(color: AppColors.textPrimary)),
                                TextSpan(text: 'Budget', style: TextStyle(color: AppColors.purple)),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r(context), vertical: 8.r(context)),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard,
                              borderRadius: BorderRadius.circular(22.r(context)),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _prevMonth,
                                  child: Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 18.r(context)),
                                ),
                                SizedBox(width: 6.r(context)),
                                Text(
                                  _monthLabel(_activeMonth),
                                  style: GoogleFonts.spaceMono(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.r(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 6.r(context)),
                                GestureDetector(
                                  onTap: _nextMonth,
                                  child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18.r(context)),
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
                            // Left Column (Donut chart, Legends, Stats Row)
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(right: 16.r(context), bottom: 20.r(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Custom Donut Chart
                                    SizedBox(
                                      height: 250.r(context),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CustomPaint(
                                            size: Size(220.r(context), 220.r(context)),
                                            painter: _BudgetDonutPainter(
                                              entries: budgetCategories.map((c) => _DonutEntry(c.spent, c.color)).toList(),
                                              borderColor: AppColors.darkBorder,
                                              strokeWidth: 22.r(context),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'TOTAL SPENT',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11.r(context),
                                                  letterSpacing: 1.2,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(height: 6.r(context)),
                                              Text(
                                                appState.formatCurrency(totalSpent),
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 30.r(context),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              SizedBox(height: 4.r(context)),
                                              Text(
                                                'of ${appState.formatCurrency(monthBudgetCap)} budget',
                                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 14.r(context)),
                                    // Legends
                                    SizedBox(
                                      height: 30.r(context),
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: budgetCategories.length,
                                        separatorBuilder: (_, __) => SizedBox(width: 14.r(context)),
                                        itemBuilder: (context, index) {
                                          final item = budgetCategories[index];
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8.r(context),
                                                height: 8.r(context),
                                                decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                                              ),
                                              SizedBox(width: 6.r(context)),
                                              Text(
                                                item.name,
                                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 18.r(context)),
                                    // Stats Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _SummaryChip(
                                            label: 'REMAINING',
                                            value: appState.formatCurrency(remaining),
                                            color: AppColors.green,
                                          ),
                                        ),
                                        SizedBox(width: 8.r(context)),
                                        Expanded(
                                          child: _SummaryChip(
                                            label: 'OVER BUDGET',
                                            value: '$overBudgetCount',
                                            color: AppColors.orange,
                                          ),
                                        ),
                                        SizedBox(width: 8.r(context)),
                                        Expanded(
                                          child: _SummaryChip(
                                            label: 'USED',
                                            value: '${percentUsed.round()}%',
                                            color: AppColors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Divider
                            Container(
                              width: 1.r(context),
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              margin: EdgeInsets.symmetric(horizontal: 4.r(context)),
                            ),
                            // Right Column (Sources list, Categories spending bars)
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(left: 16.r(context), bottom: 20.r(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_balance_wallet_outlined, color: AppColors.purple, size: 18.r(context)),
                                        SizedBox(width: 8.r(context)),
                                        Text(
                                          isAllSelected
                                              ? 'All Sources Budget'
                                              : '${sourceNameById[_selectedSourceId] ?? 'Source'} Budget',
                                          style: TextStyle(
                                            color: AppColors.purple,
                                            fontSize: 14.r(context),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 14.r(context)),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedSourceId = 'all'),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 22.r(context), vertical: 12.r(context)),
                                          decoration: BoxDecoration(
                                            color: isAllSelected ? AppColors.purple : AppColors.darkCard,
                                            borderRadius: BorderRadius.circular(22.r(context)),
                                            border: Border.all(
                                              color: isAllSelected ? AppColors.purple : AppColors.darkBorder,
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
                                                  color: isSelected ? AppColors.purple : AppColors.darkBorder,
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
                                    SizedBox(height: 28.r(context)),
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
                                    ...budgetCategories.map((category) {
                                      final percent = category.limit <= 0 ? 0.0 : (category.spent / category.limit).clamp(0.0, 1.0);
                                      return FinanceCard(
                                        margin: EdgeInsets.only(bottom: 12.r(context)),
                                        padding: EdgeInsets.all(16.r(context)),
                                        onTap: () => _openCategoryLimitBottomSheet(appState, category, monthBudgetCap, budgetCategories),
                                        child: Row(
                                          children: [
                                            _CategoryIcon(category.id, category.color),
                                            SizedBox(width: 14.r(context)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    category.name,
                                                    style: TextStyle(fontSize: 17.r(context), fontWeight: FontWeight.w800),
                                                  ),
                                                  SizedBox(height: 12.r(context)),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(6.r(context)),
                                                    child: LinearProgressIndicator(
                                                      value: percent,
                                                      minHeight: 7.r(context),
                                                      backgroundColor: AppColors.darkBorder,
                                                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 14.r(context)),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  appState.formatCurrency(category.spent),
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 17.r(context),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(height: 12.r(context)),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${(percent * 100).round()}%',
                                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.r(context)),
                                                    ),
                                                    SizedBox(width: 8.r(context)),
                                                    Container(
                                                      width: 8.r(context),
                                                      height: 8.r(context),
                                                      decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(20.r(context), 24.r(context), 20.r(context), 110.r(context)),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.w900),
                            children: const [
                              TextSpan(text: 'My ', style: TextStyle(color: AppColors.textPrimary)),
                              TextSpan(text: 'Budget', style: TextStyle(color: AppColors.purple)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.r(context), vertical: 8.r(context)),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(22.r(context)),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _prevMonth,
                                child: Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 18.r(context)),
                              ),
                              SizedBox(width: 6.r(context)),
                              Text(
                                _monthLabel(_activeMonth),
                                style: GoogleFonts.spaceMono(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.r(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 6.r(context)),
                              GestureDetector(
                                onTap: _nextMonth,
                                child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18.r(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.r(context)),
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: AppColors.purple, size: 18.r(context)),
                        SizedBox(width: 8.r(context)),
                        Text(
                          isAllSelected
                              ? 'All Sources Budget'
                              : '${sourceNameById[_selectedSourceId] ?? 'Source'} Budget',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 14.r(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.r(context)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSourceId = 'all'),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 22.r(context), vertical: 12.r(context)),
                          decoration: BoxDecoration(
                            color: isAllSelected ? AppColors.purple : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(22.r(context)),
                            border: Border.all(
                              color: isAllSelected ? AppColors.purple : AppColors.darkBorder,
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
                                  color: isSelected ? AppColors.purple : AppColors.darkBorder,
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
                    SizedBox(height: 28.r(context)),
                    // Custom Donut Chart
                    SizedBox(
                      height: 250.r(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(220.r(context), 220.r(context)),
                            painter: _BudgetDonutPainter(
                              entries: budgetCategories.map((c) => _DonutEntry(c.spent, c.color)).toList(),
                              borderColor: AppColors.darkBorder,
                              strokeWidth: 22.r(context),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOTAL SPENT',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.r(context),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6.r(context)),
                              Text(
                                appState.formatCurrency(totalSpent),
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 30.r(context),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4.r(context)),
                              Text(
                                'of ${appState.formatCurrency(monthBudgetCap)} budget',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.r(context)),
                    // Legends
                    SizedBox(
                      height: 30.r(context),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: budgetCategories.length,
                        separatorBuilder: (_, __) => SizedBox(width: 14.r(context)),
                        itemBuilder: (context, index) {
                          final item = budgetCategories[index];
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.r(context),
                                height: 8.r(context),
                                decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                              ),
                              SizedBox(width: 6.r(context)),
                              Text(
                                item.name,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 18.r(context)),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryChip(
                            label: 'REMAINING',
                            value: appState.formatCurrency(remaining),
                            color: AppColors.green,
                          ),
                        ),
                        SizedBox(width: 8.r(context)),
                        Expanded(
                          child: _SummaryChip(
                            label: 'OVER BUDGET',
                            value: '$overBudgetCount',
                            color: AppColors.orange,
                          ),
                        ),
                        SizedBox(width: 8.r(context)),
                        Expanded(
                          child: _SummaryChip(
                            label: 'USED',
                            value: '${percentUsed.round()}%',
                            color: AppColors.purple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.r(context)),
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
                    ...budgetCategories.map((category) {
                      final percent = category.limit <= 0 ? 0.0 : (category.spent / category.limit).clamp(0.0, 1.0);
                      return FinanceCard(
                        margin: EdgeInsets.only(bottom: 12.r(context)),
                        padding: EdgeInsets.all(16.r(context)),
                        onTap: () => _openCategoryLimitBottomSheet(appState, category, monthBudgetCap, budgetCategories),
                        child: Row(
                          children: [
                            _CategoryIcon(category.id, category.color),
                            SizedBox(width: 14.r(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(fontSize: 17.r(context), fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(height: 12.r(context)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r(context)),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      minHeight: 7.r(context),
                                      backgroundColor: AppColors.darkBorder,
                                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 14.r(context)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  appState.formatCurrency(category.spent),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 17.r(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 12.r(context)),
                                Row(
                                  children: [
                                    Text(
                                      '${(percent * 100).round()}%',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.r(context)),
                                    ),
                                    SizedBox(width: 8.r(context)),
                                    Container(
                                      width: 8.r(context),
                                      height: 8.r(context),
                                      decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                                    ),
                                  ],
                                ),
                              ],
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

  void _openCategoryLimitBottomSheet(
    AppStateModel appState,
    _BudgetCategoryView category,
    double cap,
    List<_BudgetCategoryView> items,
  ) {
    if (_selectedSourceId == 'all') return;

    final controller = TextEditingController(text: category.limit.toStringAsFixed(0));
    final double totalOthers = items
        .where((item) => item.id != category.id)
        .fold(0.0, (sum, item) => sum + item.limit);

    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      constraints: BoxConstraints(
        maxWidth: (isTablet || isLandscape) ? 500.r(context) : double.infinity,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r(context))),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.r(context), 18.r(context), 18.r(context), MediaQuery.of(context).viewInsets.bottom + 24.r(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Category Limit',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20.r(context), fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.r(context)),
              Text(
                category.name,
                style: GoogleFonts.spaceMono(color: AppColors.textSecondary, fontSize: 13.r(context)),
              ),
              SizedBox(height: 16.r(context)),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Monthly limit',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.darkBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r(context)), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.r(context), vertical: 12.r(context)),
                ),
              ),
              SizedBox(height: 12.r(context)),
              Text(
                'Limits total must equal monthly cap (${appState.formatCurrency(cap)})',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
              ),
              SizedBox(height: 20.r(context)),
              SizedBox(
                width: double.infinity,
                height: 48.r(context),
                child: ElevatedButton(
                  onPressed: () {
                    final nextVal = double.tryParse(controller.text) ?? 0;
                    final total = totalOthers + nextVal;
                    if (total.round() != cap.round()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Total limits (${total.round()}) must equal cap (${cap.round()})'),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                      return;
                    }
                    appState.setCategoryLimit(_selectedSourceId, category.id, nextVal);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.darkBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
                  ),
                  child: Text('Save Limit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.r(context))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditCapDialog(
    AppStateModel appState,
    List<_BudgetCategoryView> items,
    double currentCap,
  ) {
    final capController = TextEditingController(text: currentCap.toStringAsFixed(0));
    final limitControllers = {
      for (final item in items) item.id: TextEditingController(text: item.limit.toStringAsFixed(0))
    };
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final double typedCap = double.tryParse(capController.text) ?? 0;
            double totalLimits = 0;
            limitControllers.forEach((_, c) {
              totalLimits += double.tryParse(c.text) ?? 0;
            });
            final isBalanced = typedCap.round() == totalLimits.round();

            return Dialog(
              backgroundColor: AppColors.darkCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r(context))),
              insetPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 24.r(context)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500.r(context)),
                child: Padding(
                  padding: EdgeInsets.all(18.r(context)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Budget Limits',
                            style: TextStyle(color: Colors.white, fontSize: 20.r(context), fontWeight: FontWeight.w800),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: AppColors.textSecondary, size: 24.r(context)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.r(context)),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Budget Cap',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.r(context), fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 8.r(context)),
                              TextField(
                                controller: capController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Monthly Cap',
                                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                                  filled: true,
                                  fillColor: AppColors.darkBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r(context)),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 18.r(context)),
                              Text(
                                'Category Limits',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.r(context), fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 10.r(context)),
                              ...items.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.r(context)),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_emoji(item.id)} ${item.name}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 100.r(context),
                                        child: TextField(
                                          controller: limitControllers[item.id],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.white),
                                          textAlign: TextAlign.end,
                                          onChanged: (_) => setState(() {}),
                                          decoration: InputDecoration(
                                            hintText: 'Limit',
                                            hintStyle: const TextStyle(color: AppColors.textSecondary),
                                            filled: true,
                                            fillColor: AppColors.darkBg,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10.r(context), vertical: 8.r(context)),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.r(context)),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 16.r(context)),
                              Container(
                                padding: EdgeInsets.all(12.r(context)),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBg,
                                  border: Border.all(color: AppColors.darkBorder),
                                  borderRadius: BorderRadius.circular(12.r(context)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total limits: ${appState.formatCurrency(totalLimits)}',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                                    ),
                                    SizedBox(height: 4.r(context)),
                                    Text(
                                      'Monthly cap: ${appState.formatCurrency(typedCap)}',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.r(context)),
                                    ),
                                    SizedBox(height: 6.r(context)),
                                    Text(
                                      isBalanced ? 'Balanced' : 'Limits must exactly equal monthly cap',
                                      style: TextStyle(
                                        color: isBalanced ? AppColors.green : AppColors.orange,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.r(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r(context)),
                      SizedBox(
                        width: double.infinity,
                        height: 48.r(context),
                        child: ElevatedButton(
                          onPressed: isBalanced
                              ? () {
                                  final nextLimits = <String, double>{};
                                  limitControllers.forEach((id, c) {
                                    nextLimits[id] = double.tryParse(c.text) ?? 0;
                                  });
                                  appState.setAllBudgetLimits(_selectedSourceId, typedCap, nextLimits);
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            disabledBackgroundColor: AppColors.green.withValues(alpha: 0.45),
                            foregroundColor: AppColors.darkBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
                          ),
                          child: Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.r(context))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BudgetCategoryView {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final double spent;
  final double limit;

  _BudgetCategoryView({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.spent,
    required this.limit,
  });
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.r(context)),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(14.r(context)),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.r(context)),
              child: Text(
                value,
                style: TextStyle(color: color, fontSize: 22.r(context), fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(height: 4.r(context)),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              color: AppColors.textSecondary,
              fontSize: 10.r(context),
              letterSpacing: 1.r(context),
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

class _DonutEntry {
  final double value;
  final Color color;

  const _DonutEntry(this.value, this.color);
}

class _BudgetDonutPainter extends CustomPainter {
  final List<_DonutEntry> entries;
  final Color borderColor;
  final double strokeWidth;

  const _BudgetDonutPainter({
    required this.entries,
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = borderColor;

    // Draw background circle
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, math.pi * 2, false, backgroundPaint);

    final activeEntries = entries.where((c) => c.value > 0).toList();
    final total = activeEntries.fold(0.0, (sum, item) => sum + item.value);

    if (total > 0) {
      var start = -math.pi / 2;
      for (final item in activeEntries) {
        final sweep = item.value / total * math.pi * 2;
        stroke.color = item.color;
        canvas.drawArc(rect.deflate(strokeWidth / 2), start, sweep, false, stroke);
        start += sweep;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BudgetDonutPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
