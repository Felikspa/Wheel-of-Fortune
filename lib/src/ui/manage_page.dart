import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../services/wheel_codec.dart';
import '../state/app_controller.dart';
import 'palette_tokens.dart';
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
        final accentColor = paletteAccentColor(
          wheel?.palette ?? 'random',
          isDark,
        );
        final colorlessGlass = wheel?.palette == 'transparent';
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            _SectionTitle(
              icon: Icons.layers_outlined,
              title: l10n.wheels,
              accentColor: accentColor,
            ),
            const SizedBox(height: 8),
            _FrostedPanel(
              accentColor: accentColor,
              colorlessGlass: colorlessGlass,
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
                          selectedColor: accentColor.withValues(
                            alpha: isDark ? 0.26 : 0.2,
                          ),
                          side: BorderSide(
                            color: entry.id == controller.selectedWheelId
                                ? accentColor.withValues(
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
            _SectionTitle(
              icon: Icons.bolt_rounded,
              title: l10n.tabManage,
              accentColor: accentColor,
            ),
            const SizedBox(height: 8),
            _FrostedPanel(
              accentColor: accentColor,
              colorlessGlass: colorlessGlass,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.addWheel,
                          accentColor: accentColor,
                          onPressed: () => _addWheel(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: l10n.deleteWheel,
                          accentColor: accentColor,
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
                          accentColor: accentColor,
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
                          accentColor: accentColor,
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
              _WheelSettingsCard(wheel: wheel, accentColor: accentColor),
              const SizedBox(height: 16),
              _ItemsCard(wheel: wheel, accentColor: accentColor),
              const SizedBox(height: 16),
            ],
            _AppSettingsCard(
              accentColor: accentColor,
              colorlessGlass: colorlessGlass,
            ),
            const SizedBox(height: 22),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: _LoveSignatureGlass(
                  accentColor: accentColor,
                  colorlessGlass: colorlessGlass,
                ),
              ),
            ),
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
  const _WheelSettingsCard({required this.wheel, required this.accentColor});

  final WheelModel wheel;
  final Color accentColor;

  @override
  State<_WheelSettingsCard> createState() => _WheelSettingsCardState();
}

class _WheelSettingsCardState extends State<_WheelSettingsCard> {
  late double _spinDuration;
  late double _backgroundOpacity;
  late double _backgroundBlur;
  bool _isDraggingDuration = false;
  bool _isDraggingBackgroundOpacity = false;
  bool _isDraggingBackgroundBlur = false;

  @override
  void initState() {
    super.initState();
    _spinDuration = widget.wheel.spinDurationMs.toDouble();
    final settings = context.read<AppController>().settings;
    _backgroundOpacity = settings.globalBackgroundImageOpacity;
    _backgroundBlur = settings.globalBackgroundImageBlurSigma;
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
    final settings = context.read<AppController>().settings;
    if (!_isDraggingBackgroundOpacity) {
      _backgroundOpacity = settings.globalBackgroundImageOpacity;
    }
    if (!_isDraggingBackgroundBlur) {
      _backgroundBlur = settings.globalBackgroundImageBlurSigma;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AppController>();
    final settings = controller.settings;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final randomPaletteLabel = isZh ? '随机' : 'Random';
    final pinkPaletteLabel = isZh ? '樱粉' : 'Pink';
    final transparentPaletteLabel = isZh ? '透明' : 'Transparent';
    final backgroundImageLabel = isZh ? '全局背景图' : 'Global Background Image';
    final enableBackgroundLabel = isZh ? '启用背景图' : 'Enable Background';
    final chooseImageLabel = isZh ? '选择图片' : 'Choose Image';
    final changeImageLabel = isZh ? '更换图片' : 'Change Image';
    final clearImageLabel = isZh ? '清除图片' : 'Clear Image';
    final opacityLabel = isZh ? '透明度' : 'Opacity';
    final blurLabel = isZh ? '模糊度' : 'Blur';
    final backgroundImagePath = settings.globalBackgroundImagePath;
    final hasBackgroundImage = backgroundImagePath != null;
    final backgroundEnabled =
        hasBackgroundImage && settings.globalBackgroundImageEnabled;
    final paletteOptions = <String, String>{
      'random': randomPaletteLabel,
      'ocean': l10n.paletteOcean,
      'sunset': l10n.paletteSunset,
      'mint': l10n.paletteMint,
      'mono': l10n.paletteMono,
      'pink': pinkPaletteLabel,
      'transparent': transparentPaletteLabel,
    };
    final colorlessGlass = widget.wheel.palette == 'transparent';

    return _FrostedPanel(
      accentColor: widget.accentColor,
      colorlessGlass: colorlessGlass,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.settings_suggest_outlined,
            title: l10n.currentWheelSettings,
            accentColor: widget.accentColor,
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
            dropdownColor: _dropdownPopupColor(
              context,
              accentColor: widget.accentColor,
            ),
            iconEnabledColor: widget.accentColor,
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
            activeColor: widget.accentColor,
            inactiveColor: widget.accentColor.withValues(
              alpha: isDark ? 0.26 : 0.24,
            ),
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
            dropdownColor: _dropdownPopupColor(
              context,
              accentColor: widget.accentColor,
            ),
            iconEnabledColor: widget.accentColor,
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
          const SizedBox(height: 12),
          Text(
            backgroundImageLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickBackgroundImage(controller),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    hasBackgroundImage ? changeImageLabel : chooseImageLabel,
                  ),
                ),
              ),
              if (hasBackgroundImage) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _clearBackgroundImage(controller),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(clearImageLabel),
                  ),
                ),
              ],
            ],
          ),
          if (hasBackgroundImage) ...[
            const SizedBox(height: 8),
            Text(
              _basename(backgroundImagePath),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: backgroundEnabled,
              title: Text(enableBackgroundLabel),
              activeThumbColor: widget.accentColor,
              activeTrackColor: widget.accentColor.withValues(
                alpha: isDark ? 0.4 : 0.28,
              ),
              onChanged: (value) async {
                await controller.updateGlobalBackgroundConfig(enabled: value);
              },
            ),
            Text('$opacityLabel: ${_backgroundOpacity.toStringAsFixed(2)}'),
            Slider(
              value: _backgroundOpacity.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              divisions: 20,
              activeColor: widget.accentColor,
              inactiveColor: widget.accentColor.withValues(
                alpha: isDark ? 0.26 : 0.24,
              ),
              onChanged: (value) {
                setState(() {
                  _backgroundOpacity = value;
                  _isDraggingBackgroundOpacity = true;
                });
              },
              onChangeEnd: (value) async {
                _isDraggingBackgroundOpacity = false;
                await controller.updateGlobalBackgroundConfig(opacity: value);
              },
            ),
            Text('$blurLabel: ${_backgroundBlur.toStringAsFixed(1)}'),
            Slider(
              value: _backgroundBlur.clamp(0.0, 24.0),
              min: 0,
              max: 24,
              divisions: 24,
              activeColor: widget.accentColor,
              inactiveColor: widget.accentColor.withValues(
                alpha: isDark ? 0.26 : 0.24,
              ),
              onChanged: (value) {
                setState(() {
                  _backgroundBlur = value;
                  _isDraggingBackgroundBlur = true;
                });
              },
              onChangeEnd: (value) async {
                _isDraggingBackgroundBlur = false;
                await controller.updateGlobalBackgroundConfig(blurSigma: value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickBackgroundImage(AppController controller) async {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final picked = result.files.first;
      final ext = _resolveExtensionFromName(picked.name);
      final directory = await getApplicationDocumentsDirectory();
      final backgroundsDir = Directory('${directory.path}/wheel_backgrounds');
      if (!backgroundsDir.existsSync()) {
        await backgroundsDir.create(recursive: true);
      }
      final target = File(
        '${backgroundsDir.path}/global_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      final sourcePath = picked.path;
      if (sourcePath != null && sourcePath.isNotEmpty) {
        final sourceFile = File(sourcePath);
        if (sourceFile.existsSync()) {
          await sourceFile.copy(target.path);
        } else if (picked.bytes != null) {
          await target.writeAsBytes(picked.bytes!, flush: true);
        } else {
          throw StateError('Selected image path does not exist.');
        }
      } else if (picked.bytes != null) {
        await target.writeAsBytes(picked.bytes!, flush: true);
      } else {
        throw StateError('No image bytes available from picker.');
      }
      final previous = controller.settings.globalBackgroundImagePath;
      if (previous != null && previous != target.path) {
        final oldFile = File(previous);
        if (oldFile.existsSync()) {
          await oldFile.delete();
        }
      }
      await controller.updateGlobalBackgroundConfig(
        backgroundImagePath: target.path,
        enabled: true,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isZh ? '全局背景图已应用' : 'Global background image applied'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = isZh
          ? '设置背景图失败: $error'
          : 'Failed to apply background image: $error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _clearBackgroundImage(AppController controller) async {
    final previous = controller.settings.globalBackgroundImagePath;
    if (previous != null) {
      final oldFile = File(previous);
      if (oldFile.existsSync()) {
        await oldFile.delete();
      }
    }
    await controller.updateGlobalBackgroundConfig(
      clearBackgroundImagePath: true,
      enabled: false,
    );
  }

  String _resolveExtensionFromName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) {
      return 'jpg';
    }
    final ext = fileName.substring(dot + 1).trim().toLowerCase();
    if (ext.isNotEmpty) {
      return ext;
    }
    return 'jpg';
  }

  String _basename(String path) {
    final slash = path.lastIndexOf(RegExp(r'[\\/]'));
    if (slash < 0 || slash >= path.length - 1) {
      return path;
    }
    return path.substring(slash + 1);
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.wheel, required this.accentColor});

  final WheelModel wheel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemSurface = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.11 : 0.07),
      theme.colorScheme.surface.withValues(alpha: isDark ? 0.32 : 0.56),
    );
    final itemBorder = accentColor.withValues(alpha: isDark ? 0.34 : 0.24);
    final colorlessGlass = wheel.palette == 'transparent';
    return _FrostedPanel(
      accentColor: accentColor,
      colorlessGlass: colorlessGlass,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PanelHeader(
                icon: Icons.list_alt_rounded,
                title: l10n.items,
                accentColor: accentColor,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _quickImportItems(context),
                icon: Icon(
                  Icons.playlist_add_outlined,
                  color: accentColor.withValues(alpha: isDark ? 0.92 : 0.86),
                ),
                tooltip: l10n.quickImportItems,
              ),
              IconButton(
                onPressed: () => _addItem(context),
                icon: Icon(
                  Icons.add,
                  color: accentColor.withValues(alpha: isDark ? 0.92 : 0.86),
                ),
                tooltip: l10n.addItem,
              ),
            ],
          ),
          SizedBox(
            height: 320,
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: itemSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: itemBorder),
                  ),
                  child: child,
                ),
              ),
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
                    color: itemSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: itemBorder),
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
                      child: Icon(
                        Icons.drag_indicator,
                        color: accentColor.withValues(
                          alpha: isDark ? 0.82 : 0.72,
                        ),
                      ),
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
  const _AppSettingsCard({
    required this.accentColor,
    this.colorlessGlass = false,
  });

  final Color accentColor;
  final bool colorlessGlass;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final settings = controller.settings;
        return _FrostedPanel(
          accentColor: accentColor,
          colorlessGlass: colorlessGlass,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(
                icon: Icons.phone_iphone_rounded,
                title: l10n.appSettings,
                accentColor: accentColor,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                key: ValueKey('locale-${settings.localeOverride ?? 'system'}'),
                initialValue: settings.localeOverride,
                isExpanded: true,
                menuMaxHeight: 320,
                borderRadius: _dropdownPopupRadius,
                dropdownColor: _dropdownPopupColor(
                  context,
                  accentColor: accentColor,
                ),
                iconEnabledColor: accentColor,
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
                dropdownColor: _dropdownPopupColor(
                  context,
                  accentColor: accentColor,
                ),
                iconEnabledColor: accentColor,
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
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = Theme.of(context).textTheme.titleMedium?.color;
    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Color.lerp(defaultTextColor, accentColor, 0.45),
          ),
        ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = Theme.of(context).textTheme.titleMedium?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Color.lerp(defaultTextColor, accentColor, 0.42),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onPressed != null;
    final bgColor = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
      theme.colorScheme.surface.withValues(alpha: isDark ? 0.32 : 0.56),
    );
    final borderColor = accentColor.withValues(alpha: isDark ? 0.34 : 0.24);
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
                  Icon(
                    icon,
                    size: 19,
                    color: Color.lerp(
                      fgColor,
                      accentColor,
                      enabled ? (isDark ? 0.28 : 0.34) : 0.18,
                    ),
                  ),
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

