// lib/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsBottomSheet;
  
  const LanguageSelector({
    super.key,
    this.showAsBottomSheet = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsBottomSheet) {
      return IconButton(
        icon: const Icon(Icons.language),
        onPressed: () => _showLanguageBottomSheet(context),
        tooltip: 'Change Language',
      );
    } else {
      return _buildLanguageGrid(context);
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select Language / भाषा चुनें / زبان منتخب کریں / ভাষা নির্বাচন করুন',
                style: AppTheme.subheadingStyle(context),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Language options
            _buildLanguageGrid(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageGrid(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, currentLocale, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
            children: LanguageService.supportedLanguages.entries.map((entry) {
              final languageName = entry.key;
              final locale = entry.value;
              final isSelected = currentLocale.languageCode == locale.languageCode;
              
              return _buildLanguageOption(
                context: context,
                languageName: languageName,
                locale: locale,
                isSelected: isSelected,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageName,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await LanguageService.changeLanguage(locale);
        if (showAsBottomSheet && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Language flag or icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getLanguageColor(locale.languageCode),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getLanguageEmoji(locale.languageCode),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Language name
              Expanded(
                child: Text(
                  languageName,
                  style: AppTheme.bodyStyle(context).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLanguageColor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Colors.blue;
      case 'hi':
        return Colors.orange;
      case 'ur':
        return Colors.green;
      case 'bn':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLanguageEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'hi':
        return '🇮🇳';
      case 'ur':
        return '🇵🇰';
      case 'bn':
        return '🇧🇩';
      default:
        return '🌐';
    }
  }
}

// Usage in a settings screen or app bar
class LanguageSelectorExample extends StatelessWidget {
  const LanguageSelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: const [
          LanguageSelector(), // This shows as icon button with bottom sheet
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LanguageSelector(showAsBottomSheet: false), // This shows inline
          ],
        ),
      ),
    );
  }
}