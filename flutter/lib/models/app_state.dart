import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'budget.dart';
import 'category.dart';
import 'source.dart';
import 'transaction.dart';

class AppProfile {
  final String name;
  final int createdAt;
  final int lastUpdated;

  AppProfile({
    required this.name,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'createdAt': createdAt,
        'lastUpdated': lastUpdated,
      };

  factory AppProfile.fromJson(Map<String, dynamic> json) => AppProfile(
        name: json['name'] as String? ?? 'User',
        createdAt:
            json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        lastUpdated: json['lastUpdated'] as int? ??
            DateTime.now().millisecondsSinceEpoch,
      );
}

class SourceBalance {
  final SourceModel source;
  final double balance;

  SourceBalance({required this.source, required this.balance});
}

class SourceBudget {
  final double monthBudgetCap;
  final Map<String, double> limitsByCategory;

  SourceBudget({
    required this.monthBudgetCap,
    required this.limitsByCategory,
  });

  Map<String, dynamic> toJson() => {
        'monthBudgetCap': monthBudgetCap,
        'limitsByCategory': limitsByCategory,
      };

  factory SourceBudget.fromJson(Map<String, dynamic> json) {
    final limits = <String, double>{};
    final rawLimits = json['limitsByCategory'] as Map<String, dynamic>? ?? {};
    rawLimits.forEach((key, val) {
      limits[key] = (val as num).toDouble();
    });
    return SourceBudget(
      monthBudgetCap: (json['monthBudgetCap'] as num? ?? 0.0).toDouble(),
      limitsByCategory: limits,
    );
  }
}

class AppStateModel extends ChangeNotifier {
  static const _profileKey = '@ehk_profile';
  static const _transactionsKey = '@ehk_transactions';
  static const _sourcesKey = '@ehk_sources';
  static const _categoriesKey = '@ehk_categories';
  static const _budgetsKey = '@ehk_budgets';
  static const _themeKey = '@ehk_theme';
  static const _initializedKey = '@ehk_initialized';
  static const _aiApiKeyKey = '@ehk_ai_api_key';
  static const _appLockEnabledKey = '@ehk_app_lock_enabled';
  static const _appLockPinKey = '@ehk_app_lock_pin';
  static const _budgetTrackerKey = '@ehk_budget_tracker';

  final List<TransactionModel> _transactions = [];
  final List<SourceModel> _sources = [];
  final List<BudgetModel> _budgets = [];
  List<CategoryModel> _categories = _defaultCategories();
  AppProfile? _profile;
  bool _initialized = false;
  bool _isLoaded = false;
  ThemeMode _themeMode = ThemeMode.dark;
  String? _aiApiKey;
  bool _appLockEnabled = false;
  String? _appLockPin;
  Map<String, SourceBudget> _budgetTracker = {
    'all': SourceBudget(monthBudgetCap: 0.0, limitsByCategory: {})
  };

