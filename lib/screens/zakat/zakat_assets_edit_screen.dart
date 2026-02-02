// screens/zakat/zakat_assets_edit_screen.dart
// Full screen editor for Zakat assets with dynamic entries
import 'package:flutter/material.dart';
import '../../services/zakat_service.dart';
import '../../utils/theme/app_theme.dart';

class ZakatAssetsEditScreen extends StatefulWidget {
  final ZakatAssets initialAssets;

  const ZakatAssetsEditScreen({super.key, required this.initialAssets});

  @override
  State<ZakatAssetsEditScreen> createState() => _ZakatAssetsEditScreenState();
}

class _ZakatAssetsEditScreenState extends State<ZakatAssetsEditScreen> {
  // Dynamic entries
  late List<_EntryController> _cashEntries;
  late List<_EntryController> _bankEntries;
  late List<_EntryController> _debtEntries;

  // Fixed fields
  late TextEditingController _goldWeightController;
  late TextEditingController _goldRateController;
  late TextEditingController _silverWeightController;
  late TextEditingController _silverRateController;
  late TextEditingController _investmentsController;
  late TextEditingController _businessController;
  late TextEditingController _receivablesController;
  late TextEditingController _otherController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAssets;

    // Initialize cash entries
    _cashEntries = a.cashEntries.isEmpty
        ? [_EntryController(name: 'Cash in Hand', amount: '')]
        : a.cashEntries.map((e) => _EntryController(
            name: e.name,
            amount: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
          )).toList();

    // Initialize bank entries
    _bankEntries = a.bankEntries.isEmpty
        ? [_EntryController(name: 'Bank Account', amount: '')]
        : a.bankEntries.map((e) => _EntryController(
            name: e.name,
            amount: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
          )).toList();

    // Initialize debt entries
    _debtEntries = a.debtEntries.isEmpty
        ? [_EntryController(name: 'Debt/Loan', amount: '')]
        : a.debtEntries.map((e) => _EntryController(
            name: e.name,
            amount: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
          )).toList();

