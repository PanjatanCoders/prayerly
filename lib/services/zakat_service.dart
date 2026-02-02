// services/zakat_service.dart
// Simple Zakat calculation and payment tracking
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatService {
  static const String _assetsKey = 'zakat_assets';
  static const String _paymentsKey = 'zakat_payments';

  // Zakat rate
  static const double zakatRate = 0.025; // 2.5%

  // Nisab constants (correct Islamic values)
  static const double nisabGoldGrams = 87.48;     // 7.5 tola = 87.48 grams
  static const double nisabSilverGrams = 653.184; // 653 grams 184 mg

  /// Save assets
  static Future<void> saveAssets(ZakatAssets assets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_assetsKey, json.encode(assets.toJson()));
  }

  /// Load assets
  static Future<ZakatAssets> loadAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_assetsKey);
      if (data != null) {
        return ZakatAssets.fromJson(json.decode(data));
      }
    } catch (e) {
      // Return default
    }
    return ZakatAssets();
  }

  /// Add payment
  static Future<void> addPayment(ZakatPayment payment) async {
    final payments = await loadPayments();
    payments.insert(0, payment);

    if (payments.length > 100) {
      payments.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _paymentsKey,
      json.encode(payments.map((p) => p.toJson()).toList()),
    );
  }

  /// Load payments
  static Future<List<ZakatPayment>> loadPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_paymentsKey);
      if (data != null) {
        final list = json.decode(data) as List;
        return list.map((e) => ZakatPayment.fromJson(e)).toList();
      }
    } catch (e) {
      // Return empty
    }
    return [];
  }

  /// Clear all payments (for new year)
  static Future<void> clearPayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paymentsKey);
  }
}

/// Named amount entry (for cash, bank, liabilities)
class NamedAmount {
  final String name;
  final double amount;

  NamedAmount({required this.name, required this.amount});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};

  factory NamedAmount.fromJson(Map<String, dynamic> json) => NamedAmount(
    name: json['name'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
  );
}

/// Zakat-eligible assets with gold/silver weight and rates
class ZakatAssets {
  // Cash entries (multiple)
  final List<NamedAmount> cashEntries;

  // Bank entries (multiple)
  final List<NamedAmount> bankEntries;

  // Gold - weight in grams + rate per gram
  final double goldWeightGrams;
  final double goldRatePerGram;

  // Silver - weight in grams + rate per gram
  final double silverWeightGrams;
  final double silverRatePerGram;

  // Other assets
  final double investments;
  final double businessStock;
  final double receivables;
  final double otherAssets;

  // Liabilities/Debts (multiple)
  final List<NamedAmount> debtEntries;

  ZakatAssets({
    List<NamedAmount>? cashEntries,
    List<NamedAmount>? bankEntries,
    this.goldWeightGrams = 0,
    this.goldRatePerGram = 0,
    this.silverWeightGrams = 0,
    this.silverRatePerGram = 0,
    this.investments = 0,
    this.businessStock = 0,
    this.receivables = 0,
    this.otherAssets = 0,
    List<NamedAmount>? debtEntries,
  }) : cashEntries = cashEntries ?? [],
       bankEntries = bankEntries ?? [],
       debtEntries = debtEntries ?? [];

  // Computed totals from entries
  double get cash => cashEntries.fold(0.0, (sum, e) => sum + e.amount);
  double get bankBalance => bankEntries.fold(0.0, (sum, e) => sum + e.amount);
  double get debts => debtEntries.fold(0.0, (sum, e) => sum + e.amount);

  // Calculated gold value
  double get goldValue => goldWeightGrams * goldRatePerGram;

  // Calculated silver value
  double get silverValue => silverWeightGrams * silverRatePerGram;

  // Nisab based on gold rate (7.5 tola = 87.48g × gold rate)
  double get nisabByGold => ZakatService.nisabGoldGrams * goldRatePerGram;

  // Nisab based on silver rate (653.184g × silver rate)
  double get nisabBySilver => ZakatService.nisabSilverGrams * silverRatePerGram;

  // Check what type of assets the person has
  bool get _hasOnlyGold =>
      goldWeightGrams > 0 &&
      silverWeightGrams <= 0 &&
      cash <= 0 &&
      bankBalance <= 0 &&
      investments <= 0 &&
      businessStock <= 0 &&
      receivables <= 0 &&
      otherAssets <= 0;

  bool get _hasOnlySilver =>
      silverWeightGrams > 0 &&
      goldWeightGrams <= 0 &&
      cash <= 0 &&
      bankBalance <= 0 &&
      investments <= 0 &&
      businessStock <= 0 &&
      receivables <= 0 &&
      otherAssets <= 0;

