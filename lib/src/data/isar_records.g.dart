// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_records.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWheelRecordCollection on Isar {
  IsarCollection<WheelRecord> get wheelRecords => this.collection();
}

const WheelRecordSchema = CollectionSchema(
  name: r'WheelRecord',
  id: -4633196076657241671,
  properties: {
    r'backgroundImageBlurSigma': PropertySchema(
      id: 0,
      name: r'backgroundImageBlurSigma',
      type: IsarType.double,
    ),
    r'backgroundImageOpacity': PropertySchema(
      id: 1,
      name: r'backgroundImageOpacity',
      type: IsarType.double,
    ),
    r'backgroundImagePath': PropertySchema(
      id: 2,
      name: r'backgroundImagePath',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'palette': PropertySchema(
      id: 5,
      name: r'palette',
      type: IsarType.string,
    ),
    r'probabilityMode': PropertySchema(
      id: 6,
      name: r'probabilityMode',
      type: IsarType.string,
      enumMap: _WheelRecordprobabilityModeEnumValueMap,
    ),
    r'spinDurationMs': PropertySchema(
      id: 7,
      name: r'spinDurationMs',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _wheelRecordEstimateSize,
  serialize: _wheelRecordSerialize,
  deserialize: _wheelRecordDeserialize,
  deserializeProp: _wheelRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _wheelRecordGetId,
  getLinks: _wheelRecordGetLinks,
  attach: _wheelRecordAttach,
  version: '3.1.0+1',
);

int _wheelRecordEstimateSize(
  WheelRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.backgroundImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.palette.length * 3;
  bytesCount += 3 + object.probabilityMode.name.length * 3;
  return bytesCount;
}

void _wheelRecordSerialize(
  WheelRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.backgroundImageBlurSigma);
  writer.writeDouble(offsets[1], object.backgroundImageOpacity);
  writer.writeString(offsets[2], object.backgroundImagePath);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.palette);
  writer.writeString(offsets[6], object.probabilityMode.name);
  writer.writeLong(offsets[7], object.spinDurationMs);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

WheelRecord _wheelRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WheelRecord();
  object.backgroundImageBlurSigma = reader.readDouble(offsets[0]);
  object.backgroundImageOpacity = reader.readDouble(offsets[1]);
  object.backgroundImagePath = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.name = reader.readString(offsets[4]);
  object.palette = reader.readString(offsets[5]);
  object.probabilityMode = _WheelRecordprobabilityModeValueEnumMap[
          reader.readStringOrNull(offsets[6])] ??
      ProbabilityMode.equal;
  object.spinDurationMs = reader.readLong(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _wheelRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_WheelRecordprobabilityModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          ProbabilityMode.equal) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _WheelRecordprobabilityModeEnumValueMap = {
  r'equal': r'equal',
  r'weighted': r'weighted',
  r'softAntiRepeat': r'softAntiRepeat',
};
const _WheelRecordprobabilityModeValueEnumMap = {
  r'equal': ProbabilityMode.equal,
  r'weighted': ProbabilityMode.weighted,
  r'softAntiRepeat': ProbabilityMode.softAntiRepeat,
};

Id _wheelRecordGetId(WheelRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wheelRecordGetLinks(WheelRecord object) {
  return [];
}

void _wheelRecordAttach(
    IsarCollection<dynamic> col, Id id, WheelRecord object) {
  object.id = id;
}

extension WheelRecordQueryWhereSort
    on QueryBuilder<WheelRecord, WheelRecord, QWhere> {
  QueryBuilder<WheelRecord, WheelRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WheelRecordQueryWhere
    on QueryBuilder<WheelRecord, WheelRecord, QWhereClause> {
  QueryBuilder<WheelRecord, WheelRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WheelRecordQueryFilter
    on QueryBuilder<WheelRecord, WheelRecord, QFilterCondition> {
  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageBlurSigmaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundImageBlurSigma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageBlurSigmaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundImageBlurSigma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageBlurSigmaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundImageBlurSigma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageBlurSigmaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundImageBlurSigma',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageOpacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundImageOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageOpacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundImageOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageOpacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundImageOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImageOpacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundImageOpacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'backgroundImagePath',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'backgroundImagePath',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backgroundImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      backgroundImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      paletteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'palette',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      paletteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'palette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition> paletteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'palette',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      paletteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'palette',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      paletteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'palette',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeEqualTo(
    ProbabilityMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeGreaterThan(
    ProbabilityMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeLessThan(
    ProbabilityMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeBetween(
    ProbabilityMode lower,
    ProbabilityMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'probabilityMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'probabilityMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'probabilityMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'probabilityMode',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      probabilityModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'probabilityMode',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      spinDurationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spinDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      spinDurationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spinDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      spinDurationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spinDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      spinDurationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spinDurationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WheelRecordQueryObject
    on QueryBuilder<WheelRecord, WheelRecord, QFilterCondition> {}

extension WheelRecordQueryLinks
    on QueryBuilder<WheelRecord, WheelRecord, QFilterCondition> {}

extension WheelRecordQuerySortBy
    on QueryBuilder<WheelRecord, WheelRecord, QSortBy> {
  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImageBlurSigma() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlurSigma', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImageBlurSigmaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlurSigma', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImageOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByPalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'palette', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByPaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'palette', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByProbabilityMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probabilityMode', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortByProbabilityModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probabilityMode', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortBySpinDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinDurationMs', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      sortBySpinDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinDurationMs', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WheelRecordQuerySortThenBy
    on QueryBuilder<WheelRecord, WheelRecord, QSortThenBy> {
  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImageBlurSigma() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlurSigma', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImageBlurSigmaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlurSigma', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImageOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByPalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'palette', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByPaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'palette', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByProbabilityMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probabilityMode', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenByProbabilityModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probabilityMode', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenBySpinDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinDurationMs', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy>
      thenBySpinDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinDurationMs', Sort.desc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WheelRecordQueryWhereDistinct
    on QueryBuilder<WheelRecord, WheelRecord, QDistinct> {
  QueryBuilder<WheelRecord, WheelRecord, QDistinct>
      distinctByBackgroundImageBlurSigma() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundImageBlurSigma');
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct>
      distinctByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundImageOpacity');
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct>
      distinctByBackgroundImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctByPalette(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'palette', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctByProbabilityMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'probabilityMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctBySpinDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spinDurationMs');
    });
  }

  QueryBuilder<WheelRecord, WheelRecord, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension WheelRecordQueryProperty
    on QueryBuilder<WheelRecord, WheelRecord, QQueryProperty> {
  QueryBuilder<WheelRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WheelRecord, double, QQueryOperations>
      backgroundImageBlurSigmaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImageBlurSigma');
    });
  }

  QueryBuilder<WheelRecord, double, QQueryOperations>
      backgroundImageOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImageOpacity');
    });
  }

  QueryBuilder<WheelRecord, String?, QQueryOperations>
      backgroundImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImagePath');
    });
  }

  QueryBuilder<WheelRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WheelRecord, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<WheelRecord, String, QQueryOperations> paletteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'palette');
    });
  }

  QueryBuilder<WheelRecord, ProbabilityMode, QQueryOperations>
      probabilityModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'probabilityMode');
    });
  }

  QueryBuilder<WheelRecord, int, QQueryOperations> spinDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spinDurationMs');
    });
  }

  QueryBuilder<WheelRecord, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWheelItemRecordCollection on Isar {
  IsarCollection<WheelItemRecord> get wheelItemRecords => this.collection();
}

