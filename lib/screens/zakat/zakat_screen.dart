// screens/zakat/zakat_screen.dart
// Simple Zakat calculator and payment tracker
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/zakat_service.dart';
import '../../utils/theme/app_theme.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  ZakatAssets _assets = ZakatAssets();
  List<ZakatPayment> _payments = [];
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final assets = await ZakatService.loadAssets();
    final payments = await ZakatService.loadPayments();
    if (mounted) {
      setState(() {
        _assets = assets;
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  double get _totalPaid => _payments.fold(0.0, (sum, p) => sum + p.amount);
  double get _remaining => (_assets.zakatDue - _totalPaid).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zakat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildNisabInfo(),
            const SizedBox(height: 20),
            _buildSectionTitle('Market Rates'),
            const SizedBox(height: 8),
            _buildMarketRatesCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Your Assets'),
            const SizedBox(height: 8),
            _buildAssetsCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Payments Made'),
            const SizedBox(height: 8),
            _buildPaymentsSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Payment', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isAboveNisab = _assets.isAboveNisab;
    final progress = _assets.zakatDue > 0 ? (_totalPaid / _assets.zakatDue).clamp(0.0, 1.0) : 0.0;
    final hasRates = _assets.goldRatePerGram > 0 || _assets.silverRatePerGram > 0;

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              !hasRates ? 'Set Market Rates' : (isAboveNisab ? 'Zakat Due' : 'Below Nisab'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(_assets.zakatDue),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isAboveNisab && hasRates) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid: ${_currencyFormat.format(_totalPaid)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Remaining: ${_currencyFormat.format(_remaining)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (!hasRates) ...[
              const SizedBox(height: 8),
              const Text(
                'Enter gold or silver rate to calculate Nisab',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ] else if (!isAboveNisab) ...[
              const SizedBox(height: 8),
              Text(
                'Wealth: ${_currencyFormat.format(_assets.totalWealth)} < Nisab: ${_currencyFormat.format(_assets.nisab)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNisabInfo() {
    final hasRates = _assets.goldRatePerGram > 0 || _assets.silverRatePerGram > 0;
    final usingGoldNisab = _assets.nisabType == 'Gold';

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nisab Threshold',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gold: 7.5 Tola (87.48g) = ${_currencyFormat.format(_assets.nisabByGold)}\n'
                        'Silver: 653.184g = ${_currencyFormat.format(_assets.nisabBySilver)}',
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasRates) ...[
              const Divider(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: usingGoldNisab ? Colors.amber.shade200 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Using ${_assets.nisabType} Nisab: ${_currencyFormat.format(_assets.nisab)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: usingGoldNisab ? Colors.amber.shade900 : Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usingGoldNisab
                    ? 'Only gold assets → Gold Nisab'
                    : 'Silver Nisab applies',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildMarketRatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gold Rate
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.diamond, color: Colors.amber.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gold Rate', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '${_currencyFormat.format(_assets.goldRatePerGram)} / gram',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Silver Rate
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.circle, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Silver Rate', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '${_currencyFormat.format(_assets.silverRatePerGram)} / gram',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEditRatesDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Update Rates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAssetRow('Cash in Hand', _assets.cash, Icons.money),
            _buildAssetRow('Bank Balance', _assets.bankBalance, Icons.account_balance),
            const Divider(),
            _buildAssetRowWithDetails(
              'Gold',
              '${_assets.goldWeightGrams.toStringAsFixed(1)}g × ${_currencyFormat.format(_assets.goldRatePerGram)}',
              _assets.goldValue,
              Icons.diamond,
              Colors.amber,
            ),
            _buildAssetRowWithDetails(
              'Silver',
              '${_assets.silverWeightGrams.toStringAsFixed(1)}g × ${_currencyFormat.format(_assets.silverRatePerGram)}',
              _assets.silverValue,
              Icons.circle,
              Colors.grey,
            ),
            const Divider(),
            _buildAssetRow('Investments', _assets.investments, Icons.trending_up),
            _buildAssetRow('Business Stock', _assets.businessStock, Icons.store),
            _buildAssetRow('Receivables', _assets.receivables, Icons.receipt),
            _buildAssetRow('Other Assets', _assets.otherAssets, Icons.more_horiz),
            const Divider(),
            _buildAssetRow('Debts (deductible)', _assets.debts, Icons.remove_circle, isDebt: true),
            const Divider(thickness: 2),
            _buildAssetRow('Total Wealth', _assets.totalWealth, Icons.calculate, isTotal: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditAssetsDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Assets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(String label, double value, IconData icon, {bool isDebt = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDebt ? Colors.red : (isTotal ? AppTheme.primaryGreen : Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isDebt ? Colors.red : null,
              ),
            ),
          ),
          Text(
            _currencyFormat.format(value),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDebt ? Colors.red : (isTotal ? AppTheme.primaryGreen : null),
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRowWithDetails(String label, String details, double value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(details, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(value),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection() {
    if (_payments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.payment, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No payments recorded',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ..._payments.take(5).map((payment) => ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              child: Icon(Icons.check, color: AppTheme.primaryGreen),
            ),
            title: Text(_currencyFormat.format(payment.amount)),
            subtitle: Text(
              '${DateFormat('MMM dd, yyyy').format(payment.date)}${payment.recipient != null ? ' - ${payment.recipient}' : ''}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deletePayment(payment),
            ),
          )),
          if (_payments.length > 5)
            TextButton(
              onPressed: _showAllPayments,
              child: Text('View all ${_payments.length} payments'),
            ),
        ],
      ),
    );
  }

  void _showEditRatesDialog() {
    final goldRateController = TextEditingController(
      text: _assets.goldRatePerGram > 0 ? _assets.goldRatePerGram.toStringAsFixed(0) : '',
    );
    final silverRateController = TextEditingController(
      text: _assets.silverRatePerGram > 0 ? _assets.silverRatePerGram.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Market Rates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter current market rates per gram in your local currency',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goldRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Gold Rate / gram',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.diamond, color: Colors.amber.shade700),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: silverRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Silver Rate / gram',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.circle, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAssets = ZakatAssets(
                cash: _assets.cash,
                bankBalance: _assets.bankBalance,
                goldWeightGrams: _assets.goldWeightGrams,
                goldRatePerGram: double.tryParse(goldRateController.text) ?? 0,
                silverWeightGrams: _assets.silverWeightGrams,
                silverRatePerGram: double.tryParse(silverRateController.text) ?? 0,
                investments: _assets.investments,
                businessStock: _assets.businessStock,
                receivables: _assets.receivables,
                otherAssets: _assets.otherAssets,
                debts: _assets.debts,
              );
              await ZakatService.saveAssets(newAssets);
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditAssetsDialog() {
    final controllers = {
      'cash': TextEditingController(text: _assets.cash > 0 ? _assets.cash.toStringAsFixed(0) : ''),
      'bank': TextEditingController(text: _assets.bankBalance > 0 ? _assets.bankBalance.toStringAsFixed(0) : ''),
      'goldWeight': TextEditingController(text: _assets.goldWeightGrams > 0 ? _assets.goldWeightGrams.toStringAsFixed(1) : ''),
      'silverWeight': TextEditingController(text: _assets.silverWeightGrams > 0 ? _assets.silverWeightGrams.toStringAsFixed(1) : ''),
      'investments': TextEditingController(text: _assets.investments > 0 ? _assets.investments.toStringAsFixed(0) : ''),
      'business': TextEditingController(text: _assets.businessStock > 0 ? _assets.businessStock.toStringAsFixed(0) : ''),
      'receivables': TextEditingController(text: _assets.receivables > 0 ? _assets.receivables.toStringAsFixed(0) : ''),
      'other': TextEditingController(text: _assets.otherAssets > 0 ? _assets.otherAssets.toStringAsFixed(0) : ''),
      'debts': TextEditingController(text: _assets.debts > 0 ? _assets.debts.toStringAsFixed(0) : ''),
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Assets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controllers['cash']!, 'Cash in Hand'),
              _buildTextField(controllers['bank']!, 'Bank Balance'),
              const Divider(),
              const Text('Gold & Silver (in grams)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              _buildTextField(controllers['goldWeight']!, 'Gold Weight (grams)'),
              _buildTextField(controllers['silverWeight']!, 'Silver Weight (grams)'),
              const Divider(),
              _buildTextField(controllers['investments']!, 'Investments'),
              _buildTextField(controllers['business']!, 'Business Stock'),
              _buildTextField(controllers['receivables']!, 'Receivables'),
              _buildTextField(controllers['other']!, 'Other Assets'),
              const Divider(),
              _buildTextField(controllers['debts']!, 'Debts (you owe)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAssets = ZakatAssets(
                cash: double.tryParse(controllers['cash']!.text) ?? 0,
                bankBalance: double.tryParse(controllers['bank']!.text) ?? 0,
                goldWeightGrams: double.tryParse(controllers['goldWeight']!.text) ?? 0,
                goldRatePerGram: _assets.goldRatePerGram,
                silverWeightGrams: double.tryParse(controllers['silverWeight']!.text) ?? 0,
                silverRatePerGram: _assets.silverRatePerGram,
                investments: double.tryParse(controllers['investments']!.text) ?? 0,
                businessStock: double.tryParse(controllers['business']!.text) ?? 0,
                receivables: double.tryParse(controllers['receivables']!.text) ?? 0,
                otherAssets: double.tryParse(controllers['other']!.text) ?? 0,
                debts: double.tryParse(controllers['debts']!.text) ?? 0,
              );
              await ZakatService.saveAssets(newAssets);
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    final amountController = TextEditingController();
    final recipientController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Zakat Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                await ZakatService.addPayment(ZakatPayment(
                  amount: amount,
                  recipient: recipientController.text.isNotEmpty ? recipientController.text : null,
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                ));
                Navigator.pop(ctx);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment recorded')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayment(ZakatPayment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: Text('Remove payment of ${_currencyFormat.format(payment.amount)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _payments.removeWhere((p) => p.id == payment.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'zakat_payments',
        json.encode(_payments.map((p) => p.toJson()).toList()),
      );
      _loadData();
    }
  }

  void _showAllPayments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Payments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _confirmClearAllPayments(ctx),
                    child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: Icon(Icons.check, color: AppTheme.primaryGreen),
                    ),
                    title: Text(_currencyFormat.format(payment.amount)),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(payment.date) +
                      (payment.recipient != null ? '\nTo: ${payment.recipient}' : '') +
                      (payment.note != null ? '\n${payment.note}' : ''),
                    ),
                    isThreeLine: payment.recipient != null || payment.note != null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAllPayments(BuildContext sheetContext) async {
    final confirm = await showDialog<bool>(
      context: sheetContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Payments?'),
        content: const Text('This will remove all payment records. Use this when starting a new Zakat year.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ZakatService.clearPayments();
      Navigator.pop(sheetContext);
      _loadData();
    }
  }
}