class _LoveSignatureGlass extends StatelessWidget {
  const _LoveSignatureGlass({
    required this.accentColor,
    this.colorlessGlass = false,
  });

  final Color accentColor;
  final bool colorlessGlass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final usesPremiumPipeline =
        !kIsWeb && ui.ImageFilter.isShaderFilterSupported;
    final textColor =
        theme.textTheme.labelLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    return LiquidStretch(
      interactionScale: 2,
      stretch: 0.3,
      resistance: 0.003,
      hitTestBehavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 42,
        child: LiquidGlassChrome(
          borderRadius: 0,
          accentColor: accentColor,
          isDark: isDark,
          colorless: colorlessGlass,
          shadowStrength: 1.0,
          highlightStrength: 1.0,
          child: GlassButton.custom(
            onTap: () {},
            enabled: true,
            label: 'LJX & HLY',
            width: double.infinity,
            height: 42,
            useOwnLayer: true,
            quality: GlassQuality.premium,
            shape: const LiquidRoundedRectangle(borderRadius: 0.01),
            settings: LiquidGlassSettings(
              thickness: isDark ? 48 : 50,
              blur: 0,
              glassColor: colorlessGlass
                  ? Colors.transparent
                  : Color.lerp(
                      accentColor,
                      const Color(0xFFEAF6FF),
                      isDark ? 0.72 : 0.6,
                    )!.withValues(alpha: isDark ? 0.06 : 0.055),
              lightAngle: usesPremiumPipeline
                  ? (isDark ? 2.18 : 2.12)
                  : (isDark ? 125.0 : 121.5),
              lightIntensity: colorlessGlass ? 0 : (isDark ? 0.42 : 0.84),
              ambientStrength: colorlessGlass ? 0 : (isDark ? 0.016 : 0.042),
              refractiveIndex: 1.86,
              saturation: 1.1,
              chromaticAberration: 0.012,
            ),
            interactionScale: 1.0,
            stretch: 0,
            resistance: 0.05,
            glowColor: colorlessGlass
                ? Colors.white.withValues(alpha: 0)
                : accentColor.withValues(alpha: isDark ? 0.035 : 0.03),
            glowRadius: 1.08,
            style: GlassButtonStyle.filled,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _GemFacetRefractionOverlays(
                  accentColor: accentColor,
                  isDark: isDark,
                  colorlessGlass: colorlessGlass,
                ),
                CustomPaint(
                  painter: _LoveSignatureGemPainter(
                    accentColor: accentColor,
                    isDark: isDark,
                    colorlessGlass: colorlessGlass,
                  ),
                  child: const SizedBox.expand(),
                ),
                Center(
                  child: _GemTableEngravedLabel(
                    text: 'LJX & HLY',
                    textColor: textColor,
                    accentColor: accentColor,
                    isDark: isDark,
                    colorlessGlass: colorlessGlass,
                    baseStyle: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _GemFacetKind { top, left, bottom, right, table }

class _GemTableEngravedLabel extends StatelessWidget {
  const _GemTableEngravedLabel({
    required this.text,
    required this.textColor,
    required this.accentColor,
    required this.isDark,
    required this.colorlessGlass,
    this.baseStyle,
  });

  final String text;
  final Color textColor;
  final Color accentColor;
  final bool isDark;
  final bool colorlessGlass;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final mainColor = Color.lerp(
      textColor.withValues(alpha: isDark ? 0.28 : 0.34),
      colorlessGlass
          ? Colors.white.withValues(alpha: 0.2)
          : accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
      0.36,
    )!;

    final highlightColor = Colors.white.withValues(alpha: isDark ? 0.28 : 0.34);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.28 : 0.2);

    final labelStyle = baseStyle?.copyWith(
      color: mainColor,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.45,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -0.35),
          child: Text(text, style: labelStyle?.copyWith(color: highlightColor)),
        ),
        Transform.translate(
          offset: const Offset(0, 0.42),
          child: Text(text, style: labelStyle?.copyWith(color: shadowColor)),
        ),
        Text(text, style: labelStyle),
      ],
    );
  }
}

class _GemFacetRefractionOverlays extends StatelessWidget {
  const _GemFacetRefractionOverlays({
    required this.accentColor,
    required this.isDark,
    required this.colorlessGlass,
  });

