// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthPoint _$HealthPointFromJson(Map<String, dynamic> json) {
  return _HealthPoint.fromJson(json);
}

/// @nodoc
mixin _$HealthPoint {
  String get testDate => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  bool get comparable => throw _privateConstructorUsedError;
  String? get comparabilityNote => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get labTestName => throw _privateConstructorUsedError;
  double? get refLow => throw _privateConstructorUsedError;
  double? get refHigh => throw _privateConstructorUsedError;
  bool? get abnormal => throw _privateConstructorUsedError;

  /// Serializes this HealthPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthPointCopyWith<HealthPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthPointCopyWith<$Res> {
  factory $HealthPointCopyWith(
          HealthPoint value, $Res Function(HealthPoint) then) =
      _$HealthPointCopyWithImpl<$Res, HealthPoint>;
  @useResult
  $Res call(
      {String testDate,
      double value,
      bool comparable,
      String? comparabilityNote,
      String bookingId,
      String labName,
      String labTestName,
      double? refLow,
      double? refHigh,
      bool? abnormal});
}

/// @nodoc
class _$HealthPointCopyWithImpl<$Res, $Val extends HealthPoint>
    implements $HealthPointCopyWith<$Res> {
  _$HealthPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testDate = null,
    Object? value = null,
    Object? comparable = null,
    Object? comparabilityNote = freezed,
    Object? bookingId = null,
    Object? labName = null,
    Object? labTestName = null,
    Object? refLow = freezed,
    Object? refHigh = freezed,
    Object? abnormal = freezed,
  }) {
    return _then(_value.copyWith(
      testDate: null == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      comparable: null == comparable
          ? _value.comparable
          : comparable // ignore: cast_nullable_to_non_nullable
              as bool,
      comparabilityNote: freezed == comparabilityNote
          ? _value.comparabilityNote
          : comparabilityNote // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      labTestName: null == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String,
      refLow: freezed == refLow
          ? _value.refLow
          : refLow // ignore: cast_nullable_to_non_nullable
              as double?,
      refHigh: freezed == refHigh
          ? _value.refHigh
          : refHigh // ignore: cast_nullable_to_non_nullable
              as double?,
      abnormal: freezed == abnormal
          ? _value.abnormal
          : abnormal // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthPointImplCopyWith<$Res>
    implements $HealthPointCopyWith<$Res> {
  factory _$$HealthPointImplCopyWith(
          _$HealthPointImpl value, $Res Function(_$HealthPointImpl) then) =
      __$$HealthPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String testDate,
      double value,
      bool comparable,
      String? comparabilityNote,
      String bookingId,
      String labName,
      String labTestName,
      double? refLow,
      double? refHigh,
      bool? abnormal});
}

/// @nodoc
class __$$HealthPointImplCopyWithImpl<$Res>
    extends _$HealthPointCopyWithImpl<$Res, _$HealthPointImpl>
    implements _$$HealthPointImplCopyWith<$Res> {
  __$$HealthPointImplCopyWithImpl(
      _$HealthPointImpl _value, $Res Function(_$HealthPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testDate = null,
    Object? value = null,
    Object? comparable = null,
    Object? comparabilityNote = freezed,
    Object? bookingId = null,
    Object? labName = null,
    Object? labTestName = null,
    Object? refLow = freezed,
    Object? refHigh = freezed,
    Object? abnormal = freezed,
  }) {
    return _then(_$HealthPointImpl(
      testDate: null == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      comparable: null == comparable
          ? _value.comparable
          : comparable // ignore: cast_nullable_to_non_nullable
              as bool,
      comparabilityNote: freezed == comparabilityNote
          ? _value.comparabilityNote
          : comparabilityNote // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      labTestName: null == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String,
      refLow: freezed == refLow
          ? _value.refLow
          : refLow // ignore: cast_nullable_to_non_nullable
              as double?,
      refHigh: freezed == refHigh
          ? _value.refHigh
          : refHigh // ignore: cast_nullable_to_non_nullable
              as double?,
      abnormal: freezed == abnormal
          ? _value.abnormal
          : abnormal // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthPointImpl implements _HealthPoint {
  const _$HealthPointImpl(
      {required this.testDate,
      required this.value,
      required this.comparable,
      this.comparabilityNote,
      required this.bookingId,
      required this.labName,
      required this.labTestName,
      this.refLow,
      this.refHigh,
      this.abnormal});

  factory _$HealthPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthPointImplFromJson(json);

  @override
  final String testDate;
  @override
  final double value;
  @override
  final bool comparable;
  @override
  final String? comparabilityNote;
  @override
  final String bookingId;
  @override
  final String labName;
  @override
  final String labTestName;
  @override
  final double? refLow;
  @override
  final double? refHigh;
  @override
  final bool? abnormal;

  @override
  String toString() {
    return 'HealthPoint(testDate: $testDate, value: $value, comparable: $comparable, comparabilityNote: $comparabilityNote, bookingId: $bookingId, labName: $labName, labTestName: $labTestName, refLow: $refLow, refHigh: $refHigh, abnormal: $abnormal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthPointImpl &&
            (identical(other.testDate, testDate) ||
                other.testDate == testDate) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.comparable, comparable) ||
                other.comparable == comparable) &&
            (identical(other.comparabilityNote, comparabilityNote) ||
                other.comparabilityNote == comparabilityNote) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.labTestName, labTestName) ||
                other.labTestName == labTestName) &&
            (identical(other.refLow, refLow) || other.refLow == refLow) &&
            (identical(other.refHigh, refHigh) || other.refHigh == refHigh) &&
            (identical(other.abnormal, abnormal) ||
                other.abnormal == abnormal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      testDate,
      value,
      comparable,
      comparabilityNote,
      bookingId,
      labName,
      labTestName,
      refLow,
      refHigh,
      abnormal);

  /// Create a copy of HealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthPointImplCopyWith<_$HealthPointImpl> get copyWith =>
      __$$HealthPointImplCopyWithImpl<_$HealthPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthPointImplToJson(
      this,
    );
  }
}

