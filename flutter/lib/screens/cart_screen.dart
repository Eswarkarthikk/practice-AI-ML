import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
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
        child: Responsive.constrained(
          context,
          ListView(
            padding: EdgeInsets.fromLTRB(20.r(context), 24.r(context), 20.r(context), 110.r(context)),
            children: [
              Row(
                children: [
                  Expanded(
                    child: SplitTitle(
                      first: 'Smart ',
                      second: 'Cart',
                      color: const Color(0xFFFF5B7F),
                      size: 31.r(context),
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.darkCard,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.close, size: 24.r(context)),
                  )
                ],
              ),
              SizedBox(height: 8.r(context)),
              Text(
                'Add items, compare with budget, then save it as one expense.',
                style: GoogleFonts.spaceMono(
                    color: AppColors.textSecondary,
                    fontSize: 12.r(context),
                    height: 1.35),
              ),
              SizedBox(height: 22.r(context)),
              FinanceCard(
                padding: EdgeInsets.all(22.r(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget Indicator',
                            style: TextStyle(
                                fontSize: 22.r(context), fontWeight: FontWeight.w900)),
                        Icon(Icons.pie_chart_outline, color: statusColor, size: 24.r(context)),
                      ],
                    ),
                    SizedBox(height: 22.r(context)),
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
                    SizedBox(height: 18.r(context)),
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
              SizedBox(height: 18.r(context)),
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
                  SizedBox(width: 12.r(context)),
                  Expanded(
                    child: FinanceCard(
                      padding: EdgeInsets.all(16.r(context)),
                      onTap: _pickDate,
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Checkout date',
                                    style: GoogleFonts.spaceMono(
                                        color: AppColors.textSecondary,
                                        fontSize: 11.r(context))),
                                SizedBox(height: 10.r(context)),
                                Text(DateFormat('yyyy-MM-dd').format(_date),
                                    style: TextStyle(
                                        fontSize: 17.r(context),
                                        fontWeight: FontWeight.w900)),
                              ])),
                          Icon(Icons.calendar_month_outlined,
                              color: AppColors.textSecondary,
                              size: 24.r(context)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 24.r(context)),
              Text('Cart Items',
                  style: TextStyle(fontSize: 24.r(context), fontWeight: FontWeight.w900)),
              SizedBox(height: 12.r(context)),
              FinanceCard(
                padding: EdgeInsets.all(18.r(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add item',
                        style:
                            TextStyle(fontSize: 18.r(context), fontWeight: FontWeight.w900)),
                    SizedBox(height: 16.r(context)),
                    FinanceTextField(controller: _nameController, label: 'Name'),
                    SizedBox(height: 12.r(context)),
                    Row(children: [
                      Expanded(
                          child: FinanceTextField(
                              controller: _priceController,
                              label: 'Price',
                              keyboardType: TextInputType.number)),
                      SizedBox(width: 10.r(context)),
                      Expanded(
                          child: FinanceTextField(
                              controller: _quantityController,
                              label: 'Qty',
                              keyboardType: TextInputType.number)),
                    ]),
                    SizedBox(height: 12.r(context)),
                    Row(children: [
                      Expanded(
                          child: FinanceTextField(
                              controller: _discountController,
                              label: 'Discount %',
                              keyboardType: TextInputType.number)),
                      SizedBox(width: 10.r(context)),
                      Expanded(
                          child: FinanceTextField(
                              controller: _couponValueController,
                              label: 'Coupon value',
                              keyboardType: TextInputType.number)),
                      SizedBox(width: 10.r(context)),
                      Expanded(
                          child: FinanceTextField(
                              controller: _couponCountController,
                              label: 'Coupon count',
                              keyboardType: TextInputType.number)),
                    ]),
                    SizedBox(height: 20.r(context)),
                    GradientActionButton(label: 'Add Item', onPressed: _addItem),
                  ],
                ),
              ),
              SizedBox(height: 28.r(context)),
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
              SizedBox(height: 14.r(context)),
              FinanceCard(
                padding: EdgeInsets.all(18.r(context)),
                child: Column(
                  children: [
                    _CheckoutRow(
                        label: 'Live Total',
                        value: appState.formatCurrency(_cartTotal)),
                    SizedBox(height: 12.r(context)),
                    _CheckoutRow(
                        label: 'Status',
                        value: _statusLabel(_budgetStatus),
                        color: statusColor),
                    SizedBox(height: 18.r(context)),
                    GradientActionButton(
                      onPressed:
                          _items.isEmpty ? null : () => _checkout(appState),
                      label: 'Checkout and Save as Expense',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.r(context)),
              Text('Cart History',
                  style: TextStyle(fontSize: 24.r(context), fontWeight: FontWeight.w900)),
              SizedBox(height: 12.r(context)),
              if (history.isEmpty)
                const EmptyFinanceState(
                  icon: Icons.history,
                  title: 'No cart history yet',
                  message:
                      'Your checked out carts will appear here with expandable details.',
                )
              else
                ...history.map((transaction) => FinanceCard(
                      margin: EdgeInsets.only(bottom: 12.r(context)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
                        title: Text('Shopping Cart',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.r(context))),
                        subtitle: Text(
                            '${transaction.date} | ${transaction.cartSnapshot!.itemCount} items',
                            style: TextStyle(fontSize: 13.r(context))),
                        trailing: Text(
                            appState.formatCurrency(transaction.amount),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.r(context))),
                      ),
                    )),
            ],
          ),
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
          style: GoogleFonts.spaceMono(
              color: AppColors.textPrimary,
              fontSize: 12.r(context))),
      SizedBox(height: 8.r(context)),
      Text(value,
          style: TextStyle(fontSize: 18.r(context), fontWeight: FontWeight.w800)),
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
      margin: EdgeInsets.only(bottom: 12.r(context)),
      child: Row(
        children: [
          IconButton(onPressed: onRemove, icon: Icon(Icons.close, size: 24.r(context))),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: TextStyle(
                      fontSize: 18.r(context), fontWeight: FontWeight.w900)),
              SizedBox(height: 4.r(context)),
              Text('Qty ${item.quantity}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.r(context))),
            ]),
          ),
          Text(total,
              style:
                  TextStyle(fontSize: 18.r(context), fontWeight: FontWeight.w900)),
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
          style: GoogleFonts.spaceMono(
              color: AppColors.textSecondary,
              fontSize: 13.r(context))),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 18.r(context), color: color)),
    ]);
  }
}
