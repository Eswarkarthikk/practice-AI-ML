import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _counterpartyController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;
  String? _sourceId;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loadedEditTransaction = false;
  String? _editingId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _counterpartyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final expenseCategories =
        appState.categories.where((item) => item.id != 'salary').toList();
    _loadEditTransactionIfNeeded(appState);
    _categoryId ??= _type == 'income' ? 'salary' : expenseCategories.first.id;
    _sourceId ??=
        appState.sources.isNotEmpty ? appState.sources.first.id : null;

    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: isTablet ? Alignment.center : Alignment.bottomCenter,
              child: Container(
                margin: isTablet ? EdgeInsets.symmetric(horizontal: 24.r(context)) : EdgeInsets.zero,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.88,
                  maxWidth: isTablet ? 500.r(context) : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: isTablet
                      ? BorderRadius.circular(28.r(context))
                      : BorderRadius.vertical(top: Radius.circular(28.r(context))),
                  border: isTablet
                      ? Border.all(color: AppColors.darkBorder)
                      : const Border(top: BorderSide(color: AppColors.darkBorder)),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: isTablet,
                    padding: EdgeInsets.fromLTRB(20.r(context), 10.r(context), 20.r(context), 28.r(context)),
                    children: [
                      Center(
                        child: Container(
                          width: 44.r(context),
                          height: 5.r(context),
                          decoration: BoxDecoration(
                            color: AppColors.darkBorder,
                            borderRadius: BorderRadius.circular(4.r(context)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.r(context)),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close,
                                  color: AppColors.textPrimary, size: 30.r(context))),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: _editingId == null ? 'Add ' : 'Update ',
                                children: const [
                                  TextSpan(
                                      text: 'Transaction',
                                      style: TextStyle(color: AppColors.blue)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 25.r(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(width: 48.r(context)),
                        ],
                      ),
                      SizedBox(height: 12.r(context)),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                                label: 'Expense',
                                value: 'expense',
                                groupValue: _type,
                                color: AppColors.orange,
                                onChanged: _setType),
                          ),
                          SizedBox(width: 10.r(context)),
                          Expanded(
                            child: _TypeChip(
                                label: 'Income',
                                value: 'income',
                                groupValue: _type,
                                color: AppColors.green,
                                onChanged: _setType),
                          ),
                          SizedBox(width: 10.r(context)),
                          Expanded(
                            child: _TypeChip(
                                label: 'Borrow / Lend',
                                value: _type == 'lend' ? 'lend' : 'borrow',
                                groupValue: (_type == 'borrow' || _type == 'lend')
                                    ? (_type == 'lend' ? 'lend' : 'borrow')
                                    : _type,
                                color: AppColors.blue,
                                onChanged: (_) => _setType('borrow')),
                          ),
                        ],
                      ),
                      if (_type == 'borrow' || _type == 'lend') ...[
                        SizedBox(height: 12.r(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeChip(
                                  label: 'Borrow',
                                  value: 'borrow',
                                  groupValue: _type,
                                  color: const Color(0xFFFFD44D),
                                  onChanged: _setType),
                            ),
                            SizedBox(width: 12.r(context)),
                            Expanded(
                              child: _TypeChip(
                                  label: 'Lend',
                                  value: 'lend',
                                  groupValue: _type,
                                  color: AppColors.blue,
                                  onChanged: _setType),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20.r(context)),
                      FinanceTextField(
                        controller: _amountController,
                        label: 'Amount',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 18.r(context)),
                      if (_type == 'income') ...[
                        FinanceSelectField<String>(
                          value: _categoryId,
                          label: 'Income Source*',
                          items: const [
                            DropdownMenuItem(
                                value: 'salary', child: Text('salary')),
                            DropdownMenuItem(value: 'other', child: Text('other')),
                          ],
                          onChanged: (value) => setState(() => _categoryId = value),
                        ),
                        SizedBox(height: 18.r(context)),
                        FinanceSelectField<String>(
                          value: _sourceId,
                          label: 'Deposit To*',
                          items: appState.sources
                              .map((source) => DropdownMenuItem(
                                  value: source.id, child: Text(source.name)))
                              .toList(),
                          onChanged: (value) => setState(() => _sourceId = value),
                          validator: (value) =>
                              value == null ? 'Select a source' : null,
                        ),
                      ] else if (_type == 'expense') ...[
                        FinanceSelectField<String>(
                          value: _categoryId,
                          label: 'Category*',
                          items: expenseCategories
                              .map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(
                                      '${_categoryEmoji(category.id)} ${category.name}')))
                              .toList(),
                          onChanged: (value) => setState(() => _categoryId = value),
                        ),
                        SizedBox(height: 18.r(context)),
                        FinanceSelectField<String>(
                          value: _sourceId,
                          label: 'From*',
                          items: appState.sources
                              .map((source) => DropdownMenuItem(
                                  value: source.id, child: Text(source.name)))
                              .toList(),
                          onChanged: (value) => setState(() => _sourceId = value),
                          validator: (value) =>
                              value == null ? 'Select a source' : null,
                        ),
                      ] else ...[
                        FinanceSelectField<String>(
                          value: _sourceId,
                          label: 'Source*',
                          items: appState.sources
                              .map((source) => DropdownMenuItem(
                                  value: source.id, child: Text(source.name)))
                              .toList(),
                          onChanged: (value) => setState(() => _sourceId = value),
                          validator: (value) =>
                              value == null ? 'Select a source' : null,
                        ),
                        SizedBox(height: 18.r(context)),
                        FinanceTextField(
                          controller: _counterpartyController,
                          label: 'Other Party*',
                          hint: 'Name',
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter the other party';
                            }
                            return null;
                          },
                        ),
                      ],
                      SizedBox(height: 18.r(context)),
                      Text('Date',
                          style: GoogleFonts.spaceMono(
                              color: AppColors.textPrimary,
                              fontSize: 12.r(context))),
                      SizedBox(height: 8.r(context)),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.r(context), vertical: 12.r(context)),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(14.r(context)),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(_date),
                                style: TextStyle(
                                    fontSize: 13.r(context),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                              Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.green,
                                size: 20.r(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18.r(context)),
                      FinanceTextField(
                        controller: _noteController,
                        label: 'Note',
                        hint: 'Add note (optional)',
                      ),
                      SizedBox(height: 22.r(context)),
                      GradientActionButton(
                        onPressed: _saving ? null : () => _save(appState),
                        label: _saving
                            ? 'Saving...'
                            : _editingId == null
                                ? 'Add Transaction'
                                : 'Update Transaction',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setType(String value) {
    setState(() {
      _type = value;
      if (value == 'income') {
        _categoryId = 'salary';
      } else if (value == 'borrow' || value == 'lend') {
        _categoryId = 'other';
      } else {
        _categoryId = null;
      }
    });
  }

  void _loadEditTransactionIfNeeded(AppStateModel appState) {
    if (_loadedEditTransaction) return;
    _loadedEditTransaction = true;
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) return;
    final transaction = appState.transactionById(id);
    if (transaction == null) return;
    _editingId = id;
    _type = transaction.type;
    _amountController.text = transaction.amount.toStringAsFixed(
        transaction.amount.truncateToDouble() == transaction.amount ? 0 : 2);
    _noteController.text = transaction.note ?? '';
    _counterpartyController.text = transaction.counterparty ?? '';
    _categoryId = transaction.category;
    _sourceId = transaction.source;
    _date = DateTime.tryParse(transaction.date) ?? DateTime.now();
  }

  Future<void> _save(AppStateModel appState) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();
    final counterparty = _counterpartyController.text.trim();
    final category = (_type == 'borrow' || _type == 'lend')
        ? 'other'
        : (_categoryId ?? 'other');
    final transaction = TransactionModel(
      id: _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      source: _sourceId!,
      date: DateFormat('yyyy-MM-dd').format(_date),
      description: note.isEmpty
          ? (_type == 'borrow' || _type == 'lend'
              ? '${_type == 'borrow' ? 'Borrow' : 'Lend'} $counterparty'
              : category)
          : note,
      type: _type,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: note.isEmpty ? null : note,
      counterparty: counterparty.isEmpty ? null : counterparty,
    );
    if (_editingId == null) {
      await appState.addTransaction(transaction);
    } else {
      await appState.updateTransaction(_editingId!, transaction);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

String _categoryEmoji(String id) {
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

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Color color;
  final ValueChanged<String> onChanged;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(12.r(context)),
      onTap: () => onChanged(value),
      child: Container(
        height: 44.r(context),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppColors.darkCard,
          borderRadius: BorderRadius.circular(12.r(context)),
          border: Border.all(color: active ? color : AppColors.darkBorder),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              fontSize: 13.r(context),
            ),
          ),
        ),
      ),
    );
  }
}