    // Fixed controllers
    _goldWeightController = TextEditingController(
      text: a.goldWeightGrams > 0 ? a.goldWeightGrams.toStringAsFixed(1) : '',
    );
    _goldRateController = TextEditingController(
      text: a.goldRatePerGram > 0 ? a.goldRatePerGram.toStringAsFixed(0) : '',
    );
    _silverWeightController = TextEditingController(
      text: a.silverWeightGrams > 0 ? a.silverWeightGrams.toStringAsFixed(1) : '',
    );
    _silverRateController = TextEditingController(
      text: a.silverRatePerGram > 0 ? a.silverRatePerGram.toStringAsFixed(0) : '',
    );
    _investmentsController = TextEditingController(
      text: a.investments > 0 ? a.investments.toStringAsFixed(0) : '',
    );
    _businessController = TextEditingController(
      text: a.businessStock > 0 ? a.businessStock.toStringAsFixed(0) : '',
    );
    _receivablesController = TextEditingController(
      text: a.receivables > 0 ? a.receivables.toStringAsFixed(0) : '',
    );
    _otherController = TextEditingController(
      text: a.otherAssets > 0 ? a.otherAssets.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    for (var e in _cashEntries) {
      e.dispose();
    }
    for (var e in _bankEntries) {
      e.dispose();
    }
    for (var e in _debtEntries) {
      e.dispose();
    }
    _goldWeightController.dispose();
    _goldRateController.dispose();
    _silverWeightController.dispose();
    _silverRateController.dispose();
    _investmentsController.dispose();
    _businessController.dispose();
    _receivablesController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  List<NamedAmount> _parseEntries(List<_EntryController> entries) {
    return entries
        .where((e) => e.amountController.text.isNotEmpty)
        .map((e) => NamedAmount(
              name: e.nameController.text.trim().isEmpty
                  ? 'Unnamed'
                  : e.nameController.text.trim(),
              amount: double.tryParse(e.amountController.text) ?? 0,
            ))
        .where((e) => e.amount > 0)
        .toList();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final newAssets = ZakatAssets(
      cashEntries: _parseEntries(_cashEntries),
      bankEntries: _parseEntries(_bankEntries),
      goldWeightGrams: double.tryParse(_goldWeightController.text) ?? 0,
      goldRatePerGram: double.tryParse(_goldRateController.text) ?? 0,
      silverWeightGrams: double.tryParse(_silverWeightController.text) ?? 0,
      silverRatePerGram: double.tryParse(_silverRateController.text) ?? 0,
      investments: double.tryParse(_investmentsController.text) ?? 0,
      businessStock: double.tryParse(_businessController.text) ?? 0,
      receivables: double.tryParse(_receivablesController.text) ?? 0,
      otherAssets: double.tryParse(_otherController.text) ?? 0,
      debtEntries: _parseEntries(_debtEntries),
    );

    await ZakatService.saveAssets(newAssets);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Assets'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Rates Section
            _buildSectionHeader('Market Rates', Icons.trending_up),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _goldRateController,
                            'Gold Rate/gram',
                            icon: Icons.diamond,
                            iconColor: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _silverRateController,
                            'Silver Rate/gram',
                            icon: Icons.circle,
                            iconColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cash Section
            _buildSectionHeader('Cash in Hand', Icons.money),
            _buildDynamicEntryList(
              entries: _cashEntries,
              defaultName: 'Cash',
              onAdd: () => setState(() {
                _cashEntries.add(_EntryController(name: '', amount: ''));
              }),
              onRemove: (index) => setState(() {
                _cashEntries[index].dispose();
                _cashEntries.removeAt(index);
              }),
            ),
            const SizedBox(height: 20),

            // Bank Section
            _buildSectionHeader('Bank Accounts', Icons.account_balance),
            _buildDynamicEntryList(
              entries: _bankEntries,
              defaultName: 'Bank Account',
              onAdd: () => setState(() {
                _bankEntries.add(_EntryController(name: '', amount: ''));
              }),
              onRemove: (index) => setState(() {
                _bankEntries[index].dispose();
                _bankEntries.removeAt(index);
              }),
            ),
            const SizedBox(height: 20),

            // Gold & Silver Section
            _buildSectionHeader('Gold & Silver', Icons.diamond),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.diamond, color: Colors.amber.shade700, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(_goldWeightController, 'Gold Weight (grams)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.circle, color: Colors.grey.shade600, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(_silverWeightController, 'Silver Weight (grams)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Other Assets Section
            _buildSectionHeader('Other Assets', Icons.account_balance_wallet),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(_investmentsController, 'Investments'),
                    const SizedBox(height: 12),
                    _buildTextField(_businessController, 'Business Stock/Inventory'),
                    const SizedBox(height: 12),
                    _buildTextField(_receivablesController, 'Receivables (money owed to you)'),
                    const SizedBox(height: 12),
                    _buildTextField(_otherController, 'Other Assets'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Liabilities Section
            _buildSectionHeader('Liabilities (Deductible)', Icons.remove_circle, color: Colors.red),
            _buildDynamicEntryList(
              entries: _debtEntries,
              defaultName: 'Debt/Loan',
              onAdd: () => setState(() {
                _debtEntries.add(_EntryController(name: '', amount: ''));
              }),
              onRemove: (index) => setState(() {
                _debtEntries[index].dispose();
                _debtEntries.removeAt(index);
              }),
              isDebt: true,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicEntryList({
    required List<_EntryController> entries,
    required String defaultName,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    bool isDebt = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...entries.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: defaultName,
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(
                            isDebt ? Icons.receipt_long : Icons.label,
                            size: 20,
                            color: isDebt ? Colors.red.shade300 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.monetization_on,
                            size: 20,
                            color: isDebt ? Colors.red.shade300 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (entries.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => onRemove(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDebt ? Colors.red : AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    Color? iconColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: iconColor ?? Colors.grey)
            : null,
      ),
    );
  }
}

/// Controller for a name+amount entry
class _EntryController {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _EntryController({required String name, required String amount})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}
