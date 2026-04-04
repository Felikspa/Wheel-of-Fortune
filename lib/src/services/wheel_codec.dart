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
  const WheelImportError({
    required this.line,
    required this.code,
    this.value,
  });

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

class WheelCodec {
  static final RegExp _hexPattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
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
      return fields.map((value) => _escapeField(value, delimiter)).join(delimiter);
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
        palette: 'ocean',
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
    final name = headers['name']?.trim().isNotEmpty == true ? headers['name']!.trim() : 'Imported Wheel';
    final mode = headers['mode'] == 'weighted' ? ProbabilityMode.weighted : ProbabilityMode.equal;
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
      for (var i = 0; i < parsedItems.length; i++) parsedItems[i].copyWith(order: i),
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

  DslFormat _resolveFormat(String? explicitFormat, List<_Line> bodyLines) {
    final normalized = explicitFormat?.toLowerCase().trim();
    if (normalized == 'pipe') {
      return DslFormat.pipe;
    }
    if (normalized == 'csv') {
      return DslFormat.csv;
    }
    final nonEmpty = bodyLines.where((line) => line.text.trim().isNotEmpty).toList();
    if (nonEmpty.isNotEmpty && nonEmpty.every((line) => line.text.contains('|'))) {
      return DslFormat.pipe;
    }
    return DslFormat.csv;
  }

  String _resolvePalette(String? value) {
    const allowed = {'ocean', 'sunset', 'mint', 'mono'};
    final normalized = value?.trim().toLowerCase();
    if (normalized != null && allowed.contains(normalized)) {
      return normalized;
    }
    return 'ocean';
  }

  void _parseItemFields({
    required List<String> fields,
    required int line,
    required List<WheelItemModel> wheelItems,
    required List<WheelImportError> errors,
  }) {
    if (fields.length > _fieldLimit) {
      errors.add(WheelImportError(line: line, code: WheelImportErrorCode.tooManyFields));
      return;
    }
    final padded = [...fields];
    while (padded.length < _fieldLimit) {
      padded.add('');
    }
    final title = padded[0].trim();
    if (title.isEmpty) {
      errors.add(WheelImportError(line: line, code: WheelImportErrorCode.missingTitle));
      return;
    }

    final colorHex = padded[4].trim();
    if (colorHex.isNotEmpty && !_hexPattern.hasMatch(colorHex)) {
      errors.add(WheelImportError(line: line, code: WheelImportErrorCode.invalidColor, value: colorHex));
      return;
    }

    final weightString = padded[5].trim();
    double? weight;
    if (weightString.isNotEmpty) {
      weight = double.tryParse(weightString);
      if (weight == null || weight <= 0) {
        errors.add(WheelImportError(line: line, code: WheelImportErrorCode.invalidWeight, value: weightString));
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
    final requiresQuotes = value.contains(delimiter) ||
        value.contains(';') ||
        value.contains('\n') ||
        value.contains(r'\') ||
        value.contains('"');
    if (!requiresQuotes) {
      return value;
    }
    return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
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
}

class _Line {
  const _Line({required this.number, required this.text});

  final int number;
  final String text;
}