  // Nisab calculation rules:
  // 1. Only gold (no silver, no cash/other) → Gold Nisab (87.48g)
  // 2. Only silver (no gold, no cash/other) → Silver Nisab (653.184g)
  // 3. Any combination (gold+cash, silver+cash, only cash, etc.) → Silver Nisab
  double get nisab {
    // Need at least one rate to calculate
    if (goldRatePerGram <= 0 && silverRatePerGram <= 0) return 0;

    // Only gold assets → use gold nisab
    if (_hasOnlyGold && goldRatePerGram > 0) {
      return nisabByGold;
    }

    // Only silver assets → use silver nisab
    if (_hasOnlySilver && silverRatePerGram > 0) {
      return nisabBySilver;
    }

    // Any combination → use silver nisab (if silver rate available)
    if (silverRatePerGram > 0) {
      return nisabBySilver;
    }

    // Fallback to gold nisab if only gold rate is available
    return nisabByGold;
  }

  // Which nisab is being used (for display)
  String get nisabType {
    if (_hasOnlyGold && goldRatePerGram > 0) return 'Gold';
    if (_hasOnlySilver && silverRatePerGram > 0) return 'Silver';
    return 'Silver'; // Default for combinations
  }

  double get totalWealth =>
    cash + bankBalance + goldValue + silverValue +
    investments + businessStock + receivables + otherAssets - debts;

  bool get isAboveNisab => nisab > 0 && totalWealth >= nisab;

  double get zakatDue => isAboveNisab ? totalWealth * ZakatService.zakatRate : 0;

  Map<String, dynamic> toJson() => {
    'cashEntries': cashEntries.map((e) => e.toJson()).toList(),
    'bankEntries': bankEntries.map((e) => e.toJson()).toList(),
    'goldWeightGrams': goldWeightGrams,
    'goldRatePerGram': goldRatePerGram,
    'silverWeightGrams': silverWeightGrams,
    'silverRatePerGram': silverRatePerGram,
    'investments': investments,
    'businessStock': businessStock,
    'receivables': receivables,
    'otherAssets': otherAssets,
    'debtEntries': debtEntries.map((e) => e.toJson()).toList(),
  };

  factory ZakatAssets.fromJson(Map<String, dynamic> json) {
    // Handle backward compatibility with old format
    List<NamedAmount> parseCashEntries() {
      if (json['cashEntries'] != null) {
        return (json['cashEntries'] as List).map((e) => NamedAmount.fromJson(e)).toList();
      }
      // Migrate old format
      final oldCash = (json['cash'] ?? 0).toDouble();
      if (oldCash > 0) return [NamedAmount(name: 'Cash', amount: oldCash)];
      return [];
    }

    List<NamedAmount> parseBankEntries() {
      if (json['bankEntries'] != null) {
        return (json['bankEntries'] as List).map((e) => NamedAmount.fromJson(e)).toList();
      }
      // Migrate old format
      final oldBank = (json['bankBalance'] ?? 0).toDouble();
      if (oldBank > 0) return [NamedAmount(name: 'Bank Account', amount: oldBank)];
      return [];
    }

    List<NamedAmount> parseDebtEntries() {
      if (json['debtEntries'] != null) {
        return (json['debtEntries'] as List).map((e) => NamedAmount.fromJson(e)).toList();
      }
      // Migrate old format
      final oldDebts = (json['debts'] ?? 0).toDouble();
      if (oldDebts > 0) return [NamedAmount(name: 'Debt', amount: oldDebts)];
      return [];
    }

    return ZakatAssets(
      cashEntries: parseCashEntries(),
      bankEntries: parseBankEntries(),
      goldWeightGrams: (json['goldWeightGrams'] ?? json['goldValue'] ?? 0).toDouble(),
      goldRatePerGram: (json['goldRatePerGram'] ?? 0).toDouble(),
      silverWeightGrams: (json['silverWeightGrams'] ?? json['silverValue'] ?? 0).toDouble(),
      silverRatePerGram: (json['silverRatePerGram'] ?? 0).toDouble(),
      investments: (json['investments'] ?? 0).toDouble(),
      businessStock: (json['businessStock'] ?? 0).toDouble(),
      receivables: (json['receivables'] ?? 0).toDouble(),
      otherAssets: (json['otherAssets'] ?? 0).toDouble(),
      debtEntries: parseDebtEntries(),
    );
  }
}

/// Zakat payment record
class ZakatPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;
  final String? recipient;

  ZakatPayment({
    String? id,
    required this.amount,
    DateTime? date,
    this.note,
    this.recipient,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
    'recipient': recipient,
  };

  factory ZakatPayment.fromJson(Map<String, dynamic> json) => ZakatPayment(
    id: json['id'],
    amount: (json['amount'] ?? 0).toDouble(),
    date: DateTime.parse(json['date']),
    note: json['note'],
    recipient: json['recipient'],
  );
}
