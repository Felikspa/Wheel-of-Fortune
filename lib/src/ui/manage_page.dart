import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../services/wheel_codec.dart';
import '../state/app_controller.dart';
import 'widgets/item_editor_dialog.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final wheel = controller.selectedWheel;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          children: [
            Text(l10n.wheels, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in controller.wheels)
                  ChoiceChip(
                    label: Text(entry.name),
                    selected: entry.id == controller.selectedWheelId,
                    onSelected: (_) => controller.selectWheel(entry.id),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addWheel(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.addWheel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: wheel == null
                        ? null
                        : () => _deleteWheel(context, wheel.id),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.deleteWheel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: wheel == null
                        ? null
                        : () => _exportWheel(context),
                    icon: const Icon(Icons.upload_outlined),
                    label: Text(l10n.quickExport),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _importWheel(context),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.quickImport),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (wheel != null) ...[
              _WheelSettingsCard(wheel: wheel),
              const SizedBox(height: 14),
              _ItemsCard(wheel: wheel),
              const SizedBox(height: 14),
            ],
            const _AppSettingsCard(),
          ],
        );
      },
    );
  }

  Future<void> _addWheel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AppController>();
    final name = await _showTextInputDialog(
      context,
      title: l10n.addWheel,
      initial: l10n.newWheelDefaultName,
      label: l10n.wheelName,
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    await controller.createWheel(name.trim());
  }

  Future<void> _deleteWheel(BuildContext context, int wheelId) async {
    final l10n = AppLocalizations.of(context)!;
    final appController = context.read<AppController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWheelConfirmTitle),
        content: Text(l10n.deleteWheelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await appController.deleteWheel(wheelId);
  }

  Future<void> _exportWheel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final code = context.read<AppController>().exportCurrentWheel();
    if (code.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportCopied)));
  }

  Future<void> _importWheel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AppController>();
    final inputController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importWheelCode),
        content: TextField(
          controller: inputController,
          minLines: 7,
          maxLines: 14,
          decoration: InputDecoration(hintText: l10n.pasteCodeHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(inputController.text),
            child: Text(l10n.importAction),
          ),
        ],
      ),
    );
    inputController.dispose();
    if (result == null || result.trim().isEmpty) {
      return;
    }
    final summary = await controller.importFromCode(result);
    if (!context.mounted) {
      return;
    }
    final messages = <String>[];
    if (summary.created) {
      messages.add(l10n.importCreatedWheel(summary.validItems));
    } else {
      messages.add(l10n.importFailedNoValidItem);
    }
    if (summary.errors.isNotEmpty) {
      messages.add(l10n.importErrorSummary(summary.errors.length));
      for (final error in summary.errors.take(3)) {
        messages.add(
          l10n.dslErrorLabel(error.line, _errorMessage(context, error.code)),
        );
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messages.join('\n'))));
  }

  String _errorMessage(BuildContext context, WheelImportErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      WheelImportErrorCode.missingTitle => l10n.dslErrorMissingTitle,
      WheelImportErrorCode.tooManyFields => l10n.dslErrorTooManyFields,
      WheelImportErrorCode.invalidColor => l10n.dslErrorInvalidColor,
      WheelImportErrorCode.invalidWeight => l10n.dslErrorInvalidWeight,
      WheelImportErrorCode.invalidHeader => l10n.dslErrorInvalidHeader,
    };
  }
}

class _WheelSettingsCard extends StatefulWidget {
  const _WheelSettingsCard({required this.wheel});

  final WheelModel wheel;

  @override
  State<_WheelSettingsCard> createState() => _WheelSettingsCardState();
}

class _WheelSettingsCardState extends State<_WheelSettingsCard> {
  late double _spinDuration;
  bool _isDraggingDuration = false;

  @override
  void initState() {
    super.initState();
    _spinDuration = widget.wheel.spinDurationMs.toDouble();
  }

