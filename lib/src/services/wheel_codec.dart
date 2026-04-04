import '../domain/models.dart';

enum DslFormat { csv, pipe }

enum WheelImportErrorCode {
  missingTitle,
  tooManyFields,
  invalidColor,
  invalidWeight,
  invalidHeader,
}

class WheelImportError {
  const WheelImportError({required this.line, required this.code, this.value});

  final int line;
  final WheelImportErrorCode code;
  final String? value;
}

class WheelImportResult {
  const WheelImportResult({
    required this.name,
    required this.probabilityMode,
    required this.spinDurationMs,
    required this.palette,
    required this.items,
    required this.errors,
    required this.format,
  });

  final String name;
  final ProbabilityMode probabilityMode;
  final int spinDurationMs;
  final String palette;
  final List<WheelItemModel> items;
  final List<WheelImportError> errors;
  final DslFormat format;
}

class QuickItemsImportResult {
  const QuickItemsImportResult({required this.items, required this.errors});

  final List<WheelItemModel> items;
  final List<WheelImportError> errors;
}

class WheelCodec {
  static final RegExp _hexPattern = RegExp(
    r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  );
  static const _fieldLimit = 6;

  String exportWheel(WheelModel wheel, {DslFormat format = DslFormat.csv}) {
    final delimiter = format == DslFormat.csv ? ',' : '|';
    final lines = <String>[
      '@format:${format.name}',
      '@name:${_escapeHeader(wheel.name)}',
      '@mode:${wheel.probabilityMode.name}',
      '@spinDurationMs:${wheel.spinDurationMs}',
      '@palette:${wheel.palette}',
      '',
    ];

    final itemLines = wheel.items.map((item) {
      final fields = <String>[
        item.title,
        item.subtitle ?? '',
        item.tags ?? '',
        item.note ?? '',
        item.colorHex ?? '',
        item.weight?.toString() ?? '',
      ];
      while (fields.isNotEmpty && fields.last.isEmpty) {
        fields.removeLast();
      }
      return fields
          .map((value) => _escapeField(value, delimiter))
          .join(delimiter);
    }).toList();

    if (format == DslFormat.csv) {
      lines.add(itemLines.map((line) => '$line;').join('\n'));
    } else {
      lines.addAll(itemLines);
    }

    return lines.join('\n');
  }

  WheelImportResult importWheel(String input) {
    final normalized = input.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const WheelImportResult(
        name: 'Imported Wheel',
        probabilityMode: ProbabilityMode.equal,
        spinDurationMs: 4800,
        palette: 'random',
        items: [],
        errors: [],
        format: DslFormat.csv,
      );
    }

    final lines = normalized.split('\n');
    final headers = <String, String>{};
    final bodyLines = <_Line>[];
    final errors = <WheelImportError>[];

    for (var index = 0; index < lines.length; index++) {
      final raw = lines[index];
      final trimmed = raw.trim();
      final lineNumber = index + 1;
      if (trimmed.isEmpty) {
        continue;
      }
      if (trimmed.startsWith('@')) {
        final colon = trimmed.indexOf(':');
        if (colon <= 1 || colon == trimmed.length - 1) {
          errors.add(
            WheelImportError(
              line: lineNumber,
              code: WheelImportErrorCode.invalidHeader,
              value: trimmed,
            ),
          );
          continue;
        }
        final key = trimmed.substring(1, colon).trim().toLowerCase();
        final value = trimmed.substring(colon + 1).trim();
        headers[key] = _unescapeHeader(value);
        continue;
      }
      bodyLines.add(_Line(number: lineNumber, text: raw));
    }

    final format = _resolveFormat(headers['format'], bodyLines);
    final name = headers['name']?.trim().isNotEmpty == true
        ? headers['name']!.trim()
        : 'Imported Wheel';
    final mode = headers['mode'] == 'weighted'
        ? ProbabilityMode.weighted
        : ProbabilityMode.equal;
    final spinDuration = int.tryParse(headers['spindurationms'] ?? '') ?? 4800;
    final palette = _resolvePalette(headers['palette']);

