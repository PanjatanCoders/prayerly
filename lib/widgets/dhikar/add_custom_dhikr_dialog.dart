import 'package:flutter/material.dart';
import 'package:prayerly/models/dhikr_tracking_models.dart';
import 'package:prayerly/services/dhikr_service.dart';

/// Lets the user create their own tasbih: a title, optional Arabic text and
/// translation, and a target count. Returns the built [CustomDhikr] via
/// [onCreate], or nothing if the sheet is dismissed.
class AddCustomDhikrDialog extends StatefulWidget {
  final void Function(CustomDhikr dhikr) onCreate;

  const AddCustomDhikrDialog({super.key, required this.onCreate});

  @override
  State<AddCustomDhikrDialog> createState() => _AddCustomDhikrDialogState();
}

class _AddCustomDhikrDialogState extends State<AddCustomDhikrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _arabicController = TextEditingController();
  final _translationController = TextEditingController();
  final _targetController = TextEditingController(text: '33');

  @override
  void dispose() {
    _titleController.dispose();
    _arabicController.dispose();
    _translationController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final arabic = _arabicController.text.trim();
    final translation = _translationController.text.trim();
    final target = int.parse(_targetController.text);

    var dhikr = CustomDhikr.createCustom(
      title: title,
      targetCount: target,
      description: translation.isEmpty ? null : translation,
    );
    if (arabic.isNotEmpty) {
      dhikr = dhikr.copyWith(arabic: arabic);
    }

    widget.onCreate(dhikr);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Add Your Own Tasbih',
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Ya Latif',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name for your tasbih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _arabicController,
                  decoration: const InputDecoration(
                    labelText: 'Arabic text (optional)',
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _translationController,
                  decoration: const InputDecoration(
                    labelText: 'Meaning / translation (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(labelText: 'Target count'),
                  keyboardType: TextInputType.number,
                  validator: DhikrService.validateTargetCount,
                ),
                const SizedBox(height: 4),
                Text(
                  'Common targets: 33, 99, 100',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add Tasbih')),
      ],
    );
  }
}
