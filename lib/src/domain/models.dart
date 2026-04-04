enum ProbabilityMode { equal, weighted }

enum AppThemeMode { system, light, dark }

class WheelItemModel {
  const WheelItemModel({
    required this.id,
    required this.wheelId,
    required this.order,
    required this.title,
    this.subtitle,
    this.tags,
    this.note,
    this.colorHex,
    this.weight,
  });

  final int id;
  final int wheelId;
  final int order;
  final String title;
  final String? subtitle;
  final String? tags;
  final String? note;
  final String? colorHex;
  final double? weight;

  WheelItemModel copyWith({
    int? id,
    int? wheelId,
    int? order,
    String? title,
    String? subtitle,
    String? tags,
    String? note,
    String? colorHex,
    double? weight,
  }) {
    return WheelItemModel(
      id: id ?? this.id,
      wheelId: wheelId ?? this.wheelId,
      order: order ?? this.order,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      colorHex: colorHex ?? this.colorHex,
      weight: weight ?? this.weight,
    );
  }
}

class WheelModel {
  const WheelModel({
    required this.id,
    required this.name,
    required this.probabilityMode,
    required this.spinDurationMs,
    required this.palette,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  final int id;
  final String name;
  final ProbabilityMode probabilityMode;
  final int spinDurationMs;
  final String palette;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WheelItemModel> items;

  WheelModel copyWith({
    int? id,
    String? name,
    ProbabilityMode? probabilityMode,
    int? spinDurationMs,
    String? palette,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WheelItemModel>? items,
  }) {
    return WheelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      probabilityMode: probabilityMode ?? this.probabilityMode,
      spinDurationMs: spinDurationMs ?? this.spinDurationMs,
      palette: palette ?? this.palette,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class AppSettingsModel {
  const AppSettingsModel({this.localeOverride, this.themeMode = AppThemeMode.system});

  final String? localeOverride;
  final AppThemeMode themeMode;

  AppSettingsModel copyWith({String? localeOverride, AppThemeMode? themeMode}) {
    return AppSettingsModel(
      localeOverride: localeOverride,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
