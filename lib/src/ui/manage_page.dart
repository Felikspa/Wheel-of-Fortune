import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../services/wheel_codec.dart';
import '../state/app_controller.dart';
import 'widgets/item_editor_dialog.dart';
import 'widgets/liquid_glass_chrome.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final wheel = controller.selectedWheel;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            _SectionTitle(icon: Icons.layers_outlined, title: l10n.wheels),
            const SizedBox(height: 8),
            _FrostedPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in controller.wheels)
                        ChoiceChip(
                          showCheckmark: false,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          label: Text(entry.name),
                          selected: entry.id == controller.selectedWheelId,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.26 : 0.2,
                          ),
                          side: BorderSide(
                            color: entry.id == controller.selectedWheelId
                                ? theme.colorScheme.primary.withValues(
                                    alpha: isDark ? 0.45 : 0.38,
                                  )
                                : (theme.dividerTheme.color ??
                                          Colors.transparent)
                                      .withValues(alpha: isDark ? 0.9 : 1),
                          ),
                          onSelected: (_) => controller.selectWheel(entry.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionTitle(icon: Icons.bolt_rounded, title: l10n.tabManage),
            const SizedBox(height: 8),
            _FrostedPanel(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.addWheel,
                          onPressed: () => _addWheel(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: l10n.deleteWheel,
                          onPressed: wheel == null
                              ? null
                              : () => _deleteWheel(context, wheel.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.upload_rounded,
                          label: l10n.quickExport,
                          onPressed: wheel == null
                              ? null
                              : () => _exportWheel(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.download_rounded,
                          label: l10n.quickImport,
                          onPressed: () => _importWheel(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (wheel != null) ...[
              _WheelSettingsCard(wheel: wheel),
              const SizedBox(height: 16),
              _ItemsCard(wheel: wheel),
              const SizedBox(height: 16),
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
    // Avoid mutating provider state in the same frame as dialog dismissal.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) {
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
    await WidgetsBinding.instance.endOfFrame;
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
    final pinkPaletteLabel =
        Localizations.localeOf(context).languageCode == 'zh' ? '樱粉' : 'Pink';
    final paletteOptions = <String, String>{
      'random': randomPaletteLabel,
      'ocean': l10n.paletteOcean,
      'sunset': l10n.paletteSunset,
      'mint': l10n.paletteMint,
      'mono': l10n.paletteMono,
      'pink': pinkPaletteLabel,
    };

    return _FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.settings_suggest_outlined,
            title: l10n.currentWheelSettings,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('wheel-name-${widget.wheel.id}-${widget.wheel.name}'),
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
            isExpanded: true,
            menuMaxHeight: 320,
            borderRadius: _dropdownPopupRadius,
            dropdownColor: _dropdownPopupColor(context),
            iconEnabledColor: Theme.of(context).colorScheme.primary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
              DropdownMenuItem(
                value: ProbabilityMode.softAntiRepeat,
                child: Text(l10n.modeSoftAntiRepeat),
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
            isExpanded: true,
            menuMaxHeight: 320,
            borderRadius: _dropdownPopupRadius,
            dropdownColor: _dropdownPopupColor(context),
            iconEnabledColor: Theme.of(context).colorScheme.primary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.wheel});

  final WheelModel wheel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _FrostedPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PanelHeader(icon: Icons.list_alt_rounded, title: l10n.items),
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
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(
                      alpha: isDark ? 0.32 : 0.56,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (theme.dividerTheme.color ?? Colors.transparent)
                          .withValues(alpha: isDark ? 0.95 : 1),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
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
                  ),
                );
              },
            ),
          ),
        ],
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

    // Avoid updating provider state in the same frame as dialog pop.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) {
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

  Future<String?> _showQuickImportDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
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
                  onPressed: () => _showQuickImportSyntaxGuide(dialogContext),
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
            onPressed: () {
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop(controller.text);
            },
            child: Text(l10n.importAction),
          ),
        ],
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    controller.dispose();
    return result;
  }

  Future<void> _showQuickImportSyntaxGuide(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
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
        return _FrostedPanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(
                icon: Icons.phone_iphone_rounded,
                title: l10n.appSettings,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                key: ValueKey('locale-${settings.localeOverride ?? 'system'}'),
                initialValue: settings.localeOverride,
                isExpanded: true,
                menuMaxHeight: 320,
                borderRadius: _dropdownPopupRadius,
                dropdownColor: _dropdownPopupColor(context),
                iconEnabledColor: Theme.of(context).colorScheme.primary,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                isExpanded: true,
                menuMaxHeight: 320,
                borderRadius: _dropdownPopupRadius,
                dropdownColor: _dropdownPopupColor(context),
                iconEnabledColor: Theme.of(context).colorScheme.primary,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onPressed != null;
    final bgColor = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.32 : 0.56,
    );
    final borderColor = (theme.dividerTheme.color ?? Colors.transparent)
        .withValues(alpha: isDark ? 0.95 : 1);
    final fgColor =
        theme.textTheme.labelLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.52,
      child: SizedBox(
        height: 50,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 19, color: fgColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedPanel extends StatelessWidget {
  const _FrostedPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    return LiquidGlassChrome(
      borderRadius: 22,
      accentColor: accentColor,
      isDark: isDark,
      shadowStrength: 0.9,
      highlightStrength: 0.92,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 16 : 14,
          glassColor: accentColor.withValues(alpha: isDark ? 0.06 : 0.05),
          lightIntensity: isDark ? 0.45 : 0.6,
          ambientStrength: isDark ? 0.04 : 0.03,
          refractiveIndex: 1.2,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.64),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

final BorderRadius _dropdownPopupRadius = BorderRadius.circular(18);

Color _dropdownPopupColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const Color(0xFF171D29).withValues(alpha: 0.96)
      : const Color(0xFFF7FAFF).withValues(alpha: 0.97);
}

Future<String?> _showTextInputDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required String label,
}) {
  var value = initial;
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        initialValue: initial,
        decoration: InputDecoration(labelText: label),
        onChanged: (next) => value = next,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppLocalizations.of(dialogContext)!.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(value),
          child: Text(AppLocalizations.of(dialogContext)!.save),
        ),
      ],
    ),
  );
}