abstract class _HealthPoint implements HealthPoint {
  const factory _HealthPoint(
      {required final String testDate,
      required final double value,
      required final bool comparable,
      final String? comparabilityNote,
      required final String bookingId,
      required final String labName,
      required final String labTestName,
      final double? refLow,
      final double? refHigh,
      final bool? abnormal}) = _$HealthPointImpl;

  factory _HealthPoint.fromJson(Map<String, dynamic> json) =
      _$HealthPointImpl.fromJson;

  @override
  String get testDate;
  @override
  double get value;
  @override
  bool get comparable;
  @override
  String? get comparabilityNote;
  @override
  String get bookingId;
  @override
  String get labName;
  @override
  String get labTestName;
  @override
  double? get refLow;
  @override
  double? get refHigh;
  @override
  bool? get abnormal;

  /// Create a copy of HealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthPointImplCopyWith<_$HealthPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthTrend _$HealthTrendFromJson(Map<String, dynamic> json) {
  return _HealthTrend.fromJson(json);
}

/// @nodoc
mixin _$HealthTrend {
  String get direction => throw _privateConstructorUsedError;
  String get narrative => throw _privateConstructorUsedError;
  String? get qualitativeNote => throw _privateConstructorUsedError;

  /// Serializes this HealthTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthTrendCopyWith<HealthTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthTrendCopyWith<$Res> {
  factory $HealthTrendCopyWith(
          HealthTrend value, $Res Function(HealthTrend) then) =
      _$HealthTrendCopyWithImpl<$Res, HealthTrend>;
  @useResult
  $Res call({String direction, String narrative, String? qualitativeNote});
}

