import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedCategoryId;
  String? _selectedSourceId;
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSourceId = null;
      _selectedType = null;
      _fromDate = null;
      _toDate = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedSourceId != null ||
      _selectedType != null ||
      _fromDate != null ||
      _toDate != null;

  void _selectCategory(BuildContext context, AppStateModel appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r(context))),
          title: Text(
            'Select Category',
            style: TextStyle(color: Colors.white, fontSize: 18.r(context), fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 320.r(context),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Categories', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...appState.categories.map((cat) => ListTile(
                  leading: Text(cat.icon, style: TextStyle(fontSize: 16.r(context))),
                  title: Text(cat.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = cat.id;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectSource(BuildContext context, AppStateModel appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r(context))),
          title: Text(
            'Select Source',
            style: TextStyle(color: Colors.white, fontSize: 18.r(context), fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 320.r(context),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Sources', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedSourceId = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...appState.sources.map((src) => ListTile(
                  title: Text(src.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedSourceId = src.id;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectType(BuildContext context) {
    final types = [
      {'label': 'All Types', 'value': null},
      {'label': 'Expense', 'value': 'expense'},
      {'label': 'Income', 'value': 'income'},
      {'label': 'Borrow', 'value': 'borrow'},
      {'label': 'Lend', 'value': 'lend'},
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r(context))),
          title: Text(
            'Select Type',
            style: TextStyle(color: Colors.white, fontSize: 18.r(context), fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 320.r(context),
            child: ListView(
              shrinkWrap: true,
              children: types.map((t) => ListTile(
                title: Text(t['label'] as String, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _selectedType = t['value'];
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = null;
        }
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();

    // Apply reactive filters
    final filteredTransactions = appState.transactions.where((t) {
      if (_selectedCategoryId != null && t.category != _selectedCategoryId) return false;
      if (_selectedSourceId != null && t.source != _selectedSourceId) return false;
      if (_selectedType != null && t.type != _selectedType) return false;
      
      final tDate = DateTime.tryParse(t.date);
      if (tDate != null) {
        if (_fromDate != null) {
          final normalizedFrom = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
          final normalizedT = DateTime(tDate.year, tDate.month, tDate.day);
          if (normalizedT.isBefore(normalizedFrom)) return false;
        }
        if (_toDate != null) {
          final normalizedTo = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
          final normalizedT = DateTime(tDate.year, tDate.month, tDate.day);
          if (normalizedT.isAfter(normalizedTo)) return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          context,
          ListView(
            padding: EdgeInsets.fromLTRB(20.r(context), 24.r(context), 20.r(context), 28.r(context)),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SplitTitle(
                      first: 'All ',
                      second: 'Transactions',
                      color: AppColors.blue,
                      size: 22.r(context),
                    ),
                  ),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(horizontal: 10.r(context), vertical: 6.r(context)),
                      ),
                      icon: Icon(Icons.clear_all, size: 16.r(context), color: AppColors.red),
                      label: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 12.r(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: _resetFilters,
                    ),
                ],
              ),
              SizedBox(height: 18.r(context)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectCategory(context, appState),
                      child: _FilterBox(
                        label: 'Category',
                        value: _selectedCategoryId == null
                            ? 'All Categories'
                            : (appState.categoryById(_selectedCategoryId!).name),
                        active: _selectedCategoryId != null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.r(context)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectSource(context, appState),
                      child: _FilterBox(
                        label: 'Source',
                        value: _selectedSourceId == null
                            ? 'All Sources'
                            : (appState.sourceById(_selectedSourceId!)?.name ?? _selectedSourceId!),
                        active: _selectedSourceId != null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.r(context)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectType(context),
                      child: _FilterBox(
                        label: 'Type',
                        value: _selectedType == null
                            ? 'All Types'
                            : _selectedType![0].toUpperCase() + _selectedType!.substring(1),
                        active: _selectedType != null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.r(context)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickFromDate(context),
                      child: _FilterBox(
                        label: 'From',
                        value: _fromDate == null
                            ? 'Select date'
                            : DateFormat('yyyy-MM-dd').format(_fromDate!),
                        icon: Icons.calendar_month_outlined,
                        iconColor: AppColors.green,
                        active: _fromDate != null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.r(context)),
              GestureDetector(
                onTap: () => _pickToDate(context),
                child: _FilterBox(
                  label: 'To',
                  value: _toDate == null
                      ? 'Select date'
                      : DateFormat('yyyy-MM-dd').format(_toDate!),
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFFFFD44D),
                  active: _toDate != null,
                ),
              ),
              SizedBox(height: 18.r(context)),
              if (filteredTransactions.isEmpty)
                const EmptyFinanceState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions found',
                  message: 'Try adjusting your filters.',
                )
              else
                ...filteredTransactions.map(
                  (transaction) => Dismissible(
                    key: ValueKey(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.r(context)),
                      margin: EdgeInsets.only(bottom: 12.r(context)),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16.r(context)),
                      ),
                      child:
                          Icon(Icons.delete_outline, color: AppColors.red, size: 20.r(context)),
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
            fontSize: 16.r(context),
            fontWeight: FontWeight.bold,
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
  final bool active;

  const _FilterBox({
    required this.label,
    required this.value,
    this.icon = Icons.keyboard_arrow_down,
    this.iconColor = AppColors.textSecondary,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
      borderColor: active ? AppColors.blue : AppColors.darkBorder,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: active ? AppColors.blue : AppColors.textSecondary,
                    fontSize: 10.r(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.r(context)),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.r(context),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.r(context)),
          Icon(
            icon,
            color: active ? AppColors.blue : iconColor,
            size: 18.r(context),
          ),
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
      margin: EdgeInsets.only(bottom: 12.r(context)),
      padding: EdgeInsets.symmetric(horizontal: 14.r(context), vertical: 12.r(context)),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 8.r(context),
            height: 8.r(context),
            decoration:
                BoxDecoration(color: category.color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.r(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.r(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.r(context)),
                Text(
                  '${transaction.date} | ${source?.name ?? transaction.source}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.r(context),
                  ),
                ),
                if ((transaction.note ?? transaction.description).isNotEmpty) ...[
                  SizedBox(height: 4.r(context)),
                  Text(
                    transaction.note ?? transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.r(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.r(context)),
          Text(
            '$amountPrefix${appState.formatCurrency(transaction.amount)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 14.r(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