const WheelItemRecordSchema = CollectionSchema(
  name: r'WheelItemRecord',
  id: 3299618855889462754,
  properties: {
    r'colorHex': PropertySchema(
      id: 0,
      name: r'colorHex',
      type: IsarType.string,
    ),
    r'customFieldsJson': PropertySchema(
      id: 1,
      name: r'customFieldsJson',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 3,
      name: r'order',
      type: IsarType.long,
    ),
    r'subtitle': PropertySchema(
      id: 4,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 5,
      name: r'tags',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    ),
    r'weight': PropertySchema(
      id: 7,
      name: r'weight',
      type: IsarType.double,
    ),
    r'wheelId': PropertySchema(
      id: 8,
      name: r'wheelId',
      type: IsarType.long,
    )
  },
  estimateSize: _wheelItemRecordEstimateSize,
  serialize: _wheelItemRecordSerialize,
  deserialize: _wheelItemRecordDeserialize,
  deserializeProp: _wheelItemRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'wheelId': IndexSchema(
      id: 8636777506550756613,
      name: r'wheelId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'wheelId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'order': IndexSchema(
      id: 5897270977454184057,
      name: r'order',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _wheelItemRecordGetId,
  getLinks: _wheelItemRecordGetLinks,
  attach: _wheelItemRecordAttach,
  version: '3.1.0+1',
);

int _wheelItemRecordEstimateSize(
  WheelItemRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.colorHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customFieldsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subtitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tags;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _wheelItemRecordSerialize(
  WheelItemRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.colorHex);
  writer.writeString(offsets[1], object.customFieldsJson);
  writer.writeString(offsets[2], object.note);
  writer.writeLong(offsets[3], object.order);
  writer.writeString(offsets[4], object.subtitle);
  writer.writeString(offsets[5], object.tags);
  writer.writeString(offsets[6], object.title);
  writer.writeDouble(offsets[7], object.weight);
  writer.writeLong(offsets[8], object.wheelId);
}

WheelItemRecord _wheelItemRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WheelItemRecord();
  object.colorHex = reader.readStringOrNull(offsets[0]);
  object.customFieldsJson = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[2]);
  object.order = reader.readLong(offsets[3]);
  object.subtitle = reader.readStringOrNull(offsets[4]);
  object.tags = reader.readStringOrNull(offsets[5]);
  object.title = reader.readString(offsets[6]);
  object.weight = reader.readDoubleOrNull(offsets[7]);
  object.wheelId = reader.readLong(offsets[8]);
  return object;
}