  final Color accentColor;
  final bool isDark;
  final bool colorlessGlass;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _GemFacetRefractionRegion(
            kind: _GemFacetKind.top,
            accentColor: accentColor,
            isDark: isDark,
            colorlessGlass: colorlessGlass,
          ),
          _GemFacetRefractionRegion(
            kind: _GemFacetKind.left,
            accentColor: accentColor,
            isDark: isDark,
            colorlessGlass: colorlessGlass,
          ),
          _GemFacetRefractionRegion(
            kind: _GemFacetKind.bottom,
            accentColor: accentColor,
            isDark: isDark,
            colorlessGlass: colorlessGlass,
          ),
          _GemFacetRefractionRegion(
            kind: _GemFacetKind.right,
            accentColor: accentColor,
            isDark: isDark,
            colorlessGlass: colorlessGlass,
          ),
          _GemFacetRefractionRegion(
            kind: _GemFacetKind.table,
            accentColor: accentColor,
            isDark: isDark,
            colorlessGlass: colorlessGlass,
          ),
        ],
      ),
    );
  }
}

class _GemFacetRefractionRegion extends StatelessWidget {
  const _GemFacetRefractionRegion({
    required this.kind,
    required this.accentColor,
    required this.isDark,
    required this.colorlessGlass,
  });