    final parsedItems = <WheelItemModel>[];
    if (format == DslFormat.csv) {
      final csvBody = bodyLines.map((line) => line.text).join('\n');
      final entries = _splitEntries(csvBody);
      for (final entry in entries) {
        if (entry.text.trim().isEmpty) {
          continue;
        }
        final fields = _splitFields(entry.text, ',');
        _parseItemFields(
          fields: fields.map((field) => field.trim()).toList(),
          line: entry.number,
          wheelItems: parsedItems,
          errors: errors,
        );
      }
    } else {
      for (final line in bodyLines) {
        final fields = _splitFields(line.text, '|');
        _parseItemFields(
          fields: fields.map((field) => field.trim()).toList(),
          line: line.number,
          wheelItems: parsedItems,
          errors: errors,
        );
      }
    }

    final orderedItems = [
      for (var i = 0; i < parsedItems.length; i++)
        parsedItems[i].copyWith(order: i),
    ];

    return WheelImportResult(
      name: name,
      probabilityMode: mode,
      spinDurationMs: spinDuration.clamp(1500, 15000),
      palette: palette,
      items: orderedItems,
      errors: errors,
      format: format,
    );
  }

  QuickItemsImportResult importQuickItems(String input) {
    final normalized = _normalizeQuickSyntax(
      input,
    ).replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const QuickItemsImportResult(items: [], errors: []);
    }

    final entries = _splitEntries(normalized);
    final errors = <WheelImportError>[];
    final items = <WheelItemModel>[];
    final schema = <String>[];

    for (final entry in entries) {
      final text = entry.text.trim();
      if (text.isEmpty) {
        continue;
      }
      final fields = _splitFields(
        text,
        ',',
      ).map((token) => token.trim()).toList();
      if (fields.isEmpty || fields.first.isEmpty) {
        errors.add(
          WheelImportError(
            line: entry.number,
            code: WheelImportErrorCode.missingTitle,
          ),
        );
        continue;
      }

      final title = fields.first;
      final values = <String, String>{};
      final extras = fields.length > 1 ? fields.sublist(1) : const <String>[];

      if (schema.isEmpty && extras.isNotEmpty) {
        for (var i = 0; i < extras.length; i++) {
          final token = extras[i];
          if (token.isEmpty) {
            continue;
          }
          final keyed = _parseKeyValue(token);
          if (keyed != null) {
            schema.add(keyed.$1);
            values[keyed.$1] = keyed.$2;
          } else {
            final fallbackKey = i == 0 ? 'subtitle' : 'extra${i + 1}';
            schema.add(fallbackKey);
            values[fallbackKey] = token;
          }
        }
      } else {
        for (var i = 0; i < extras.length; i++) {
          final token = extras[i];
          if (token.isEmpty) {
            continue;
          }
          final keyed = _parseKeyValue(token);
          if (keyed != null) {
            values[keyed.$1] = keyed.$2;
            if (i >= schema.length) {
              schema.add(keyed.$1);
            }
          } else {
            final mappedKey = i < schema.length ? schema[i] : 'extra${i + 1}';
            values[mappedKey] = token;
          }
        }
      }

      final built = _buildQuickItem(
        title: title,
        values: values,
        line: entry.number,
        errors: errors,
      );
      if (built != null) {
        items.add(built.copyWith(id: 0, wheelId: 0, order: items.length));
      }
    }

    return QuickItemsImportResult(items: items, errors: errors);
  }

  DslFormat _resolveFormat(String? explicitFormat, List<_Line> bodyLines) {
    final normalized = explicitFormat?.toLowerCase().trim();
    if (normalized == 'pipe') {
      return DslFormat.pipe;
    }
    if (normalized == 'csv') {
      return DslFormat.csv;
    }
    final nonEmpty = bodyLines
        .where((line) => line.text.trim().isNotEmpty)
        .toList();
    if (nonEmpty.isNotEmpty &&
        nonEmpty.every((line) => line.text.contains('|'))) {
      return DslFormat.pipe;
    }
    return DslFormat.csv;
  }

  String _resolvePalette(String? value) {
    const allowed = {'random', 'ocean', 'sunset', 'mint', 'mono'};
    final normalized = value?.trim().toLowerCase();
    if (normalized != null && allowed.contains(normalized)) {
      return normalized;
    }
    return 'random';
  }

  WheelItemModel? _buildQuickItem({
    required String title,
    required Map<String, String> values,
    required int line,
    required List<WheelImportError> errors,
  }) {
    const coreKnown = <String>{'subtitle', 'tags', 'note', 'color', 'weight'};

    final subtitle = _normalizeNullable(
      values['subtitle'] ?? values['site'] ?? '',
    );
    final tags = _normalizeNullable(values['tags'] ?? '');

    String? note = _normalizeNullable(values['note'] ?? '');

    String? colorHex;
    if (values.containsKey('color')) {
      colorHex = _normalizeColor(values['color']!);
      if (colorHex == null && values['color']!.trim().isNotEmpty) {
        note = _appendNote(note, 'color:${values['color']!.trim()}');
      }
    }

    double? weight;
    final rawWeight = values['weight'];
    if (rawWeight != null && rawWeight.trim().isNotEmpty) {
      weight = double.tryParse(rawWeight.trim());
      if (weight == null || weight <= 0) {
        errors.add(
          WheelImportError(
            line: line,
            code: WheelImportErrorCode.invalidWeight,
            value: rawWeight,
          ),
        );
        return null;
      }
    }

    final customFields = <String, String>{};
    for (final entry in values.entries) {
      if (!coreKnown.contains(entry.key)) {
        final cleanedValue = entry.value.trim();
        if (cleanedValue.isNotEmpty) {
          customFields[entry.key] = cleanedValue;
        }
      }
    }

    return WheelItemModel(
      id: 0,
      wheelId: 0,
      order: 0,
      title: title,
      subtitle: subtitle,
      tags: tags,
      note: note,
      colorHex: colorHex,
      weight: weight,
      customFields: customFields,
    );
  }

  void _parseItemFields({
    required List<String> fields,
    required int line,
    required List<WheelItemModel> wheelItems,
    required List<WheelImportError> errors,
  }) {
    if (fields.length > _fieldLimit) {
      errors.add(
        WheelImportError(line: line, code: WheelImportErrorCode.tooManyFields),
      );
      return;
    }
    final padded = [...fields];
    while (padded.length < _fieldLimit) {
      padded.add('');
    }
    final title = padded[0].trim();
    if (title.isEmpty) {
      errors.add(
        WheelImportError(line: line, code: WheelImportErrorCode.missingTitle),
      );
      return;
    }

    final colorHex = padded[4].trim();
    if (colorHex.isNotEmpty && !_hexPattern.hasMatch(colorHex)) {
      errors.add(
        WheelImportError(
          line: line,
          code: WheelImportErrorCode.invalidColor,
          value: colorHex,
        ),
      );
      return;
    }

    final weightString = padded[5].trim();
    double? weight;
    if (weightString.isNotEmpty) {
      weight = double.tryParse(weightString);
      if (weight == null || weight <= 0) {
        errors.add(
          WheelImportError(
            line: line,
            code: WheelImportErrorCode.invalidWeight,
            value: weightString,
          ),
        );
        return;
      }
    }

    wheelItems.add(
      WheelItemModel(
        id: 0,
        wheelId: 0,
        order: wheelItems.length,
        title: title,
        subtitle: _normalizeNullable(padded[1]),
        tags: _normalizeNullable(padded[2]),
        note: _normalizeNullable(padded[3]),
        colorHex: _normalizeNullable(colorHex),
        weight: weight,
      ),
    );
  }

  List<String> _splitFields(String line, String delimiter) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var escape = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (escape) {
        buffer.write(char);
        escape = false;
        continue;
      }
      if (char == r'\') {
        escape = true;
        continue;
      }
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && char == delimiter) {
        values.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    values.add(buffer.toString());
    return values;
  }

  List<_Line> _splitEntries(String value) {
    final entries = <_Line>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var escape = false;
    var line = 1;
    var startLine = 1;

    void flushEntry() {
      entries.add(_Line(number: startLine, text: buffer.toString()));
      buffer.clear();
    }

    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (escape) {
        buffer.write(char);
        escape = false;
        continue;
      }
      if (char == r'\') {
        escape = true;
        buffer.write(char);
        continue;
      }
      if (char == '"') {
        inQuotes = !inQuotes;
        buffer.write(char);
        continue;
      }
      if (!inQuotes && (char == ';' || char == '\n')) {
        flushEntry();
        if (char == '\n') {
          line++;
          startLine = line;
        } else {
          startLine = line;
        }
        continue;
      }
      buffer.write(char);
      if (char == '\n') {
        line++;
      }
    }
    flushEntry();
    return entries;
  }

  String _escapeField(String value, String delimiter) {
    if (value.isEmpty) {
      return value;
    }
    final requiresQuotes =
        value.contains(delimiter) ||
        value.contains(';') ||
        value.contains('\n') ||
        value.contains(r'\') ||
        value.contains('"');
    if (!requiresQuotes) {
      return value;
    }
    return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  }

  String _normalizeQuickSyntax(String input) {
    return input
        .replaceAll('，', ',')
        .replaceAll('、', ',')
        .replaceAll('﹐', ',')
        .replaceAll('；', ';')
        .replaceAll('﹔', ';')
        .replaceAll('：', ':')
        .replaceAll('﹕', ':');
  }

  (String, String)? _parseKeyValue(String value) {
    final index = value.indexOf(':');
    if (index <= 0) {
      return null;
    }
    final key = value.substring(0, index).trim().toLowerCase();
    final content = value.substring(index + 1).trim();
    if (key.isEmpty) {
      return null;
    }
    return (key, content);
  }

  String? _normalizeColor(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (_hexPattern.hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    const names = <String, String>{
      'blue': '#0000FF',
      'red': '#FF0000',
      'orange': '#FFA500',
      'green': '#008000',
      'yellow': '#FFFF00',
      'purple': '#800080',
      'pink': '#FFC0CB',
      'black': '#000000',
      'white': '#FFFFFF',
      'gray': '#808080',
      'grey': '#808080',
      'brown': '#A52A2A',
      'cyan': '#00FFFF',
      '蓝': '#0000FF',
      '蓝色': '#0000FF',
      '红': '#FF0000',
      '红色': '#FF0000',
      '橙': '#FFA500',
      '橙色': '#FFA500',
      '绿': '#008000',
      '绿色': '#008000',
      '黄': '#FFFF00',
      '黄色': '#FFFF00',
      '紫': '#800080',
      '紫色': '#800080',
      '粉': '#FFC0CB',
      '粉色': '#FFC0CB',
      '黑': '#000000',
      '黑色': '#000000',
      '白': '#FFFFFF',
      '白色': '#FFFFFF',
      '灰': '#808080',
      '灰色': '#808080',
      '棕': '#A52A2A',
      '棕色': '#A52A2A',
      '青': '#00FFFF',
      '青色': '#00FFFF',
    };
    return names[trimmed.toLowerCase()] ?? names[trimmed];
  }

  String _escapeHeader(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll(':', r'\:');
  }

  String _unescapeHeader(String value) {
    final buffer = StringBuffer();
    var escape = false;
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      if (escape) {
        buffer.write(char);
        escape = false;
      } else if (char == r'\') {
        escape = true;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String? _normalizeNullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _appendNote(String? existing, String value) {
    final left = existing?.trim();
    final right = value.trim();
    if (left == null || left.isEmpty) {
      return right;
    }
    if (right.isEmpty) {
      return left;
    }
    return '$left; $right';
  }
}

class _Line {
  const _Line({required this.number, required this.text});

  final int number;
  final String text;
}