/// @nodoc
class _$HealthTrendCopyWithImpl<$Res, $Val extends HealthTrend>
    implements $HealthTrendCopyWith<$Res> {
  _$HealthTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? narrative = null,
    Object? qualitativeNote = freezed,
  }) {
    return _then(_value.copyWith(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      narrative: null == narrative
          ? _value.narrative
          : narrative // ignore: cast_nullable_to_non_nullable
              as String,
      qualitativeNote: freezed == qualitativeNote
          ? _value.qualitativeNote
          : qualitativeNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthTrendImplCopyWith<$Res>
    implements $HealthTrendCopyWith<$Res> {
  factory _$$HealthTrendImplCopyWith(
          _$HealthTrendImpl value, $Res Function(_$HealthTrendImpl) then) =
      __$$HealthTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String direction, String narrative, String? qualitativeNote});
}

/// @nodoc
class __$$HealthTrendImplCopyWithImpl<$Res>
    extends _$HealthTrendCopyWithImpl<$Res, _$HealthTrendImpl>
    implements _$$HealthTrendImplCopyWith<$Res> {
  __$$HealthTrendImplCopyWithImpl(
      _$HealthTrendImpl _value, $Res Function(_$HealthTrendImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? narrative = null,
    Object? qualitativeNote = freezed,
  }) {
    return _then(_$HealthTrendImpl(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      narrative: null == narrative
          ? _value.narrative
          : narrative // ignore: cast_nullable_to_non_nullable
              as String,
      qualitativeNote: freezed == qualitativeNote
          ? _value.qualitativeNote
          : qualitativeNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthTrendImpl implements _HealthTrend {
  const _$HealthTrendImpl(
      {required this.direction, required this.narrative, this.qualitativeNote});

  factory _$HealthTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthTrendImplFromJson(json);

  @override
  final String direction;
  @override
  final String narrative;
  @override
  final String? qualitativeNote;

  @override
  String toString() {
    return 'HealthTrend(direction: $direction, narrative: $narrative, qualitativeNote: $qualitativeNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthTrendImpl &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.narrative, narrative) ||
                other.narrative == narrative) &&
            (identical(other.qualitativeNote, qualitativeNote) ||
                other.qualitativeNote == qualitativeNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, direction, narrative, qualitativeNote);

  /// Create a copy of HealthTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthTrendImplCopyWith<_$HealthTrendImpl> get copyWith =>
      __$$HealthTrendImplCopyWithImpl<_$HealthTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthTrendImplToJson(
      this,
    );
  }
}

abstract class _HealthTrend implements HealthTrend {
  const factory _HealthTrend(
      {required final String direction,
      required final String narrative,
      final String? qualitativeNote}) = _$HealthTrendImpl;

  factory _HealthTrend.fromJson(Map<String, dynamic> json) =
      _$HealthTrendImpl.fromJson;

  @override
  String get direction;
  @override
  String get narrative;
  @override
  String? get qualitativeNote;

  /// Create a copy of HealthTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthTrendImplCopyWith<_$HealthTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthSeries _$HealthSeriesFromJson(Map<String, dynamic> json) {
  return _HealthSeries.fromJson(json);
}

/// @nodoc
mixin _$HealthSeries {
  String get canonicalCode => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get chartUnit => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get labTestName => throw _privateConstructorUsedError;
  HealthTrend get trend => throw _privateConstructorUsedError;
  List<HealthPoint> get points => throw _privateConstructorUsedError;

  /// Serializes this HealthSeries to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthSeriesCopyWith<HealthSeries> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthSeriesCopyWith<$Res> {
  factory $HealthSeriesCopyWith(
          HealthSeries value, $Res Function(HealthSeries) then) =
      _$HealthSeriesCopyWithImpl<$Res, HealthSeries>;
  @useResult
  $Res call(
      {String canonicalCode,
      String displayName,
      String chartUnit,
      String? category,
      String? labTestName,
      HealthTrend trend,
      List<HealthPoint> points});

  $HealthTrendCopyWith<$Res> get trend;
}

/// @nodoc
class _$HealthSeriesCopyWithImpl<$Res, $Val extends HealthSeries>
    implements $HealthSeriesCopyWith<$Res> {
  _$HealthSeriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonicalCode = null,
    Object? displayName = null,
    Object? chartUnit = null,
    Object? category = freezed,
    Object? labTestName = freezed,
    Object? trend = null,
    Object? points = null,
  }) {
    return _then(_value.copyWith(
      canonicalCode: null == canonicalCode
          ? _value.canonicalCode
          : canonicalCode // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      chartUnit: null == chartUnit
          ? _value.chartUnit
          : chartUnit // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      labTestName: freezed == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String?,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as HealthTrend,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as List<HealthPoint>,
    ) as $Val);
  }

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTrendCopyWith<$Res> get trend {
    return $HealthTrendCopyWith<$Res>(_value.trend, (value) {
      return _then(_value.copyWith(trend: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HealthSeriesImplCopyWith<$Res>
    implements $HealthSeriesCopyWith<$Res> {
  factory _$$HealthSeriesImplCopyWith(
          _$HealthSeriesImpl value, $Res Function(_$HealthSeriesImpl) then) =
      __$$HealthSeriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String canonicalCode,
      String displayName,
      String chartUnit,
      String? category,
      String? labTestName,
      HealthTrend trend,
      List<HealthPoint> points});

  @override
  $HealthTrendCopyWith<$Res> get trend;
}

/// @nodoc
class __$$HealthSeriesImplCopyWithImpl<$Res>
    extends _$HealthSeriesCopyWithImpl<$Res, _$HealthSeriesImpl>
    implements _$$HealthSeriesImplCopyWith<$Res> {
  __$$HealthSeriesImplCopyWithImpl(
      _$HealthSeriesImpl _value, $Res Function(_$HealthSeriesImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonicalCode = null,
    Object? displayName = null,
    Object? chartUnit = null,
    Object? category = freezed,
    Object? labTestName = freezed,
    Object? trend = null,
    Object? points = null,
  }) {
    return _then(_$HealthSeriesImpl(
      canonicalCode: null == canonicalCode
          ? _value.canonicalCode
          : canonicalCode // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      chartUnit: null == chartUnit
          ? _value.chartUnit
          : chartUnit // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      labTestName: freezed == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String?,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as HealthTrend,
      points: null == points
          ? _value._points
          : points // ignore: cast_nullable_to_non_nullable
              as List<HealthPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthSeriesImpl implements _HealthSeries {
  const _$HealthSeriesImpl(
      {required this.canonicalCode,
      required this.displayName,
      required this.chartUnit,
      this.category,
      this.labTestName,
      required this.trend,
      required final List<HealthPoint> points})
      : _points = points;

  factory _$HealthSeriesImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthSeriesImplFromJson(json);

  @override
  final String canonicalCode;
  @override
  final String displayName;
  @override
  final String chartUnit;
  @override
  final String? category;
  @override
  final String? labTestName;
  @override
  final HealthTrend trend;
  final List<HealthPoint> _points;
  @override
  List<HealthPoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  String toString() {
    return 'HealthSeries(canonicalCode: $canonicalCode, displayName: $displayName, chartUnit: $chartUnit, category: $category, labTestName: $labTestName, trend: $trend, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthSeriesImpl &&
            (identical(other.canonicalCode, canonicalCode) ||
                other.canonicalCode == canonicalCode) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.chartUnit, chartUnit) ||
                other.chartUnit == chartUnit) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.labTestName, labTestName) ||
                other.labTestName == labTestName) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            const DeepCollectionEquality().equals(other._points, _points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      canonicalCode,
      displayName,
      chartUnit,
      category,
      labTestName,
      trend,
      const DeepCollectionEquality().hash(_points));

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthSeriesImplCopyWith<_$HealthSeriesImpl> get copyWith =>
      __$$HealthSeriesImplCopyWithImpl<_$HealthSeriesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthSeriesImplToJson(
      this,
    );
  }
}

abstract class _HealthSeries implements HealthSeries {
  const factory _HealthSeries(
      {required final String canonicalCode,
      required final String displayName,
      required final String chartUnit,
      final String? category,
      final String? labTestName,
      required final HealthTrend trend,
      required final List<HealthPoint> points}) = _$HealthSeriesImpl;

  factory _HealthSeries.fromJson(Map<String, dynamic> json) =
      _$HealthSeriesImpl.fromJson;

  @override
  String get canonicalCode;
  @override
  String get displayName;
  @override
  String get chartUnit;
  @override
  String? get category;
  @override
  String? get labTestName;
  @override
  HealthTrend get trend;
  @override
  List<HealthPoint> get points;

  /// Create a copy of HealthSeries
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthSeriesImplCopyWith<_$HealthSeriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabTestGroup _$LabTestGroupFromJson(Map<String, dynamic> json) {
  return _LabTestGroup.fromJson(json);
}

/// @nodoc
mixin _$LabTestGroup {
  String get labTestName => throw _privateConstructorUsedError;
  List<HealthSeries> get series => throw _privateConstructorUsedError;

  /// Serializes this LabTestGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabTestGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabTestGroupCopyWith<LabTestGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabTestGroupCopyWith<$Res> {
  factory $LabTestGroupCopyWith(
          LabTestGroup value, $Res Function(LabTestGroup) then) =
      _$LabTestGroupCopyWithImpl<$Res, LabTestGroup>;
  @useResult
  $Res call({String labTestName, List<HealthSeries> series});
}

/// @nodoc
class _$LabTestGroupCopyWithImpl<$Res, $Val extends LabTestGroup>
    implements $LabTestGroupCopyWith<$Res> {
  _$LabTestGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabTestGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labTestName = null,
    Object? series = null,
  }) {
    return _then(_value.copyWith(
      labTestName: null == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String,
      series: null == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as List<HealthSeries>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabTestGroupImplCopyWith<$Res>
    implements $LabTestGroupCopyWith<$Res> {
  factory _$$LabTestGroupImplCopyWith(
          _$LabTestGroupImpl value, $Res Function(_$LabTestGroupImpl) then) =
      __$$LabTestGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String labTestName, List<HealthSeries> series});
}

/// @nodoc
class __$$LabTestGroupImplCopyWithImpl<$Res>
    extends _$LabTestGroupCopyWithImpl<$Res, _$LabTestGroupImpl>
    implements _$$LabTestGroupImplCopyWith<$Res> {
  __$$LabTestGroupImplCopyWithImpl(
      _$LabTestGroupImpl _value, $Res Function(_$LabTestGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabTestGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labTestName = null,
    Object? series = null,
  }) {
    return _then(_$LabTestGroupImpl(
      labTestName: null == labTestName
          ? _value.labTestName
          : labTestName // ignore: cast_nullable_to_non_nullable
              as String,
      series: null == series
          ? _value._series
          : series // ignore: cast_nullable_to_non_nullable
              as List<HealthSeries>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabTestGroupImpl implements _LabTestGroup {
  const _$LabTestGroupImpl(
      {required this.labTestName, required final List<HealthSeries> series})
      : _series = series;

  factory _$LabTestGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabTestGroupImplFromJson(json);

  @override
  final String labTestName;
  final List<HealthSeries> _series;
  @override
  List<HealthSeries> get series {
    if (_series is EqualUnmodifiableListView) return _series;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_series);
  }

  @override
  String toString() {
    return 'LabTestGroup(labTestName: $labTestName, series: $series)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabTestGroupImpl &&
            (identical(other.labTestName, labTestName) ||
                other.labTestName == labTestName) &&
            const DeepCollectionEquality().equals(other._series, _series));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, labTestName, const DeepCollectionEquality().hash(_series));

  /// Create a copy of LabTestGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabTestGroupImplCopyWith<_$LabTestGroupImpl> get copyWith =>
      __$$LabTestGroupImplCopyWithImpl<_$LabTestGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabTestGroupImplToJson(
      this,
    );
  }
}

abstract class _LabTestGroup implements LabTestGroup {
  const factory _LabTestGroup(
      {required final String labTestName,
      required final List<HealthSeries> series}) = _$LabTestGroupImpl;

  factory _LabTestGroup.fromJson(Map<String, dynamic> json) =
      _$LabTestGroupImpl.fromJson;

  @override
  String get labTestName;
  @override
  List<HealthSeries> get series;

  /// Create a copy of LabTestGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabTestGroupImplCopyWith<_$LabTestGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PdfOnlyBooking _$PdfOnlyBookingFromJson(Map<String, dynamic> json) {
  return _PdfOnlyBooking.fromJson(json);
}

/// @nodoc
mixin _$PdfOnlyBooking {
  String get bookingId => throw _privateConstructorUsedError;
  String get scheduledAt => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get testName => throw _privateConstructorUsedError;

  /// Serializes this PdfOnlyBooking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfOnlyBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfOnlyBookingCopyWith<PdfOnlyBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfOnlyBookingCopyWith<$Res> {
  factory $PdfOnlyBookingCopyWith(
          PdfOnlyBooking value, $Res Function(PdfOnlyBooking) then) =
      _$PdfOnlyBookingCopyWithImpl<$Res, PdfOnlyBooking>;
  @useResult
  $Res call(
      {String bookingId, String scheduledAt, String labName, String testName});
}

/// @nodoc
class _$PdfOnlyBookingCopyWithImpl<$Res, $Val extends PdfOnlyBooking>
    implements $PdfOnlyBookingCopyWith<$Res> {
  _$PdfOnlyBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfOnlyBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? scheduledAt = null,
    Object? labName = null,
    Object? testName = null,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PdfOnlyBookingImplCopyWith<$Res>
    implements $PdfOnlyBookingCopyWith<$Res> {
  factory _$$PdfOnlyBookingImplCopyWith(_$PdfOnlyBookingImpl value,
          $Res Function(_$PdfOnlyBookingImpl) then) =
      __$$PdfOnlyBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId, String scheduledAt, String labName, String testName});
}

/// @nodoc
class __$$PdfOnlyBookingImplCopyWithImpl<$Res>
    extends _$PdfOnlyBookingCopyWithImpl<$Res, _$PdfOnlyBookingImpl>
    implements _$$PdfOnlyBookingImplCopyWith<$Res> {
  __$$PdfOnlyBookingImplCopyWithImpl(
      _$PdfOnlyBookingImpl _value, $Res Function(_$PdfOnlyBookingImpl) _then)
      : super(_value, _then);

  /// Create a copy of PdfOnlyBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? scheduledAt = null,
    Object? labName = null,
    Object? testName = null,
  }) {
    return _then(_$PdfOnlyBookingImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfOnlyBookingImpl implements _PdfOnlyBooking {
  const _$PdfOnlyBookingImpl(
      {required this.bookingId,
      required this.scheduledAt,
      required this.labName,
      required this.testName});

  factory _$PdfOnlyBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfOnlyBookingImplFromJson(json);

  @override
  final String bookingId;
  @override
  final String scheduledAt;
  @override
  final String labName;
  @override
  final String testName;

  @override
  String toString() {
    return 'PdfOnlyBooking(bookingId: $bookingId, scheduledAt: $scheduledAt, labName: $labName, testName: $testName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfOnlyBookingImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.testName, testName) ||
                other.testName == testName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, bookingId, scheduledAt, labName, testName);

  /// Create a copy of PdfOnlyBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfOnlyBookingImplCopyWith<_$PdfOnlyBookingImpl> get copyWith =>
      __$$PdfOnlyBookingImplCopyWithImpl<_$PdfOnlyBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfOnlyBookingImplToJson(
      this,
    );
  }
}

abstract class _PdfOnlyBooking implements PdfOnlyBooking {
  const factory _PdfOnlyBooking(
      {required final String bookingId,
      required final String scheduledAt,
      required final String labName,
      required final String testName}) = _$PdfOnlyBookingImpl;

  factory _PdfOnlyBooking.fromJson(Map<String, dynamic> json) =
      _$PdfOnlyBookingImpl.fromJson;

  @override
  String get bookingId;
  @override
  String get scheduledAt;
  @override
  String get labName;
  @override
  String get testName;

  /// Create a copy of PdfOnlyBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfOnlyBookingImplCopyWith<_$PdfOnlyBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthProfileResponse _$HealthProfileResponseFromJson(
    Map<String, dynamic> json) {
  return _HealthProfileResponse.fromJson(json);
}

/// @nodoc
mixin _$HealthProfileResponse {
  String get range => throw _privateConstructorUsedError;
  String get groupBy => throw _privateConstructorUsedError;
  List<HealthSeries> get series => throw _privateConstructorUsedError;
  List<LabTestGroup> get labTestGroups => throw _privateConstructorUsedError;
  List<PdfOnlyBooking> get pdfOnlyBookings =>
      throw _privateConstructorUsedError;
  bool get hasStructuredData => throw _privateConstructorUsedError;
  String get disclaimer => throw _privateConstructorUsedError;

  /// Serializes this HealthProfileResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthProfileResponseCopyWith<HealthProfileResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthProfileResponseCopyWith<$Res> {
  factory $HealthProfileResponseCopyWith(HealthProfileResponse value,
          $Res Function(HealthProfileResponse) then) =
      _$HealthProfileResponseCopyWithImpl<$Res, HealthProfileResponse>;
  @useResult
  $Res call(
      {String range,
      String groupBy,
      List<HealthSeries> series,
      List<LabTestGroup> labTestGroups,
      List<PdfOnlyBooking> pdfOnlyBookings,
      bool hasStructuredData,
      String disclaimer});
}

/// @nodoc
class _$HealthProfileResponseCopyWithImpl<$Res,
        $Val extends HealthProfileResponse>
    implements $HealthProfileResponseCopyWith<$Res> {
  _$HealthProfileResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? range = null,
    Object? groupBy = null,
    Object? series = null,
    Object? labTestGroups = null,
    Object? pdfOnlyBookings = null,
    Object? hasStructuredData = null,
    Object? disclaimer = null,
  }) {
    return _then(_value.copyWith(
      range: null == range
          ? _value.range
          : range // ignore: cast_nullable_to_non_nullable
              as String,
      groupBy: null == groupBy
          ? _value.groupBy
          : groupBy // ignore: cast_nullable_to_non_nullable
              as String,
      series: null == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as List<HealthSeries>,
      labTestGroups: null == labTestGroups
          ? _value.labTestGroups
          : labTestGroups // ignore: cast_nullable_to_non_nullable
              as List<LabTestGroup>,
      pdfOnlyBookings: null == pdfOnlyBookings
          ? _value.pdfOnlyBookings
          : pdfOnlyBookings // ignore: cast_nullable_to_non_nullable
              as List<PdfOnlyBooking>,
      hasStructuredData: null == hasStructuredData
          ? _value.hasStructuredData
          : hasStructuredData // ignore: cast_nullable_to_non_nullable
              as bool,
      disclaimer: null == disclaimer
          ? _value.disclaimer
          : disclaimer // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthProfileResponseImplCopyWith<$Res>
    implements $HealthProfileResponseCopyWith<$Res> {
  factory _$$HealthProfileResponseImplCopyWith(
          _$HealthProfileResponseImpl value,
          $Res Function(_$HealthProfileResponseImpl) then) =
      __$$HealthProfileResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String range,
      String groupBy,
      List<HealthSeries> series,
      List<LabTestGroup> labTestGroups,
      List<PdfOnlyBooking> pdfOnlyBookings,
      bool hasStructuredData,
      String disclaimer});
}

/// @nodoc
class __$$HealthProfileResponseImplCopyWithImpl<$Res>
    extends _$HealthProfileResponseCopyWithImpl<$Res,
        _$HealthProfileResponseImpl>
    implements _$$HealthProfileResponseImplCopyWith<$Res> {
  __$$HealthProfileResponseImplCopyWithImpl(_$HealthProfileResponseImpl _value,
      $Res Function(_$HealthProfileResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? range = null,
    Object? groupBy = null,
    Object? series = null,
    Object? labTestGroups = null,
    Object? pdfOnlyBookings = null,
    Object? hasStructuredData = null,
    Object? disclaimer = null,
  }) {
    return _then(_$HealthProfileResponseImpl(
      range: null == range
          ? _value.range
          : range // ignore: cast_nullable_to_non_nullable
              as String,
      groupBy: null == groupBy
          ? _value.groupBy
          : groupBy // ignore: cast_nullable_to_non_nullable
              as String,
      series: null == series
          ? _value._series
          : series // ignore: cast_nullable_to_non_nullable
              as List<HealthSeries>,
      labTestGroups: null == labTestGroups
          ? _value._labTestGroups
          : labTestGroups // ignore: cast_nullable_to_non_nullable
              as List<LabTestGroup>,
      pdfOnlyBookings: null == pdfOnlyBookings
          ? _value._pdfOnlyBookings
          : pdfOnlyBookings // ignore: cast_nullable_to_non_nullable
              as List<PdfOnlyBooking>,
      hasStructuredData: null == hasStructuredData
          ? _value.hasStructuredData
          : hasStructuredData // ignore: cast_nullable_to_non_nullable
              as bool,
      disclaimer: null == disclaimer
          ? _value.disclaimer
          : disclaimer // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthProfileResponseImpl implements _HealthProfileResponse {
  const _$HealthProfileResponseImpl(
      {required this.range,
      required this.groupBy,
      required final List<HealthSeries> series,
      required final List<LabTestGroup> labTestGroups,
      required final List<PdfOnlyBooking> pdfOnlyBookings,
      required this.hasStructuredData,
      required this.disclaimer})
      : _series = series,
        _labTestGroups = labTestGroups,
        _pdfOnlyBookings = pdfOnlyBookings;

  factory _$HealthProfileResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthProfileResponseImplFromJson(json);

  @override
  final String range;
  @override
  final String groupBy;
  final List<HealthSeries> _series;
  @override
  List<HealthSeries> get series {
    if (_series is EqualUnmodifiableListView) return _series;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_series);
  }

  final List<LabTestGroup> _labTestGroups;
  @override
  List<LabTestGroup> get labTestGroups {
    if (_labTestGroups is EqualUnmodifiableListView) return _labTestGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labTestGroups);
  }

  final List<PdfOnlyBooking> _pdfOnlyBookings;
  @override
  List<PdfOnlyBooking> get pdfOnlyBookings {
    if (_pdfOnlyBookings is EqualUnmodifiableListView) return _pdfOnlyBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pdfOnlyBookings);
  }

  @override
  final bool hasStructuredData;
  @override
  final String disclaimer;

  @override
  String toString() {
    return 'HealthProfileResponse(range: $range, groupBy: $groupBy, series: $series, labTestGroups: $labTestGroups, pdfOnlyBookings: $pdfOnlyBookings, hasStructuredData: $hasStructuredData, disclaimer: $disclaimer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthProfileResponseImpl &&
            (identical(other.range, range) || other.range == range) &&
            (identical(other.groupBy, groupBy) || other.groupBy == groupBy) &&
            const DeepCollectionEquality().equals(other._series, _series) &&
            const DeepCollectionEquality()
                .equals(other._labTestGroups, _labTestGroups) &&
            const DeepCollectionEquality()
                .equals(other._pdfOnlyBookings, _pdfOnlyBookings) &&
            (identical(other.hasStructuredData, hasStructuredData) ||
                other.hasStructuredData == hasStructuredData) &&
            (identical(other.disclaimer, disclaimer) ||
                other.disclaimer == disclaimer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      range,
      groupBy,
      const DeepCollectionEquality().hash(_series),
      const DeepCollectionEquality().hash(_labTestGroups),
      const DeepCollectionEquality().hash(_pdfOnlyBookings),
      hasStructuredData,
      disclaimer);

  /// Create a copy of HealthProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthProfileResponseImplCopyWith<_$HealthProfileResponseImpl>
      get copyWith => __$$HealthProfileResponseImplCopyWithImpl<
          _$HealthProfileResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthProfileResponseImplToJson(
      this,
    );
  }
}

abstract class _HealthProfileResponse implements HealthProfileResponse {
  const factory _HealthProfileResponse(
      {required final String range,
      required final String groupBy,
      required final List<HealthSeries> series,
      required final List<LabTestGroup> labTestGroups,
      required final List<PdfOnlyBooking> pdfOnlyBookings,
      required final bool hasStructuredData,
      required final String disclaimer}) = _$HealthProfileResponseImpl;

  factory _HealthProfileResponse.fromJson(Map<String, dynamic> json) =
      _$HealthProfileResponseImpl.fromJson;

  @override
  String get range;
  @override
  String get groupBy;
  @override
  List<HealthSeries> get series;
  @override
  List<LabTestGroup> get labTestGroups;
  @override
  List<PdfOnlyBooking> get pdfOnlyBookings;
  @override
  bool get hasStructuredData;
  @override
  String get disclaimer;

  /// Create a copy of HealthProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthProfileResponseImplCopyWith<_$HealthProfileResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