  final _GemFacetKind kind;
  final Color accentColor;
  final bool isDark;
  final bool colorlessGlass;

  @override
  Widget build(BuildContext context) {
    final highlightTint = colorlessGlass
        ? Colors.transparent
        : Color.lerp(accentColor, const Color(0xFFEAF6FF), 0.78)!;

    LiquidGlassSettings settingsForFacet() {
      return switch (kind) {
        _GemFacetKind.top => LiquidGlassSettings(
          thickness: isDark ? 52 : 54,
          blur: 0,
          glassColor: highlightTint.withValues(alpha: isDark ? 0.012 : 0.01),
          lightAngle: isDark ? 116.0 : 122.0,
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.2 : 0.32),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.008 : 0.014),
          refractiveIndex: 2.12,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        _GemFacetKind.left => LiquidGlassSettings(
          thickness: isDark ? 50 : 52,
          blur: 0,
          glassColor: highlightTint.withValues(alpha: isDark ? 0.01 : 0.008),
          lightAngle: isDark ? 178.0 : 184.0,
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.18 : 0.28),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.006 : 0.012),
          refractiveIndex: 1.9,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        _GemFacetKind.bottom => LiquidGlassSettings(
          thickness: isDark ? 51 : 53,
          blur: 0,
          glassColor: highlightTint.withValues(alpha: isDark ? 0.009 : 0.008),
          lightAngle: isDark ? 252.0 : 258.0,
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.16 : 0.26),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.006 : 0.012),
          refractiveIndex: 2.02,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        _GemFacetKind.right => LiquidGlassSettings(
          thickness: isDark ? 50 : 52,
          blur: 0,
          glassColor: highlightTint.withValues(alpha: isDark ? 0.012 : 0.01),
          lightAngle: isDark ? 340.0 : 346.0,
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.18 : 0.3),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.006 : 0.012),
          refractiveIndex: 2.14,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        _GemFacetKind.table => LiquidGlassSettings(
          thickness: isDark ? 49 : 51,
          blur: 0,
          glassColor: highlightTint.withValues(alpha: isDark ? 0.01 : 0.009),
          lightAngle: isDark ? 128.0 : 134.0,
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.17 : 0.27),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.007 : 0.013),
          refractiveIndex: 1.98,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
      };
    }

    return ClipPath(
      clipper: _GemFacetClipper(kind: kind),
      clipBehavior: Clip.hardEdge,
      child: RepaintBoundary(
        child: AdaptiveGlass(
          shape: const LiquidRoundedRectangle(borderRadius: 0.01),
          settings: settingsForFacet(),
          quality: GlassQuality.standard,
          useOwnLayer: true,
          clipBehavior: Clip.hardEdge,
          allowElevation: false,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GemFacetClipper extends CustomClipper<Path> {
  const _GemFacetClipper({required this.kind});

  final _GemFacetKind kind;

  @override
  Path getClip(Size size) {
    final outer = _GemFacetGeometry.outerRect(size);
    final inner = _GemFacetGeometry.innerRect(outer);
    return switch (kind) {
      _GemFacetKind.top => _GemFacetGeometry.topFacetPath(outer, inner),
      _GemFacetKind.left => _GemFacetGeometry.leftFacetPath(outer, inner),
      _GemFacetKind.bottom => _GemFacetGeometry.bottomFacetPath(outer, inner),
      _GemFacetKind.right => _GemFacetGeometry.rightFacetPath(outer, inner),
      _GemFacetKind.table => _GemFacetGeometry.tablePath(inner),
    };
  }

  @override
  bool shouldReclip(covariant _GemFacetClipper oldClipper) {
    return oldClipper.kind != kind;
  }
}

final class _GemFacetGeometry {
  const _GemFacetGeometry._();

  static Rect outerRect(Size size) {
    return (Offset.zero & size).deflate(0.9);
  }

  static Rect innerRect(Rect outer) {
    return Rect.fromCenter(
      center: outer.center,
      width: outer.width * 0.85,
      height: outer.height * 0.46,
    );
  }

  static Path tablePath(Rect inner) {
    return Path()..addRect(inner);
  }

  static Path topFacetPath(Rect outer, Rect inner) {
    return Path()
      ..moveTo(outer.left, outer.top)
      ..lineTo(outer.right, outer.top)
      ..lineTo(inner.right, inner.top)
      ..lineTo(inner.left, inner.top)
      ..close();
  }

  static Path bottomFacetPath(Rect outer, Rect inner) {
    return Path()
      ..moveTo(inner.left, inner.bottom)
      ..lineTo(inner.right, inner.bottom)
      ..lineTo(outer.right, outer.bottom)
      ..lineTo(outer.left, outer.bottom)
      ..close();
  }

  static Path leftFacetPath(Rect outer, Rect inner) {
    return Path()
      ..moveTo(outer.left, outer.top)
      ..lineTo(inner.left, inner.top)
      ..lineTo(inner.left, inner.bottom)
      ..lineTo(outer.left, outer.bottom)
      ..close();
  }

  static Path rightFacetPath(Rect outer, Rect inner) {
    return Path()
      ..moveTo(inner.right, inner.top)
      ..lineTo(outer.right, outer.top)
      ..lineTo(outer.right, outer.bottom)
      ..lineTo(inner.right, inner.bottom)
      ..close();
  }
}

class _LoveSignatureGemPainter extends CustomPainter {
  const _LoveSignatureGemPainter({
    required this.accentColor,
    required this.isDark,
    required this.colorlessGlass,
  });

  final Color accentColor;
  final bool isDark;
  final bool colorlessGlass;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final outer = _GemFacetGeometry.outerRect(size);
    final inner = _GemFacetGeometry.innerRect(outer);
    final leftFacetPath = _GemFacetGeometry.leftFacetPath(outer, inner);
    final rightFacetPath = _GemFacetGeometry.rightFacetPath(outer, inner);
    final leftFacetBounds = leftFacetPath.getBounds();
    final rightFacetBounds = rightFacetPath.getBounds();

    final brightEdge = Colors.white.withValues(alpha: isDark ? 0.34 : 0.42);
    final coolEdge =
        (colorlessGlass
                ? const Color(0xFF9AB7DC)
                : Color.lerp(accentColor, const Color(0xFFAEDFFF), 0.45)!)
            .withValues(alpha: isDark ? 0.22 : 0.2);
    final darkEdge = Colors.black.withValues(alpha: isDark ? 0.16 : 0.1);

    final topFacetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          brightEdge.withValues(alpha: brightEdge.a * 0.26),
          coolEdge.withValues(alpha: coolEdge.a * 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(outer);

    final leftFacetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -0.18),
        end: const Alignment(1.0, 0.18),
        colors: [
          darkEdge.withValues(alpha: darkEdge.a * 0.52),
          darkEdge.withValues(alpha: darkEdge.a * 0.36),
          darkEdge.withValues(alpha: darkEdge.a * 0.22),
        ],
        stops: const [0.0, 0.56, 1.0],
      ).createShader(leftFacetBounds);

    final rightFacetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -0.2),
        end: const Alignment(1.0, 0.2),
        colors: [
          coolEdge.withValues(alpha: coolEdge.a * 0.18),
          coolEdge.withValues(alpha: coolEdge.a * 0.28),
          coolEdge.withValues(alpha: coolEdge.a * 0.36),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(rightFacetBounds);

    final bottomFacetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          coolEdge.withValues(alpha: coolEdge.a * 0.1),
          darkEdge.withValues(alpha: darkEdge.a * 0.16),
          darkEdge.withValues(alpha: darkEdge.a * 0.36),
        ],
        stops: const [0.18, 0.5, 0.72, 1.0],
      ).createShader(outer);

    final tableFacetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          brightEdge.withValues(alpha: brightEdge.a * 0.18),
          Colors.transparent,
          coolEdge.withValues(alpha: coolEdge.a * 0.16),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(inner);

    canvas.drawPath(
      _GemFacetGeometry.topFacetPath(outer, inner),
      topFacetPaint,
    );

    canvas.drawPath(leftFacetPath, leftFacetPaint);

    canvas.drawPath(rightFacetPath, rightFacetPaint);

    canvas.drawPath(
      _GemFacetGeometry.bottomFacetPath(outer, inner),
      bottomFacetPaint,
    );

    canvas.drawPath(_GemFacetGeometry.tablePath(inner), tableFacetPaint);

    final specularBandPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          brightEdge.withValues(alpha: brightEdge.a * 0.16),
          brightEdge.withValues(alpha: brightEdge.a * 0.1),
          brightEdge.withValues(alpha: brightEdge.a * 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.34, 0.7, 1.0],
      ).createShader(outer);

    canvas.save();
    canvas.clipRect(outer);
    canvas.drawPath(
      Path()
        ..moveTo(
          outer.left + outer.width * 0.08,
          outer.top + outer.height * 0.06,
        )
        ..lineTo(
          outer.left + outer.width * 0.54,
          outer.top + outer.height * 0.06,
        )
        ..lineTo(
          outer.left + outer.width * 0.34,
          outer.top + outer.height * 0.46,
        )
        ..lineTo(
          outer.left - outer.width * 0.02,
          outer.top + outer.height * 0.46,
        )
        ..close(),
      specularBandPaint,
    );
    canvas.restore();

    final outerTopStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.12
      ..color = brightEdge.withValues(alpha: brightEdge.a * 0.96);
    final outerLeftStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.06
      ..color = coolEdge.withValues(alpha: coolEdge.a * 0.92);
    final outerRightStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.02
      ..color = darkEdge.withValues(alpha: darkEdge.a * 0.84);
    final outerBottomStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.04
      ..color = darkEdge;

    final innerTopStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.02
      ..color = brightEdge.withValues(alpha: brightEdge.a * 0.9);
    final innerLeftStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.98
      ..color = coolEdge.withValues(alpha: coolEdge.a * 0.92);
    final innerRightStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.96
      ..color = darkEdge.withValues(alpha: darkEdge.a * 0.82);
    final innerBottomStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.98
      ..color = darkEdge;

    final connectorTopLeftStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 1.02
      ..color = brightEdge.withValues(alpha: brightEdge.a * 0.96);
    final connectorTopRightStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 1.0
      ..color = coolEdge.withValues(alpha: coolEdge.a * 0.9);
    final connectorBottomRightStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 0.98
      ..color = darkEdge.withValues(alpha: darkEdge.a * 0.82);
    final connectorBottomLeftStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 0.98
      ..color = darkEdge.withValues(alpha: darkEdge.a * 0.8);

    canvas.drawLine(outer.topLeft, outer.topRight, outerTopStroke);
    canvas.drawLine(outer.topLeft, outer.bottomLeft, outerLeftStroke);
    canvas.drawLine(outer.topRight, outer.bottomRight, outerRightStroke);
    canvas.drawLine(outer.bottomLeft, outer.bottomRight, outerBottomStroke);

    canvas.drawLine(inner.topLeft, inner.topRight, innerTopStroke);
    canvas.drawLine(inner.topLeft, inner.bottomLeft, innerLeftStroke);
    canvas.drawLine(inner.topRight, inner.bottomRight, innerRightStroke);
    canvas.drawLine(inner.bottomLeft, inner.bottomRight, innerBottomStroke);

    canvas.drawLine(outer.topLeft, inner.topLeft, connectorTopLeftStroke);
    canvas.drawLine(outer.topRight, inner.topRight, connectorTopRightStroke);
    canvas.drawLine(
      outer.bottomRight,
      inner.bottomRight,
      connectorBottomRightStroke,
    );
    canvas.drawLine(
      outer.bottomLeft,
      inner.bottomLeft,
      connectorBottomLeftStroke,
    );
  }

  @override
  bool shouldRepaint(covariant _LoveSignatureGemPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.colorlessGlass != colorlessGlass;
  }
}

