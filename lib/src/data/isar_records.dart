import 'package:isar/isar.dart';

import '../domain/models.dart';

part 'isar_records.g.dart';

@collection
class WheelRecord {
  Id id = Isar.autoIncrement;

  late String name;

  @Enumerated(EnumType.name)
  ProbabilityMode probabilityMode = ProbabilityMode.equal;

  int spinDurationMs = 4800;
  String palette = 'ocean';
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class WheelItemRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late int wheelId;

  @Index()
  late int order;

  late String title;
  String? subtitle;
  String? tags;
  String? note;
  String? colorHex;
  double? weight;
  String? customFieldsJson;
}

@collection
class AppSettingsRecord {
  Id id = 1;
  String? localeOverride;

  @Enumerated(EnumType.name)
  AppThemeMode themeMode = AppThemeMode.system;
}