P _wheelItemRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wheelItemRecordGetId(WheelItemRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wheelItemRecordGetLinks(WheelItemRecord object) {
  return [];
}

void _wheelItemRecordAttach(
    IsarCollection<dynamic> col, Id id, WheelItemRecord object) {
  object.id = id;
}

extension WheelItemRecordQueryWhereSort
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QWhere> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhere> anyWheelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'wheelId'),
      );
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhere> anyOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'order'),
      );
    });
  }
}

extension WheelItemRecordQueryWhere
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QWhereClause> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      wheelIdEqualTo(int wheelId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'wheelId',
        value: [wheelId],
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      wheelIdNotEqualTo(int wheelId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wheelId',
              lower: [],
              upper: [wheelId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wheelId',
              lower: [wheelId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wheelId',
              lower: [wheelId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wheelId',
              lower: [],
              upper: [wheelId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      wheelIdGreaterThan(
    int wheelId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wheelId',
        lower: [wheelId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      wheelIdLessThan(
    int wheelId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wheelId',
        lower: [],
        upper: [wheelId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      wheelIdBetween(
    int lowerWheelId,
    int upperWheelId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wheelId',
        lower: [lowerWheelId],
        includeLower: includeLower,
        upper: [upperWheelId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      orderEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'order',
        value: [order],
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      orderNotEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      orderGreaterThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [order],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      orderLessThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [],
        upper: [order],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterWhereClause>
      orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [lowerOrder],
        includeLower: includeLower,
        upper: [upperOrder],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WheelItemRecordQueryFilter
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QFilterCondition> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'colorHex',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'colorHex',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      colorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customFieldsJson',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customFieldsJson',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFieldsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customFieldsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customFieldsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFieldsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      customFieldsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customFieldsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtitle',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtitle',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      wheelIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wheelId',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      wheelIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wheelId',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      wheelIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wheelId',
        value: value,
      ));
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterFilterCondition>
      wheelIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wheelId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WheelItemRecordQueryObject
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QFilterCondition> {}

extension WheelItemRecordQueryLinks
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QFilterCondition> {}

extension WheelItemRecordQuerySortBy
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QSortBy> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByCustomFieldsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsJson', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByCustomFieldsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsJson', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> sortByWheelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wheelId', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      sortByWheelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wheelId', Sort.desc);
    });
  }
}

extension WheelItemRecordQuerySortThenBy
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QSortThenBy> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByCustomFieldsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsJson', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByCustomFieldsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsJson', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy> thenByWheelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wheelId', Sort.asc);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QAfterSortBy>
      thenByWheelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wheelId', Sort.desc);
    });
  }
}

extension WheelItemRecordQueryWhereDistinct
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> {
  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByColorHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorHex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct>
      distinctByCustomFieldsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFieldsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctBySubtitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByTags(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }

  QueryBuilder<WheelItemRecord, WheelItemRecord, QDistinct>
      distinctByWheelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wheelId');
    });
  }
}

extension WheelItemRecordQueryProperty
    on QueryBuilder<WheelItemRecord, WheelItemRecord, QQueryProperty> {
  QueryBuilder<WheelItemRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WheelItemRecord, String?, QQueryOperations> colorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorHex');
    });
  }

  QueryBuilder<WheelItemRecord, String?, QQueryOperations>
      customFieldsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFieldsJson');
    });
  }

  QueryBuilder<WheelItemRecord, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<WheelItemRecord, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<WheelItemRecord, String?, QQueryOperations> subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<WheelItemRecord, String?, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<WheelItemRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<WheelItemRecord, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }

  QueryBuilder<WheelItemRecord, int, QQueryOperations> wheelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wheelId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsRecordCollection on Isar {
  IsarCollection<AppSettingsRecord> get appSettingsRecords => this.collection();
}

