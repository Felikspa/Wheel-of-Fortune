import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_of_fortune/src/domain/models.dart';
import 'package:wheel_of_fortune/src/services/wheel_codec.dart';

void main() {
  group('WheelCodec', () {
    test('imports csv format with placeholders', () {
      const input = '''
@format:csv
@name:Lunch
@mode:weighted
@spinDurationMs:5300
@palette:sunset

"Chicken, Rice",Cafe,,note,#FFAA00,3;
Noodle,,tag1|tag2,,#112233,;
''';
      final codec = WheelCodec();
      final parsed = codec.importWheel(input);

      expect(parsed.name, 'Lunch');
      expect(parsed.probabilityMode, ProbabilityMode.weighted);
      expect(parsed.spinDurationMs, 5300);
      expect(parsed.palette, 'sunset');
      expect(parsed.items.length, 2);
      expect(parsed.items.first.title, 'Chicken, Rice');
      expect(parsed.items[1].subtitle, isNull);
      expect(parsed.errors, isEmpty);
    });

    test('imports pipe format and reports invalid rows', () {
      const input = '''
@format:pipe
@name:Dinner
Steak|Hall A|||#GGGGGG|2
Pasta|Hall B|||#112233|1.5
''';
      final codec = WheelCodec();
      final parsed = codec.importWheel(input);

      expect(parsed.format, DslFormat.pipe);
      expect(parsed.items.length, 1);
      expect(parsed.errors.length, 1);
      expect(parsed.errors.first.code, WheelImportErrorCode.invalidColor);
    });

    test('round-trips wheel export and import', () {
      final codec = WheelCodec();
      final wheel = WheelModel(
        id: 1,
        name: 'RoundTrip',
        probabilityMode: ProbabilityMode.equal,
        spinDurationMs: 4800,
        palette: 'ocean',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        items: const [
          WheelItemModel(id: 1, wheelId: 1, order: 0, title: 'A', subtitle: 'S1'),
          WheelItemModel(id: 2, wheelId: 1, order: 1, title: 'B', weight: 2.0),
        ],
      );
      final text = codec.exportWheel(wheel);
      final parsed = codec.importWheel(text);

      expect(parsed.name, wheel.name);
      expect(parsed.items.length, wheel.items.length);
      expect(parsed.items[0].subtitle, 'S1');
      expect(parsed.items[1].weight, 2.0);
    });
  });
}
