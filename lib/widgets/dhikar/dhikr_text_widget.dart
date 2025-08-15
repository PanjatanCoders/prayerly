// widgets/dhikr_text_widget.dart
import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_models.dart';

/// Widget for displaying Dhikr text in multiple formats
class DhikrTextWidget extends StatelessWidget {
  final Dhikr dhikr;
  final DhikrSettings settings;
  final bool isCompact;

  const DhikrTextWidget({
    super.key,
    required this.dhikr,
    required this.settings,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      margin: EdgeInsets.all(isCompact ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dhikr.category.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: dhikr.category.color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: dhikr.category.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dhikr.category.displayName.split(' ')[0], // First word only
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (dhikr.reward != null)
                Chip(
                  label: Text(
                    '${dhikr.reward}x Reward',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.amber.shade100,
                  side: BorderSide.none,
                ),
            ],
          ),
          
          SizedBox(height: isCompact ? 8 : 12),
          
          // Arabic text
          if (settings.showArabicText)
            _buildArabicText(),
          
          // Transliteration
          if (settings.showTransliteration)
            _buildTransliterationText(),
          
          // Translation
          if (settings.showTranslation)
            _buildTranslationText(),
          
          // Meaning (only in full mode)
          if (!isCompact && dhikr.meaning.isNotEmpty)
            _buildMeaningText(),
        ],
      ),
    );
  }

  Widget _buildArabicText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        dhikr.arabic,
        style: TextStyle(
          fontSize: isCompact ? 18 : 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTransliterationText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        dhikr.transliteration,
        style: TextStyle(
          fontSize: isCompact ? 14 : 16,
          fontWeight: FontWeight.w500,
          color: dhikr.category.color,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTranslationText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        dhikr.translation,
        style: TextStyle(
          fontSize: isCompact ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMeaningText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dhikr.category.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: dhikr.category.color,
              ),
              const SizedBox(width: 6),
              Text(
                'Meaning',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: dhikr.category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dhikr.meaning,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact dhikr card for lists
class DhikrCardWidget extends StatelessWidget {
  final Dhikr dhikr;
  final VoidCallback? onTap;
  final bool isSelected;

  const DhikrCardWidget({
    super.key,
    required this.dhikr,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
            ? dhikr.category.color 
            : dhikr.category.color.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and target
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: dhikr.category.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dhikr.category.displayName.split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Target: ${dhikr.targetCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Arabic text
              Text(
                dhikr.arabic,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
              
              const SizedBox(height: 6),
              
              // Transliteration
              Text(
                dhikr.transliteration,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: dhikr.category.color,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Translation
              Text(
                dhikr.translation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              
              // Reward indicator
              if (dhikr.reward != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dhikr.reward}x Spiritual Reward',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple dhikr display for counter screen
class DhikrDisplayWidget extends StatelessWidget {
  final Dhikr dhikr;
  final DhikrSettings settings;

  const DhikrDisplayWidget({
    super.key,
    required this.dhikr,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dhikr.category.color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Arabic text
          if (settings.showArabicText)
            Text(
              dhikr.arabic,
              style: TextStyle(
                fontSize: 20 + settings.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          
          if (settings.showArabicText && 
              (settings.showTransliteration || settings.showTranslation))
            const SizedBox(height: 12),
          
          // Transliteration
          if (settings.showTransliteration)
            Text(
              dhikr.transliteration,
              style: TextStyle(
                fontSize: 14 + (settings.fontSize * 0.7),
                fontWeight: FontWeight.w500,
                color: dhikr.category.color,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          
          if (settings.showTransliteration && settings.showTranslation)
            const SizedBox(height: 8),
          
          // Translation
          if (settings.showTranslation)
            Text(
              dhikr.translation,
              style: TextStyle(
                fontSize: 12 + (settings.fontSize * 0.5),
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}