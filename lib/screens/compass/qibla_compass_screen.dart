// screens/qibla_compass_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:prayerly/models/qibla_data.dart';
import 'package:prayerly/services/qibla_service.dart';
import 'package:prayerly/widgets/compass/compass_widget.dart';
import 'package:prayerly/widgets/compass/loading_error_widgets.dart';
import 'package:prayerly/widgets/compass/qibla_info_widget.dart';

/// Main Qibla compass screen with real-time updates
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  // State variables
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  QiblaData? _qiblaData;
  
  // Stream management
  Stream<QiblaData>? _qiblaStream;
  StreamSubscription<QiblaData>? _qiblaSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  @override
  void dispose() {
    _qiblaSubscription?.cancel();
    QiblaService.dispose();
    super.dispose();
  }

  /// Initialize the Qibla compass
  Future<void> _initializeCompass() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Check if compass is available
      final isCompassAvailable = await QiblaService.isCompassAvailable();
      if (!isCompassAvailable) {
        throw Exception('Compass sensor is not available on this device');
      }

      // Get initial location and Qibla data
      final position = await QiblaService.getCurrentLocation();
      final initialQiblaData = await QiblaService.getQiblaData(position);
      
      setState(() {
        _qiblaData = initialQiblaData;
        _isLoading = false;
      });

      // Start the real-time compass stream
      _startCompassStream();
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Start listening to compass updates
  void _startCompassStream() {
    try {
      _qiblaStream = QiblaService.startQiblaCompass();
      _qiblaSubscription = _qiblaStream!.listen(
        (qiblaData) {
          if (mounted) {
            setState(() {
              _qiblaData = qiblaData;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = error.toString();
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Refresh the compass data
  Future<void> _refreshCompass() async {
    await _qiblaSubscription?.cancel();
    await _initializeCompass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Qibla Compass',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.green.shade800,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _isLoading ? null : _refreshCompass,
          tooltip: 'Refresh compass',
        ),
      ],
    );
  }

  /// Build the main body content
  Widget _buildBody() {
    if (_isLoading) {
      return const QiblaLoadingWidget();
    }

    if (_hasError) {
      return QiblaErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _refreshCompass,
      );
    }

    if (_qiblaData == null) {
      return const QiblaLoadingWidget(
        message: 'Preparing compass...',
      );
    }

    return _buildCompassContent(_qiblaData!);
  }

  /// Build the main compass content
  Widget _buildCompassContent(QiblaData qiblaData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Main compass widget
          CompassWidget(qiblaData: qiblaData),
          
          const SizedBox(height: 20),
          
          // Direction banner
          QiblaDirectionBanner(qiblaData: qiblaData),
          
          // Information cards
          QiblaInfoWidget(qiblaData: qiblaData),
          
          // Instructions card
          _buildInstructionsCard(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build instructions card for users
  Widget _buildInstructionsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'How to Use',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildInstructionItem(
              '1. Hold your device flat (parallel to ground)',
              Icons.phone_android,
            ),
            const SizedBox(height: 8),
            
            _buildInstructionItem(
              '2. Rotate until the amber marker points upward',
              Icons.rotate_right,
            ),
            const SizedBox(height: 8),
            
            _buildInstructionItem(
              '3. Face the direction of the amber marker',
              Icons.explore,
            ),
            const SizedBox(height: 8),
            
            _buildInstructionItem(
              '4. You are now facing Qibla (Kaaba direction)',
              Icons.place,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual instruction item
  Widget _buildInstructionItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}