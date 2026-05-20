class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final double discountPercent;
  final double couponValue;
  final int couponCount;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.discountPercent,
    required this.couponValue,
    required this.couponCount,
  });

  double get discountedUnitPrice => price * (1 - discountPercent / 100);

  double get couponTotal =>
      couponValue * couponCount.clamp(0, quantity).toDouble();

  double get total {
    final value = discountedUnitPrice * quantity - couponTotal;
    return value < 0 ? 0 : value;
  }

  CartItem copyWith({
    String? name,
    double? price,
    int? quantity,
    double? discountPercent,
    double? couponValue,
    int? couponCount,
  }) {
    final nextQuantity = quantity ?? this.quantity;
    return CartItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: nextQuantity,
      discountPercent: discountPercent ?? this.discountPercent,
      couponValue: couponValue ?? this.couponValue,
      couponCount:
          (couponCount ?? this.couponCount).clamp(0, nextQuantity).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'discountPercent': discountPercent,
      'couponValue': couponValue,
      'couponCount': couponCount,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      couponValue: (json['couponValue'] as num).toDouble(),
      couponCount: json['couponCount'] as int,
    );
  }
}

class CartSnapshot {
  final double budget;
  final double total;
  final double ratio;
  final String status;
  final int itemCount;
  final int totalQuantity;
  final List<CartItem> items;
  final int checkedOutAt;

  CartSnapshot({
    required this.budget,
    required this.total,
    required this.ratio,
    required this.status,
    required this.itemCount,
    required this.totalQuantity,
    required this.items,
    required this.checkedOutAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'budget': budget,
      'total': total,
      'ratio': ratio,
      'status': status,
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'items': items.map((item) => item.toJson()).toList(),
      'checkedOutAt': checkedOutAt,
    };
  }

  factory CartSnapshot.fromJson(Map<String, dynamic> json) {
    return CartSnapshot(
      budget: (json['budget'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      ratio: (json['ratio'] as num).toDouble(),
      status: json['status'] as String,
      itemCount: json['itemCount'] as int,
      totalQuantity: json['totalQuantity'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      checkedOutAt: json['checkedOutAt'] as int,
    );
  }
}

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String source;
  final String date;
  final String description;
  final String type;
  final int timestamp;
  final String? note;
  final String? counterparty;
  final CartSnapshot? cartSnapshot;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.source,
    required this.date,
    required this.description,
    required this.type,
    required this.timestamp,
    this.note,
    this.counterparty,
    this.cartSnapshot,
  });

  bool get isCredit => type == 'income' || type == 'borrow';

  bool get isDebit => type == 'expense' || type == 'lend';

  TransactionModel copyWith({
    double? amount,
    String? category,
    String? source,
    String? date,
    String? description,
    String? type,
    int? timestamp,
    String? note,
    String? counterparty,
    CartSnapshot? cartSnapshot,
  }) {
    return TransactionModel(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      source: source ?? this.source,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      counterparty: counterparty ?? this.counterparty,
      cartSnapshot: cartSnapshot ?? this.cartSnapshot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'source': source,
      'date': date,
      'description': description,
      'type': type,
      'timestamp': timestamp,
      'note': note,
      'counterparty': counterparty,
      'cartSnapshot': cartSnapshot?.toJson(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      source: json['source'] as String,
      date: json['date'] as String,
      description:
          json['description'] as String? ?? json['note'] as String? ?? '',
      type: json['type'] as String,
      timestamp:
          json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      note: json['note'] as String?,
      counterparty: json['counterparty'] as String?,
      cartSnapshot: json['cartSnapshot'] != null
          ? CartSnapshot.fromJson(json['cartSnapshot'] as Map<String, dynamic>)
          : null,
    );
  }
}