class _FrostedPanel extends StatelessWidget {
  const _FrostedPanel({
    required this.child,
    required this.accentColor,
    this.colorlessGlass = false,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final Color accentColor;
  final bool colorlessGlass;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return LiquidGlassChrome(
      borderRadius: 22,
      accentColor: accentColor,
      isDark: isDark,
      colorless: colorlessGlass,
      shadowStrength: 0.9,
      highlightStrength: 0.92,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 20 : 18,
          glassColor: colorlessGlass
              ? Colors.transparent
              : accentColor.withValues(alpha: isDark ? 0.06 : 0.05),
          lightIntensity: colorlessGlass ? 0 : (isDark ? 0.45 : 0.6),
          ambientStrength: colorlessGlass ? 0 : (isDark ? 0.04 : 0.03),
          refractiveIndex: 1.2,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorlessGlass
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.1))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.64)),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

final BorderRadius _dropdownPopupRadius = BorderRadius.circular(18);

Color _dropdownPopupColor(BuildContext context, {required Color accentColor}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Color.alphaBlend(
          accentColor.withValues(alpha: 0.14),
          const Color(0xFF171D29).withValues(alpha: 0.96),
        )
      : Color.alphaBlend(
          accentColor.withValues(alpha: 0.08),
          const Color(0xFFF7FAFF).withValues(alpha: 0.97),
        );
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
