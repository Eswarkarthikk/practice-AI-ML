import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_scaffold.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController();
  final _couponValueController = TextEditingController();
  final _couponCountController = TextEditingController();
  final _budgetController = TextEditingController();
  final List<CartItem> _items = [];
  String? _selectedSourceId;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _couponValueController.dispose();
    _couponCountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  double get _budget => double.tryParse(_budgetController.text) ?? 0;
  double get _cartTotal => _items.fold(0.0, (sum, item) => sum + item.total);

  String get _budgetStatus {
    if (_budget <= 0) return 'untracked';
    final ratio = _cartTotal / _budget;
    if (ratio > 1) return 'over';
    if (ratio >= 0.8) return 'warning';
    return 'safe';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    _selectedSourceId ??=
        appState.sources.isNotEmpty ? appState.sources.first.id : null;
    final history = appState.transactions
        .where((item) => item.cartSnapshot != null)
        .toList();
    final statusColor = switch (_budgetStatus) {
      'safe' => AppColors.green,
      'warning' => AppColors.orange,
      'over' => AppColors.red,
      _ => AppColors.textSecondary,
    };

    if (appState.sources.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Add a source before using the cart.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          children: [
            Row(
              children: [
                const Expanded(
                  child: SplitTitle(
                    first: 'Smart ',
                    second: 'Cart',
                    color: Color(0xFFFF5B7F),
                    size: 31,
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkCard,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add items, compare with budget, then save it as one expense.',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  height: 1.35),
            ),
            const SizedBox(height: 22),
            FinanceCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budget Indicator',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900)),
                      Icon(Icons.pie_chart_outline, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                          child: _Metric(
                              label: 'Budget',
                              value: _budget > 0
                                  ? appState.formatCurrency(_budget)
                                  : 'Not set')),
                      Expanded(
                          child: _Metric(
                              label: 'Current',
                              value: appState.formatCurrency(_cartTotal))),
                      Expanded(
                          child: _Metric(
                              label: 'Remaining',
                              value: _budgetDifference(appState))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FinanceTextField(
                    controller: _budgetController,
                    label: 'Set cart budget',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FinanceSelectField<String>(
                    label: 'Pay from',
                    value: _selectedSourceId,
                    items: appState.sources
                        .map((source) => DropdownMenuItem(
                            value: source.id, child: Text(source.name)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSourceId = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FinanceCard(
                    padding: const EdgeInsets.all(16),
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const Text('Checkout date',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontFamily: 'monospace')),
                              const SizedBox(height: 10),
                              Text(DateFormat('yyyy-MM-dd').format(_date),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900)),
                            ])),
                        const Icon(Icons.calendar_month_outlined,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Cart Items',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            FinanceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add item',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  FinanceTextField(controller: _nameController, label: 'Name'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: FinanceTextField(
                            controller: _priceController,
                            label: 'Price',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: FinanceTextField(
                            controller: _quantityController,
                            label: 'Qty',
                            keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: FinanceTextField(
                            controller: _discountController,
                            label: 'Discount %',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: FinanceTextField(
                            controller: _couponValueController,
                            label: 'Coupon value',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: FinanceTextField(
                            controller: _couponCountController,
                            label: 'Coupon count',
                            keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 20),
                  GradientActionButton(label: 'Add Item', onPressed: _addItem),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (_items.isEmpty)
              const EmptyFinanceState(
                icon: Icons.shopping_cart_outlined,
                title: 'No items yet',
                message:
                    'Start with an item, then adjust quantity, discounts, and coupons live.',
              )
            else
              ..._items.map((item) => _CartItemCard(
                    item: item,
                    total: appState.formatCurrency(item.total),
                    onRemove: () => setState(() =>
                        _items.removeWhere((entry) => entry.id == item.id)),
                  )),
            const SizedBox(height: 14),
            FinanceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _CheckoutRow(
                      label: 'Live Total',
                      value: appState.formatCurrency(_cartTotal)),
                  const SizedBox(height: 12),
                  _CheckoutRow(
                      label: 'Status',
                      value: _statusLabel(_budgetStatus),
                      color: statusColor),
                  const SizedBox(height: 18),
                  GradientActionButton(
                    onPressed:
                        _items.isEmpty ? null : () => _checkout(appState),
                    label: 'Checkout and Save as Expense',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Cart History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const EmptyFinanceState(
                icon: Icons.history,
                title: 'No cart history yet',
                message:
                    'Your checked out carts will appear here with expandable details.',
              )
            else
              ...history.map((transaction) => FinanceCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: const Text('Shopping Cart',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                          '${transaction.date} | ${transaction.cartSnapshot!.itemCount} items'),
                      trailing: Text(
                          appState.formatCurrency(transaction.amount),
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  )),
          ],
        ),
      ),
    );
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

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid item name and price')));
      return;
    }
    setState(() {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        price: price,
        quantity: quantity < 1 ? 1 : quantity,
        discountPercent: (double.tryParse(_discountController.text) ?? 0)
            .clamp(0, 100)
            .toDouble(),
        couponValue: double.tryParse(_couponValueController.text) ?? 0,
        couponCount: int.tryParse(_couponCountController.text) ?? 0,
      ));
      _nameController.clear();
      _priceController.clear();
      _quantityController.text = '1';
      _discountController.clear();
      _couponValueController.clear();
      _couponCountController.clear();
    });
  }

  Future<void> _checkout(AppStateModel appState) async {
    final budget = _budget;
    await appState.addTransaction(
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: _cartTotal,
        category: 'shopping',
        source: _selectedSourceId!,
        date: DateFormat('yyyy-MM-dd').format(_date),
        description: 'Cart checkout (${_items.length} items)',
        type: 'expense',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: 'Cart: ${_items.take(3).map((item) => item.name).join(', ')}',
        cartSnapshot: CartSnapshot(
          budget: budget,
          total: _cartTotal,
          ratio: budget <= 0 ? 0 : _cartTotal / budget,
          status: _budgetStatus,
          itemCount: _items.length,
          totalQuantity: _items.fold(0, (sum, item) => sum + item.quantity),
          items: List.from(_items),
          checkedOutAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    setState(() => _items.clear());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart saved as transaction')));
  }

  String _budgetDifference(AppStateModel appState) {
    if (_budget <= 0) return 'Set budget';
    return appState.formatCurrency((_budget - _cartTotal).abs());
  }

  String _statusLabel(String status) {
    if (status == 'safe') return 'Safe';
    if (status == 'warning') return 'Near limit';
    if (status == 'over') return 'Over budget';
    return 'Budget not set';
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary, fontFamily: 'monospace')),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final String total;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.total,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              Text('Qty ${item.quantity}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
          Text(total,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _CheckoutRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontFamily: 'monospace')),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 18, color: color)),
    ]);
  }
}
