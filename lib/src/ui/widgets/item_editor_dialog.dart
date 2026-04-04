import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models.dart';

class ItemEditorResult {
  const ItemEditorResult({
    required this.title,
    this.subtitle,
    this.tags,
    this.note,
    this.colorHex,
    this.weight,
  });

  final String title;
  final String? subtitle;
  final String? tags;
  final String? note;
  final String? colorHex;
  final double? weight;
}

Future<ItemEditorResult?> showItemEditorDialog(
  BuildContext context, {
  WheelItemModel? initialItem,
}) {
  return showDialog<ItemEditorResult>(
    context: context,
    builder: (_) => _ItemEditorDialog(initialItem: initialItem),
  );
}

class _ItemEditorDialog extends StatefulWidget {
  const _ItemEditorDialog({this.initialItem});

  final WheelItemModel? initialItem;

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _tagsController;
  late final TextEditingController _noteController;
  late final TextEditingController _colorController;
  late final TextEditingController _weightController;

  static final RegExp _hexPattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _subtitleController = TextEditingController(text: item?.subtitle ?? '');
    _tagsController = TextEditingController(text: item?.tags ?? '');
    _noteController = TextEditingController(text: item?.note ?? '');
    _colorController = TextEditingController(text: item?.colorHex ?? '');
    _weightController = TextEditingController(text: item?.weight?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _tagsController.dispose();
    _noteController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.initialItem == null ? l10n.addItem : l10n.editItem),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.itemTitle),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.requiredField : null,
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(labelText: l10n.itemSubtitle),
              ),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: l10n.itemTags),
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.itemNote),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: l10n.itemColorHex),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]'))],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  return _hexPattern.hasMatch(value.trim()) ? null : l10n.invalidColorHex;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: l10n.itemWeight),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final parsed = double.tryParse(value.trim());
                  return parsed != null && parsed > 0 ? null : l10n.invalidWeight;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              ItemEditorResult(
                title: _titleController.text.trim(),
                subtitle: _valueOrNull(_subtitleController.text),
                tags: _valueOrNull(_tagsController.text),
                note: _valueOrNull(_noteController.text),
                colorHex: _valueOrNull(_colorController.text),
                weight: _weightController.text.trim().isEmpty
                    ? null
                    : double.parse(_weightController.text.trim()),
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  String? _valueOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
