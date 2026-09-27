import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/qaza_service.dart';
import '../../utils/theme/app_theme.dart';

class QazaCalculatorScreen extends StatefulWidget {
  const QazaCalculatorScreen({super.key});

  @override
  State<QazaCalculatorScreen> createState() => _QazaCalculatorScreenState();
}

class _QazaCalculatorScreenState extends State<QazaCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Age when started praying regularly
  final _startAgeController = TextEditingController();
  
  // Current age
  final _currentAgeController = TextEditingController();
  
  // Years of irregular prayer
  final _irregularYearsController = TextEditingController();
  
  // Percentage of prayers missed during irregular years
  double _missedPercentage = 50.0;
  
  // Calculated results
  Map<String, int> _calculatedQaza = {};
  bool _showResults = false;

  @override
  void dispose() {
    _startAgeController.dispose();
    _currentAgeController.dispose();
    _irregularYearsController.dispose();
    super.dispose();
  }

  void _calculateQaza() {
    if (!_formKey.currentState!.validate()) return;

    final startAge = int.parse(_startAgeController.text);
    final currentAge = int.parse(_currentAgeController.text);
    final irregularYears = int.parse(_irregularYearsController.text);
    
    // Calculate total years of prayer obligation
    final totalYears = currentAge - startAge;
    
    if (totalYears <= 0) {
      _showErrorDialog('Invalid age range. Current age must be greater than start age.');
      return;
    }
    
    if (irregularYears > totalYears) {
      _showErrorDialog('Irregular years cannot be more than total years of prayer obligation.');
      return;
    }
    
    // Calculate prayers per year (approximately)
    const daysPerYear = 365;
    const fardPrayersPerDay = 5; // Fajr, Zuhr, Asr, Maghrib, Isha
    // ignore: unused_local_variable
    const witrPrayersPerDay = 1; // Witr (Hanafi considers it Wajib)
    
    // Calculate missed prayers during irregular years
    final irregularDays = (irregularYears * daysPerYear).round();
    final missedFardPerDay = (fardPrayersPerDay * _missedPercentage / 100).round();
    final missedWitrPerDay = (_missedPercentage > 50 ? 1 : 0); // More conservative for Witr
    
    final totalMissedFard = irregularDays * missedFardPerDay;
    final totalMissedWitr = irregularDays * missedWitrPerDay;
    
    // Distribute Fard prayers (assuming equal distribution)
    final fardPerPrayer = (totalMissedFard / 5).round();
    
    setState(() {
      _calculatedQaza = {
        'Fajr': fardPerPrayer,
        'Zuhr': fardPerPrayer,
        'Asr': fardPerPrayer,
        'Maghrib': fardPerPrayer,
        'Isha': fardPerPrayer,
        'Witr': totalMissedWitr,
      };
      _showResults = true;
    });

    // Show calculation details
    _showCalculationDetails(totalYears, irregularYears, irregularDays);
  }

  void _showCalculationDetails(int totalYears, int irregularYears, int irregularDays) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'Total years of prayer obligation:', '$totalYears years'),
            _buildDetailRow(context, 'Years with irregular prayers:', '$irregularYears years'),
            _buildDetailRow(context, 'Days with irregular prayers:', '$irregularDays days'),
            _buildDetailRow(context, 'Estimated missed percentage:', '${_missedPercentage.round()}%'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note:',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This is an estimation. For exact count, consult with a knowledgeable scholar. The calculation assumes equal distribution of missed prayers.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Input Error',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addCalculatedQaza() async {
    if (_calculatedQaza.isNotEmpty) {
      await QazaService.addQazaPrayers(_calculatedQaza);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calculated Qaza prayers added to your tracker'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _resetCalculation() {
    setState(() {
      _startAgeController.clear();
      _currentAgeController.clear();
      _irregularYearsController.clear();
      _missedPercentage = 50.0;
      _calculatedQaza.clear();
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Qaza Calculator'),
        actions: [
          if (_showResults)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetCalculation,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              if (!_showResults) ...[
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildCalculateButton(),
              ] else ...[
                _buildResultsSection(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.8),
            Colors.indigo.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calculate,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Estimate Your Qaza Prayers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculate an approximate number of missed prayers based on your prayer history',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prayer History',
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _startAgeController,
          label: 'Age when you started praying regularly',
          hint: 'e.g., 15',
          icon: Icons.child_care,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _currentAgeController,
          label: 'Your current age',
          hint: 'e.g., 25',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _irregularYearsController,
          label: 'Years with irregular prayers',
          hint: 'e.g., 5',
          icon: Icons.timeline,
        ),
        const SizedBox(height: 20),
        _buildPercentageSlider(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: TextStyle(color: onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 100) {
              return 'Please enter a valid age (1-100)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPercentageSlider() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated percentage of prayers missed during irregular years',
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Missed prayers:',
                    style: TextStyle(color: onSurface),
                  ),
                  Text(
                    '${_missedPercentage.round()}%',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: onSurface.withValues(alpha: 0.15),
                  thumbColor: Colors.orange,
                  overlayColor: Colors.orange.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: _missedPercentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _missedPercentage = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rarely (0%)',
                    style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
                  ),
                  Text(
                    'Always (100%)',
                    style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateQaza,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Calculate Qaza Prayers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    final totalQaza = _calculatedQaza.values.fold(0, (sum, count) => sum + count);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculated Results',
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.8),
                Colors.teal.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.assessment,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'Estimated Total Qaza',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                totalQaza.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'prayers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _calculatedQaza.length,
          itemBuilder: (context, index) {
            final prayer = _calculatedQaza.keys.elementAt(index);
            final count = _calculatedQaza[prayer]!;
            return _buildResultCard(prayer, count);
          },
        ),
      ],
    );
  }

  Widget _buildResultCard(String prayer, int count) {
    final color = AppTheme.legibleAccent(context, _getPrayerColor(prayer));
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getPrayerIcon(prayer),
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            prayer,
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addCalculatedQaza,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Add to My Qaza Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetCalculation,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Calculate Again',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr': return Colors.blue;
      case 'Zuhr': return Colors.orange;
      case 'Asr': return Colors.amber;
      case 'Maghrib': return Colors.pink;
      case 'Isha': return Colors.purple;
      case 'Witr': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr': return Icons.wb_twilight;
      case 'Zuhr': return Icons.wb_sunny;
      case 'Asr': return Icons.wb_sunny_outlined;
      case 'Maghrib': return Icons.nights_stay;
      case 'Isha': return Icons.nightlight;
      case 'Witr': return Icons.star;
      default: return Icons.mosque;
    }
  }
}