  @override
  void didUpdateWidget(covariant _WheelSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wheelChanged = oldWidget.wheel.id != widget.wheel.id;
    final valueChanged =
        oldWidget.wheel.spinDurationMs != widget.wheel.spinDurationMs;
    if (!_isDraggingDuration && (wheelChanged || valueChanged)) {
      _spinDuration = widget.wheel.spinDurationMs.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AppController>();
    final randomPaletteLabel =
        Localizations.localeOf(context).languageCode == 'zh' ? '随机' : 'Random';
    final paletteOptions = <String, String>{
      'random': randomPaletteLabel,
      'ocean': l10n.paletteOcean,
      'sunset': l10n.paletteSunset,
      'mint': l10n.paletteMint,
      'mono': l10n.paletteMono,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentWheelSettings,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey(
                'wheel-name-${widget.wheel.id}-${widget.wheel.name}',
              ),
              initialValue: widget.wheel.name,
              decoration: InputDecoration(labelText: l10n.wheelName),
              onFieldSubmitted: (value) {
                if (value.trim().isEmpty) {
                  return;
                }
                controller.updateWheelConfig(
                  wheelId: widget.wheel.id,
                  name: value.trim(),
                );
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ProbabilityMode>(
              key: ValueKey(
                'wheel-mode-${widget.wheel.id}-${widget.wheel.probabilityMode.name}',
              ),
              initialValue: widget.wheel.probabilityMode,
              decoration: InputDecoration(labelText: l10n.probabilityMode),
              items: [
                DropdownMenuItem(
                  value: ProbabilityMode.equal,
                  child: Text(l10n.modeEqual),
                ),
                DropdownMenuItem(
                  value: ProbabilityMode.weighted,
                  child: Text(l10n.modeWeighted),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                controller.updateWheelConfig(
                  wheelId: widget.wheel.id,
                  mode: value,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.spinDuration}: ${l10n.secondsShort((_spinDuration / 1000).toStringAsFixed(1))}',
            ),
            Slider(
              value: _spinDuration,
              min: 2000,
              max: 10000,
              divisions: 16,
              onChanged: (value) {
                setState(() {
                  _spinDuration = value;
                  _isDraggingDuration = true;
                });
              },
              onChangeEnd: (value) async {
                _isDraggingDuration = false;
                await controller.updateWheelConfig(
                  wheelId: widget.wheel.id,
                  spinDurationMs: value.round(),
                );
              },
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'wheel-palette-${widget.wheel.id}-${widget.wheel.palette}',
              ),
              initialValue: widget.wheel.palette,
              decoration: InputDecoration(labelText: l10n.palette),
              items: paletteOptions.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                controller.updateWheelConfig(
                  wheelId: widget.wheel.id,
                  palette: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.wheel});

  final WheelModel wheel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.items,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _quickImportItems(context),
                  icon: const Icon(Icons.playlist_add_outlined),
                  tooltip: l10n.quickImportItems,
                ),
                IconButton(
                  onPressed: () => _addItem(context),
                  icon: const Icon(Icons.add),
                  tooltip: l10n.addItem,
                ),
              ],
            ),
            SizedBox(
              height: 320,
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: wheel.items.length,
                onReorder: (oldIndex, newIndex) {
                  final items = [...wheel.items];
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final moved = items.removeAt(oldIndex);
                  items.insert(newIndex, moved);
                  context.read<AppController>().saveCurrentWheelItems(items);
                },
                itemBuilder: (context, index) {
                  final item = wheel.items[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.title),
                    subtitle: item.subtitle == null
                        ? null
                        : Text(item.subtitle!),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    onTap: () => _editItem(context, index, item),
                    trailing: IconButton(
                      onPressed: () => context
                          .read<AppController>()
                          .deleteItemByOrder(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appController = context.read<AppController>();
    final edited = await showItemEditorDialog(context);
    if (edited == null) {
      return;
    }
    await appController.addItem(
      WheelItemModel(
        id: 0,
        wheelId: wheel.id,
        order: wheel.items.length,
        title: edited.title.isEmpty ? l10n.newItemDefaultTitle : edited.title,
        subtitle: edited.subtitle,
        tags: edited.tags,
        note: edited.note,
        colorHex: edited.colorHex,
        weight: edited.weight,
      ),
    );
  }

  Future<void> _quickImportItems(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appController = context.read<AppController>();
    final text = await _showQuickImportDialog(context);
    if (text == null || text.trim().isEmpty) {
      return;
    }

    final summary = await appController.quickImportItemsToCurrentWheel(text);
    if (!context.mounted) {
      return;
    }

    final messages = <String>[];
    if (summary.importedItems > 0) {
      messages.add(l10n.quickImportAdded(summary.importedItems));
    } else {
      messages.add(l10n.importFailedNoValidItem);
    }
    if (summary.skippedByLimit > 0) {
      messages.add(l10n.quickImportSkipped(summary.skippedByLimit));
    }
    if (summary.errors.isNotEmpty) {
      messages.add(l10n.importErrorSummary(summary.errors.length));
      for (final error in summary.errors.take(3)) {
        messages.add(
          l10n.dslErrorLabel(error.line, _errorMessage(context, error.code)),
        );
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messages.join('\n'))));
  }

  Future<String?> _showQuickImportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.quickImportItems),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.quickImportExampleLabel),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(l10n.quickImportExampleText),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showQuickImportSyntaxGuide(context),
                  child: Text(l10n.syntaxGuideEntry),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                minLines: 6,
                maxLines: 12,
                decoration: InputDecoration(hintText: l10n.quickImportHint),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.importAction),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _showQuickImportSyntaxGuide(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.syntaxGuideTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(l10n.syntaxGuideOverview),
                const SizedBox(height: 10),
                Text(l10n.syntaxGuideRule1),
                Text(l10n.syntaxGuideRule2),
                Text(l10n.syntaxGuideRule3),
                Text(l10n.syntaxGuideRule4),
                const SizedBox(height: 10),
                Text(
                  l10n.syntaxGuideExample1Title,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(l10n.syntaxGuideExample1Value),
                const SizedBox(height: 10),
                Text(
                  l10n.syntaxGuideExample2Title,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(l10n.syntaxGuideExample2Value),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(BuildContext context, WheelImportErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      WheelImportErrorCode.missingTitle => l10n.dslErrorMissingTitle,
      WheelImportErrorCode.tooManyFields => l10n.dslErrorTooManyFields,
      WheelImportErrorCode.invalidColor => l10n.dslErrorInvalidColor,
      WheelImportErrorCode.invalidWeight => l10n.dslErrorInvalidWeight,
      WheelImportErrorCode.invalidHeader => l10n.dslErrorInvalidHeader,
    };
  }

  Future<void> _editItem(
    BuildContext context,
    int index,
    WheelItemModel item,
  ) async {
    final appController = context.read<AppController>();
    final edited = await showItemEditorDialog(context, initialItem: item);
    if (edited == null) {
      return;
    }
    await appController.updateItemByOrder(
      index,
      WheelItemModel(
        id: item.id,
        wheelId: item.wheelId,
        order: item.order,
        title: edited.title,
        subtitle: edited.subtitle,
        tags: edited.tags,
        note: edited.note,
        colorHex: edited.colorHex,
        weight: edited.weight,
        customFields: item.customFields,
      ),
    );
  }
}

class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final settings = controller.settings;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appSettings,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  key: ValueKey(
                    'locale-${settings.localeOverride ?? 'system'}',
                  ),
                  initialValue: settings.localeOverride,
                  decoration: InputDecoration(labelText: l10n.language),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.languageSystem),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'en',
                      child: Text(l10n.languageEnglish),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'zh',
                      child: Text(l10n.languageChinese),
                    ),
                  ],
                  onChanged: (value) => controller.setLocaleOverride(value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AppThemeMode>(
                  key: ValueKey('theme-mode-${settings.themeMode.name}'),
                  initialValue: settings.themeMode,
                  decoration: InputDecoration(labelText: l10n.theme),
                  items: [
                    DropdownMenuItem(
                      value: AppThemeMode.system,
                      child: Text(l10n.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: AppThemeMode.light,
                      child: Text(l10n.themeLight),
                    ),
                    DropdownMenuItem(
                      value: AppThemeMode.dark,
                      child: Text(l10n.themeDark),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setThemeMode(value);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<String?> _showTextInputDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required String label,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