  List<TransactionModel> get transactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sorted);
  }

  List<SourceModel> get sources => List.unmodifiable(_sources);
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  AppProfile? get profile => _profile;
  bool get initialized => _initialized;
  bool get isLoaded => _isLoaded;
  ThemeMode get themeMode => _themeMode;
  String? get aiApiKey => _aiApiKey;
  bool get appLockEnabled => _appLockEnabled;
  String? get appLockPin => _appLockPin;
  Map<String, SourceBudget> get budgetTracker => _budgetTracker;

  bool get requiresInitialLockSetup =>
      _profile != null && _sources.isNotEmpty && (!_appLockEnabled || _appLockPin == null || _appLockPin!.length < 4);

  bool get shouldProtectApp =>
      _profile != null && _sources.isNotEmpty && _appLockEnabled && _appLockPin != null && _appLockPin!.length >= 4;

  SourceBudget getBudget(String sourceKey) {
    return _budgetTracker[sourceKey] ??
        SourceBudget(monthBudgetCap: 0.0, limitsByCategory: {});
  }

  double getLimit(String sourceKey, String categoryId, double fallback) {
    final budget = getBudget(sourceKey);
    return budget.limitsByCategory[categoryId] ?? fallback;
  }

  Future<void> setCategoryLimit(
      String sourceKey, String categoryId, double limit) async {
    final current = getBudget(sourceKey);
    current.limitsByCategory[categoryId] = limit;
    _budgetTracker[sourceKey] = current;
    await _save();
    notifyListeners();
  }

  Future<void> setAllBudgetLimits(
      String sourceKey, double cap, Map<String, double> nextLimits) async {
    _budgetTracker[sourceKey] =
        SourceBudget(monthBudgetCap: cap, limitsByCategory: nextLimits);
    await _save();
    notifyListeners();
  }

  Future<void> setAppLockPin(String? pin) async {
    _appLockPin = pin;
    await _save();
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    _appLockEnabled = enabled;
    await _save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _profile = _decodeObject(prefs.getString(_profileKey), AppProfile.fromJson);
    _themeMode = prefs.getString(_themeKey) == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
    _initialized = prefs.getBool(_initializedKey) ?? false;
    _aiApiKey = prefs.getString(_aiApiKeyKey);
    _appLockEnabled = prefs.getBool(_appLockEnabledKey) ?? false;
    _appLockPin = prefs.getString(_appLockPinKey);

    final budgetTrackerRaw = prefs.getString(_budgetTrackerKey);
    if (budgetTrackerRaw != null) {
      try {
        final decoded = jsonDecode(budgetTrackerRaw) as Map<String, dynamic>;
        final bySource = decoded['bySource'] as Map<String, dynamic>? ?? {};
        _budgetTracker.clear();
        bySource.forEach((key, value) {
          _budgetTracker[key] =
              SourceBudget.fromJson(value as Map<String, dynamic>);
        });
      } catch (_) {
        _budgetTracker = {
          'all': SourceBudget(monthBudgetCap: 0.0, limitsByCategory: {})
        };
      }
    } else {
      _budgetTracker = {
        'all': SourceBudget(monthBudgetCap: 0.0, limitsByCategory: {})
      };
    }

    _transactions
      ..clear()
      ..addAll(_decodeList(
          prefs.getString(_transactionsKey), TransactionModel.fromJson));
    _sources
      ..clear()
      ..addAll(_decodeList(prefs.getString(_sourcesKey), SourceModel.fromJson));
    _budgets
      ..clear()
      ..addAll(_decodeList(prefs.getString(_budgetsKey), BudgetModel.fromJson));

    final savedCategories =
        _decodeList(prefs.getString(_categoriesKey), CategoryModel.fromJson);
    _categories =
        savedCategories.isEmpty ? _defaultCategories() : savedCategories;
    if (savedCategories.isEmpty) {
      await prefs.setString(_categoriesKey,
          jsonEncode(_categories.map((item) => item.toJson()).toList()));
    }

    await _migrateLegacyKeys(prefs);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _migrateLegacyKeys(SharedPreferences prefs) async {
    if (_transactions.isEmpty && prefs.getString('transactions') != null) {
      _transactions.addAll(_decodeList(
          prefs.getString('transactions'), TransactionModel.fromJson));
    }
    if (_budgets.isEmpty && prefs.getString('budgets') != null) {
      _budgets.addAll(
          _decodeList(prefs.getString('budgets'), BudgetModel.fromJson));
    }
    if (_sources.isEmpty && prefs.getString('sources') != null) {
      _sources.addAll(
          _decodeList(prefs.getString('sources'), SourceModel.fromJson));
    }
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transactionsKey,
        jsonEncode(_transactions.map((item) => item.toJson()).toList()));
    await prefs.setString(_sourcesKey,
        jsonEncode(_sources.map((item) => item.toJson()).toList()));
    await prefs.setString(_budgetsKey,
        jsonEncode(_budgets.map((item) => item.toJson()).toList()));
    await prefs.setString(_categoriesKey,
        jsonEncode(_categories.map((item) => item.toJson()).toList()));
    if (_profile != null) {
      await prefs.setString(_profileKey, jsonEncode(_profile!.toJson()));
    }
    await prefs.setString(
        _themeKey, _themeMode == ThemeMode.light ? 'light' : 'dark');
    await prefs.setBool(_initializedKey, _initialized);
    if (_aiApiKey != null) {
      await prefs.setString(_aiApiKeyKey, _aiApiKey!);
    } else {
      await prefs.remove(_aiApiKeyKey);
    }
    await prefs.setBool(_appLockEnabledKey, _appLockEnabled);
    if (_appLockPin != null) {
      await prefs.setString(_appLockPinKey, _appLockPin!);
    } else {
      await prefs.remove(_appLockPinKey);
    }
    final budgetTrackerPayload = {
      'bySource': _budgetTracker
          .map((key, value) => MapEntry(key, value.toJson()))
    };
    await prefs.setString(_budgetTrackerKey, jsonEncode(budgetTrackerPayload));
  }

  Future<void> setProfile(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _profile = AppProfile(
        name: name, createdAt: _profile?.createdAt ?? now, lastUpdated: now);
    _initialized = true;
    await _save();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _save();
    notifyListeners();
  }

  Future<void> setAiApiKey(String? key) async {
    _aiApiKey = key;
    await _save();
    notifyListeners();
  }

  Future<String> addSource(
      String name, String type, double startingAmount) async {
    final source = SourceModel(
      id: _generateId(),
      name: name,
      type: type,
      startingAmount: startingAmount,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _sources.add(source);
    _initialized = true;
    await _save();
    notifyListeners();
    return source.id;
  }

  Future<void> updateSource(String id, SourceModel source) async {
    final index = _sources.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _sources[index] = source;
    await _save();
    notifyListeners();
  }

  Future<void> removeSource(String id) async {
    _sources.removeWhere((item) => item.id == id);
    _transactions.removeWhere((item) => item.source == id);
    await _save();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _save();
    notifyListeners();
  }

  Future<void> updateTransaction(
      String id, TransactionModel transaction) async {
    final index = _transactions.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _transactions[index] = transaction;
    await _save();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    _budgets.removeWhere((item) =>
        item.categoryId == budget.categoryId && item.period == budget.period);
    _budgets.add(budget);
    await _save();
    notifyListeners();
  }

  Future<void> removeBudget(String id) async {
    _budgets.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_sourcesKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_initializedKey);
    await prefs.remove(_appLockEnabledKey);
    await prefs.remove(_appLockPinKey);
    await prefs.remove(_budgetTrackerKey);
    _profile = null;
    _transactions.clear();
    _sources.clear();
    _budgets.clear();
    _initialized = false;
    _appLockEnabled = false;
    _appLockPin = null;
    _budgetTracker = {
      'all': SourceBudget(monthBudgetCap: 0.0, limitsByCategory: {})
    };
    await _save();
    notifyListeners();
  }

  double totalIncome({bool thisMonth = false}) {
    return _transactions
        .where(
            (item) => item.isCredit && (!thisMonth || isThisMonth(item.date)))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double totalExpense({bool thisMonth = false}) {
    return _transactions
        .where((item) => item.isDebit && (!thisMonth || isThisMonth(item.date)))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double currentBalance() {
    return sourceBalances().fold(0.0, (sum, item) => sum + item.balance);
  }

  List<SourceBalance> sourceBalances() {
    return _sources.map((source) {
      final total = _transactions
          .where((item) => item.source == source.id)
          .fold(source.startingAmount, (sum, item) {
        if (item.isCredit) return sum + item.amount;
        if (item.isDebit) return sum - item.amount;
        return sum;
      });
      return SourceBalance(source: source, balance: total);
    }).toList();
  }

  Map<String, double> expenseByCategory({bool thisMonth = false}) {
    final breakdown = <String, double>{};
    for (final transaction in _transactions.where(
        (item) => item.isDebit && (!thisMonth || isThisMonth(item.date)))) {
      breakdown[transaction.category] =
          (breakdown[transaction.category] ?? 0) + transaction.amount;
    }
    return breakdown;
  }

  double spentForBudget(BudgetModel budget) {
    return _transactions
        .where((item) =>
            item.isDebit &&
            item.category == budget.categoryId &&
            _matchesBudgetPeriod(item.date, budget.period))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  CategoryModel categoryById(String id) {
    return _categories.firstWhere(
      (item) => item.id == id,
      orElse: () => CategoryModel(
          id: id, name: id, icon: '', color: const Color(0xFF94A3B8)),
    );
  }

  SourceModel? sourceById(String id) {
    for (final source in _sources) {
      if (source.id == id) return source;
    }
    return null;
  }

  TransactionModel? transactionById(String id) {
    for (final transaction in _transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  String formatCurrency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0)
          .format(amount);

  bool isThisMonth(String date) {
    final parsed = DateTime.tryParse(date);
    final now = DateTime.now();
    return parsed != null &&
        parsed.year == now.year &&
        parsed.month == now.month;
  }

  bool _matchesBudgetPeriod(String date, String period) {
    final parsed = DateTime.tryParse(date);
    final now = DateTime.now();
    if (parsed == null) return false;
    if (period == 'weekly') {
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 7));
      return !parsed.isBefore(start) && parsed.isBefore(end);
    }
    return parsed.year == now.year && parsed.month == now.month;
  }

  static T? _decodeObject<T>(
      String? raw, T Function(Map<String, dynamic>) factory) {
    if (raw == null) return null;
    try {
      return factory(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static List<T> _decodeList<T>(
      String? raw, T Function(Map<String, dynamic>) factory) {
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => factory(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${UniqueKey()}';
  }

  static List<CategoryModel> _defaultCategories() {
    return const [
      CategoryModel(
          id: 'salary',
          name: 'Salary',
          icon: 'Salary',
          color: Color(0xFF22C55E)),
      CategoryModel(
          id: 'food', name: 'Food', icon: 'Food', color: Color(0xFF7B61FF)),
      CategoryModel(
          id: 'transport',
          name: 'Transport',
          icon: 'Ride',
          color: Color(0xFF27D7A1)),
      CategoryModel(
          id: 'entertainment',
          name: 'Entertainment',
          icon: 'Fun',
          color: Color(0xFF3CC7FF)),
      CategoryModel(
          id: 'shopping',
          name: 'Shopping',
          icon: 'Shop',
          color: Color(0xFFFF5B7F)),
      CategoryModel(
          id: 'bills', name: 'Bills', icon: 'Bills', color: Color(0xFFFFD44D)),
      CategoryModel(
          id: 'health', name: 'Health', icon: 'Care', color: Color(0xFF2FE49B)),
      CategoryModel(
          id: 'other', name: 'Other', icon: 'Other', color: Color(0xFF9AA4C8)),
    ];
  }
}
