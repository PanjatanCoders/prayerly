// services/zakat_service.dart
// Simple Zakat calculation and payment tracking
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatService {
  static const String _assetsKey = 'zakat_assets';
  static const String _paymentsKey = 'zakat_payments';

  // Zakat rate
  static const double zakatRate = 0.025; // 2.5%

  // Nisab constants
  static const double nisabGoldGrams = 85.0;    // 85 grams of gold
  static const double nisabSilverGrams = 595.0; // 595 grams of silver

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

/// Zakat-eligible assets with gold/silver weight and rates
class ZakatAssets {
  // Cash & Bank
  final double cash;
  final double bankBalance;

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
  final double debts;

  ZakatAssets({
    this.cash = 0,
    this.bankBalance = 0,
    this.goldWeightGrams = 0,
    this.goldRatePerGram = 0,
    this.silverWeightGrams = 0,
    this.silverRatePerGram = 0,
    this.investments = 0,
    this.businessStock = 0,
    this.receivables = 0,
    this.otherAssets = 0,
    this.debts = 0,
  });

  // Calculated gold value
  double get goldValue => goldWeightGrams * goldRatePerGram;

  // Calculated silver value
  double get silverValue => silverWeightGrams * silverRatePerGram;

  // Nisab based on gold rate (85g × gold rate)
  double get nisabByGold => ZakatService.nisabGoldGrams * goldRatePerGram;

  // Nisab based on silver rate (595g × silver rate)
  double get nisabBySilver => ZakatService.nisabSilverGrams * silverRatePerGram;

  // Use the lower of the two Nisab values (more conservative/safer)
  // If one rate is 0, use the other
  double get nisab {
    if (goldRatePerGram <= 0 && silverRatePerGram <= 0) return 0;
    if (goldRatePerGram <= 0) return nisabBySilver;
    if (silverRatePerGram <= 0) return nisabByGold;
    return nisabByGold < nisabBySilver ? nisabByGold : nisabBySilver;
  }

  double get totalWealth =>
    cash + bankBalance + goldValue + silverValue +
    investments + businessStock + receivables + otherAssets - debts;

  bool get isAboveNisab => nisab > 0 && totalWealth >= nisab;

  double get zakatDue => isAboveNisab ? totalWealth * ZakatService.zakatRate : 0;

  Map<String, dynamic> toJson() => {
    'cash': cash,
    'bankBalance': bankBalance,
    'goldWeightGrams': goldWeightGrams,
    'goldRatePerGram': goldRatePerGram,
    'silverWeightGrams': silverWeightGrams,
    'silverRatePerGram': silverRatePerGram,
    'investments': investments,
    'businessStock': businessStock,
    'receivables': receivables,
    'otherAssets': otherAssets,
    'debts': debts,
  };

  factory ZakatAssets.fromJson(Map<String, dynamic> json) => ZakatAssets(
    cash: (json['cash'] ?? 0).toDouble(),
    bankBalance: (json['bankBalance'] ?? 0).toDouble(),
    goldWeightGrams: (json['goldWeightGrams'] ?? json['goldValue'] ?? 0).toDouble(),
    goldRatePerGram: (json['goldRatePerGram'] ?? 0).toDouble(),
    silverWeightGrams: (json['silverWeightGrams'] ?? json['silverValue'] ?? 0).toDouble(),
    silverRatePerGram: (json['silverRatePerGram'] ?? 0).toDouble(),
    investments: (json['investments'] ?? 0).toDouble(),
    businessStock: (json['businessStock'] ?? 0).toDouble(),
    receivables: (json['receivables'] ?? 0).toDouble(),
    otherAssets: (json['otherAssets'] ?? 0).toDouble(),
    debts: (json['debts'] ?? 0).toDouble(),
  );
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
