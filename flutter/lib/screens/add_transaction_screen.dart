import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
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

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.72),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            decoration: const BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppColors.darkBorder)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close,
                              color: AppColors.textPrimary, size: 30)),
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TypeChip(
                            label: 'Income',
                            value: 'income',
                            groupValue: _type,
                            color: AppColors.green,
                            onChanged: _setType),
                      ),
                      const SizedBox(width: 10),
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
                    const SizedBox(height: 12),
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
                        const SizedBox(width: 12),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 18),
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
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 18),
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
                  const SizedBox(height: 18),
                  const Text('Date',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_date),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month_outlined,
                            color: AppColors.green),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FinanceTextField(
                    controller: _noteController,
                    label: 'Note',
                    hint: 'Add note (optional)',
                  ),
                  const SizedBox(height: 22),
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
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(value),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? color : AppColors.darkBorder),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