const AppSettingsRecordSchema = CollectionSchema(
  name: r'AppSettingsRecord',
  id: -5800169138830006153,
  properties: {
    r'drawSettingsJson': PropertySchema(
      id: 0,
      name: r'drawSettingsJson',
      type: IsarType.string,
    ),
    r'localeOverride': PropertySchema(
      id: 1,
      name: r'localeOverride',
      type: IsarType.string,
    ),
    r'themeMode': PropertySchema(
      id: 2,
      name: r'themeMode',
      type: IsarType.string,
      enumMap: _AppSettingsRecordthemeModeEnumValueMap,
    )
  },
  estimateSize: _appSettingsRecordEstimateSize,
  serialize: _appSettingsRecordSerialize,
  deserialize: _appSettingsRecordDeserialize,
  deserializeProp: _appSettingsRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsRecordGetId,
  getLinks: _appSettingsRecordGetLinks,
  attach: _appSettingsRecordAttach,
  version: '3.1.0+1',
);

int _appSettingsRecordEstimateSize(
  AppSettingsRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.drawSettingsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localeOverride;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.themeMode.name.length * 3;
  return bytesCount;
}

void _appSettingsRecordSerialize(
  AppSettingsRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.drawSettingsJson);
  writer.writeString(offsets[1], object.localeOverride);
  writer.writeString(offsets[2], object.themeMode.name);
}

AppSettingsRecord _appSettingsRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsRecord();
  object.drawSettingsJson = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.localeOverride = reader.readStringOrNull(offsets[1]);
  object.themeMode = _AppSettingsRecordthemeModeValueEnumMap[
          reader.readStringOrNull(offsets[2])] ??
      AppThemeMode.system;
  return object;
}

P _appSettingsRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (_AppSettingsRecordthemeModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AppThemeMode.system) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppSettingsRecordthemeModeEnumValueMap = {
  r'system': r'system',
  r'light': r'light',
  r'dark': r'dark',
};
const _AppSettingsRecordthemeModeValueEnumMap = {
  r'system': AppThemeMode.system,
  r'light': AppThemeMode.light,
  r'dark': AppThemeMode.dark,
};

Id _appSettingsRecordGetId(AppSettingsRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsRecordGetLinks(
    AppSettingsRecord object) {
  return [];
}

void _appSettingsRecordAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsRecord object) {
  object.id = id;
}

extension AppSettingsRecordQueryWhereSort
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QWhere> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsRecordQueryWhere
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QWhereClause> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsRecordQueryFilter
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QFilterCondition> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'drawSettingsJson',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'drawSettingsJson',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'drawSettingsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'drawSettingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'drawSettingsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'drawSettingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      drawSettingsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'drawSettingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localeOverride',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localeOverride',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localeOverride',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localeOverride',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localeOverride',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localeOverride',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      localeOverrideIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localeOverride',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeEqualTo(
    AppThemeMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeGreaterThan(
    AppThemeMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeLessThan(
    AppThemeMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeBetween(
    AppThemeMode lower,
    AppThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themeMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterFilterCondition>
      themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themeMode',
        value: '',
      ));
    });
  }
}

extension AppSettingsRecordQueryObject
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QFilterCondition> {}

extension AppSettingsRecordQueryLinks
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QFilterCondition> {}

extension AppSettingsRecordQuerySortBy
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QSortBy> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByDrawSettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drawSettingsJson', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByDrawSettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drawSettingsJson', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByLocaleOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeOverride', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByLocaleOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeOverride', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension AppSettingsRecordQuerySortThenBy
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QSortThenBy> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByDrawSettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drawSettingsJson', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByDrawSettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drawSettingsJson', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByLocaleOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeOverride', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByLocaleOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeOverride', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QAfterSortBy>
      thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension AppSettingsRecordQueryWhereDistinct
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QDistinct> {
  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QDistinct>
      distinctByDrawSettingsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'drawSettingsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QDistinct>
      distinctByLocaleOverride({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localeOverride',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsRecord, AppSettingsRecord, QDistinct>
      distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }
}

extension AppSettingsRecordQueryProperty
    on QueryBuilder<AppSettingsRecord, AppSettingsRecord, QQueryProperty> {
  QueryBuilder<AppSettingsRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsRecord, String?, QQueryOperations>
      drawSettingsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'drawSettingsJson');
    });
  }

  QueryBuilder<AppSettingsRecord, String?, QQueryOperations>
      localeOverrideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localeOverride');
    });
  }

  QueryBuilder<AppSettingsRecord, AppThemeMode, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
