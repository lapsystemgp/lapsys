// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkspaceBookingLab _$WorkspaceBookingLabFromJson(Map<String, dynamic> json) {
  return _WorkspaceBookingLab.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceBookingLab {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceBookingLab to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceBookingLabCopyWith<WorkspaceBookingLab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceBookingLabCopyWith<$Res> {
  factory $WorkspaceBookingLabCopyWith(
          WorkspaceBookingLab value, $Res Function(WorkspaceBookingLab) then) =
      _$WorkspaceBookingLabCopyWithImpl<$Res, WorkspaceBookingLab>;
  @useResult
  $Res call({String id, String name, String address});
}

/// @nodoc
class _$WorkspaceBookingLabCopyWithImpl<$Res, $Val extends WorkspaceBookingLab>
    implements $WorkspaceBookingLabCopyWith<$Res> {
  _$WorkspaceBookingLabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceBookingLabImplCopyWith<$Res>
    implements $WorkspaceBookingLabCopyWith<$Res> {
  factory _$$WorkspaceBookingLabImplCopyWith(_$WorkspaceBookingLabImpl value,
          $Res Function(_$WorkspaceBookingLabImpl) then) =
      __$$WorkspaceBookingLabImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String address});
}

/// @nodoc
class __$$WorkspaceBookingLabImplCopyWithImpl<$Res>
    extends _$WorkspaceBookingLabCopyWithImpl<$Res, _$WorkspaceBookingLabImpl>
    implements _$$WorkspaceBookingLabImplCopyWith<$Res> {
  __$$WorkspaceBookingLabImplCopyWithImpl(_$WorkspaceBookingLabImpl _value,
      $Res Function(_$WorkspaceBookingLabImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
  }) {
    return _then(_$WorkspaceBookingLabImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceBookingLabImpl implements _WorkspaceBookingLab {
  const _$WorkspaceBookingLabImpl(
      {required this.id, required this.name, required this.address});

  factory _$WorkspaceBookingLabImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceBookingLabImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;

  @override
  String toString() {
    return 'WorkspaceBookingLab(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceBookingLabImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, address);

  /// Create a copy of WorkspaceBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceBookingLabImplCopyWith<_$WorkspaceBookingLabImpl> get copyWith =>
      __$$WorkspaceBookingLabImplCopyWithImpl<_$WorkspaceBookingLabImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceBookingLabImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceBookingLab implements WorkspaceBookingLab {
  const factory _WorkspaceBookingLab(
      {required final String id,
      required final String name,
      required final String address}) = _$WorkspaceBookingLabImpl;

  factory _WorkspaceBookingLab.fromJson(Map<String, dynamic> json) =
      _$WorkspaceBookingLabImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;

  /// Create a copy of WorkspaceBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceBookingLabImplCopyWith<_$WorkspaceBookingLabImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceBookingTest _$WorkspaceBookingTestFromJson(Map<String, dynamic> json) {
  return _WorkspaceBookingTest.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceBookingTest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceBookingTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceBookingTestCopyWith<WorkspaceBookingTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceBookingTestCopyWith<$Res> {
  factory $WorkspaceBookingTestCopyWith(WorkspaceBookingTest value,
          $Res Function(WorkspaceBookingTest) then) =
      _$WorkspaceBookingTestCopyWithImpl<$Res, WorkspaceBookingTest>;
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class _$WorkspaceBookingTestCopyWithImpl<$Res,
        $Val extends WorkspaceBookingTest>
    implements $WorkspaceBookingTestCopyWith<$Res> {
  _$WorkspaceBookingTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? priceEgp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceBookingTestImplCopyWith<$Res>
    implements $WorkspaceBookingTestCopyWith<$Res> {
  factory _$$WorkspaceBookingTestImplCopyWith(_$WorkspaceBookingTestImpl value,
          $Res Function(_$WorkspaceBookingTestImpl) then) =
      __$$WorkspaceBookingTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class __$$WorkspaceBookingTestImplCopyWithImpl<$Res>
    extends _$WorkspaceBookingTestCopyWithImpl<$Res, _$WorkspaceBookingTestImpl>
    implements _$$WorkspaceBookingTestImplCopyWith<$Res> {
  __$$WorkspaceBookingTestImplCopyWithImpl(_$WorkspaceBookingTestImpl _value,
      $Res Function(_$WorkspaceBookingTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? priceEgp = null,
  }) {
    return _then(_$WorkspaceBookingTestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceBookingTestImpl implements _WorkspaceBookingTest {
  const _$WorkspaceBookingTestImpl(
      {required this.id, required this.name, required this.priceEgp});

  factory _$WorkspaceBookingTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceBookingTestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int priceEgp;

  @override
  String toString() {
    return 'WorkspaceBookingTest(id: $id, name: $name, priceEgp: $priceEgp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceBookingTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, priceEgp);

  /// Create a copy of WorkspaceBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceBookingTestImplCopyWith<_$WorkspaceBookingTestImpl>
      get copyWith =>
          __$$WorkspaceBookingTestImplCopyWithImpl<_$WorkspaceBookingTestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceBookingTestImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceBookingTest implements WorkspaceBookingTest {
  const factory _WorkspaceBookingTest(
      {required final String id,
      required final String name,
      required final int priceEgp}) = _$WorkspaceBookingTestImpl;

  factory _WorkspaceBookingTest.fromJson(Map<String, dynamic> json) =
      _$WorkspaceBookingTestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get priceEgp;

  /// Create a copy of WorkspaceBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceBookingTestImplCopyWith<_$WorkspaceBookingTestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkspaceTimelineEntry _$WorkspaceTimelineEntryFromJson(
    Map<String, dynamic> json) {
  return _WorkspaceTimelineEntry.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceTimelineEntry {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceTimelineEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceTimelineEntryCopyWith<WorkspaceTimelineEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceTimelineEntryCopyWith<$Res> {
  factory $WorkspaceTimelineEntryCopyWith(WorkspaceTimelineEntry value,
          $Res Function(WorkspaceTimelineEntry) then) =
      _$WorkspaceTimelineEntryCopyWithImpl<$Res, WorkspaceTimelineEntry>;
  @useResult
  $Res call({String id, String status, String? note, String createdAt});
}

/// @nodoc
class _$WorkspaceTimelineEntryCopyWithImpl<$Res,
        $Val extends WorkspaceTimelineEntry>
    implements $WorkspaceTimelineEntryCopyWith<$Res> {
  _$WorkspaceTimelineEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceTimelineEntryImplCopyWith<$Res>
    implements $WorkspaceTimelineEntryCopyWith<$Res> {
  factory _$$WorkspaceTimelineEntryImplCopyWith(
          _$WorkspaceTimelineEntryImpl value,
          $Res Function(_$WorkspaceTimelineEntryImpl) then) =
      __$$WorkspaceTimelineEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String status, String? note, String createdAt});
}

/// @nodoc
class __$$WorkspaceTimelineEntryImplCopyWithImpl<$Res>
    extends _$WorkspaceTimelineEntryCopyWithImpl<$Res,
        _$WorkspaceTimelineEntryImpl>
    implements _$$WorkspaceTimelineEntryImplCopyWith<$Res> {
  __$$WorkspaceTimelineEntryImplCopyWithImpl(
      _$WorkspaceTimelineEntryImpl _value,
      $Res Function(_$WorkspaceTimelineEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$WorkspaceTimelineEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceTimelineEntryImpl implements _WorkspaceTimelineEntry {
  const _$WorkspaceTimelineEntryImpl(
      {required this.id,
      required this.status,
      this.note,
      required this.createdAt});

  factory _$WorkspaceTimelineEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceTimelineEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final String? note;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'WorkspaceTimelineEntry(id: $id, status: $status, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceTimelineEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, note, createdAt);

  /// Create a copy of WorkspaceTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceTimelineEntryImplCopyWith<_$WorkspaceTimelineEntryImpl>
      get copyWith => __$$WorkspaceTimelineEntryImplCopyWithImpl<
          _$WorkspaceTimelineEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceTimelineEntryImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceTimelineEntry implements WorkspaceTimelineEntry {
  const factory _WorkspaceTimelineEntry(
      {required final String id,
      required final String status,
      final String? note,
      required final String createdAt}) = _$WorkspaceTimelineEntryImpl;

  factory _WorkspaceTimelineEntry.fromJson(Map<String, dynamic> json) =
      _$WorkspaceTimelineEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  String? get note;
  @override
  String get createdAt;

  /// Create a copy of WorkspaceTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceTimelineEntryImplCopyWith<_$WorkspaceTimelineEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkspaceBooking _$WorkspaceBookingFromJson(Map<String, dynamic> json) {
  return _WorkspaceBooking.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceBooking {
  String get id => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  BookingType get bookingType => throw _privateConstructorUsedError;
  String get scheduledAt => throw _privateConstructorUsedError;
  int get totalPriceEgp => throw _privateConstructorUsedError;
  String? get homeAddress => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  String? get paymentReference => throw _privateConstructorUsedError;
  String? get paymentPaidAt => throw _privateConstructorUsedError;
  String? get paymentFailedAt => throw _privateConstructorUsedError;
  String? get paymentFailureReason => throw _privateConstructorUsedError;
  KitStatus? get kitStatus => throw _privateConstructorUsedError;
  String? get kitTrackingNumber => throw _privateConstructorUsedError;
  String? get kitShippedAt => throw _privateConstructorUsedError;
  String? get kitDeliveredAt => throw _privateConstructorUsedError;
  String? get sampleReceivedAt => throw _privateConstructorUsedError;
  WorkspaceBookingLab get lab => throw _privateConstructorUsedError;
  WorkspaceBookingTest get test => throw _privateConstructorUsedError;
  List<WorkspaceTimelineEntry> get timeline =>
      throw _privateConstructorUsedError;

  /// Serializes this WorkspaceBooking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceBookingCopyWith<WorkspaceBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceBookingCopyWith<$Res> {
  factory $WorkspaceBookingCopyWith(
          WorkspaceBooking value, $Res Function(WorkspaceBooking) then) =
      _$WorkspaceBookingCopyWithImpl<$Res, WorkspaceBooking>;
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      BookingType bookingType,
      String scheduledAt,
      int totalPriceEgp,
      String? homeAddress,
      PaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      String? paymentReference,
      String? paymentPaidAt,
      String? paymentFailedAt,
      String? paymentFailureReason,
      KitStatus? kitStatus,
      String? kitTrackingNumber,
      String? kitShippedAt,
      String? kitDeliveredAt,
      String? sampleReceivedAt,
      WorkspaceBookingLab lab,
      WorkspaceBookingTest test,
      List<WorkspaceTimelineEntry> timeline});

  $WorkspaceBookingLabCopyWith<$Res> get lab;
  $WorkspaceBookingTestCopyWith<$Res> get test;
}

/// @nodoc
class _$WorkspaceBookingCopyWithImpl<$Res, $Val extends WorkspaceBooking>
    implements $WorkspaceBookingCopyWith<$Res> {
  _$WorkspaceBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? bookingType = null,
    Object? scheduledAt = null,
    Object? totalPriceEgp = null,
    Object? homeAddress = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? paymentReference = freezed,
    Object? paymentPaidAt = freezed,
    Object? paymentFailedAt = freezed,
    Object? paymentFailureReason = freezed,
    Object? kitStatus = freezed,
    Object? kitTrackingNumber = freezed,
    Object? kitShippedAt = freezed,
    Object? kitDeliveredAt = freezed,
    Object? sampleReceivedAt = freezed,
    Object? lab = null,
    Object? test = null,
    Object? timeline = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      bookingType: null == bookingType
          ? _value.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
              as BookingType,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      totalPriceEgp: null == totalPriceEgp
          ? _value.totalPriceEgp
          : totalPriceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      homeAddress: freezed == homeAddress
          ? _value.homeAddress
          : homeAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentPaidAt: freezed == paymentPaidAt
          ? _value.paymentPaidAt
          : paymentPaidAt // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentFailedAt: freezed == paymentFailedAt
          ? _value.paymentFailedAt
          : paymentFailedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentFailureReason: freezed == paymentFailureReason
          ? _value.paymentFailureReason
          : paymentFailureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      kitStatus: freezed == kitStatus
          ? _value.kitStatus
          : kitStatus // ignore: cast_nullable_to_non_nullable
              as KitStatus?,
      kitTrackingNumber: freezed == kitTrackingNumber
          ? _value.kitTrackingNumber
          : kitTrackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      kitShippedAt: freezed == kitShippedAt
          ? _value.kitShippedAt
          : kitShippedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      kitDeliveredAt: freezed == kitDeliveredAt
          ? _value.kitDeliveredAt
          : kitDeliveredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      sampleReceivedAt: freezed == sampleReceivedAt
          ? _value.sampleReceivedAt
          : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookingLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookingTest,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceTimelineEntry>,
    ) as $Val);
  }

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkspaceBookingLabCopyWith<$Res> get lab {
    return $WorkspaceBookingLabCopyWith<$Res>(_value.lab, (value) {
      return _then(_value.copyWith(lab: value) as $Val);
    });
  }

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkspaceBookingTestCopyWith<$Res> get test {
    return $WorkspaceBookingTestCopyWith<$Res>(_value.test, (value) {
      return _then(_value.copyWith(test: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkspaceBookingImplCopyWith<$Res>
    implements $WorkspaceBookingCopyWith<$Res> {
  factory _$$WorkspaceBookingImplCopyWith(_$WorkspaceBookingImpl value,
          $Res Function(_$WorkspaceBookingImpl) then) =
      __$$WorkspaceBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      BookingType bookingType,
      String scheduledAt,
      int totalPriceEgp,
      String? homeAddress,
      PaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      String? paymentReference,
      String? paymentPaidAt,
      String? paymentFailedAt,
      String? paymentFailureReason,
      KitStatus? kitStatus,
      String? kitTrackingNumber,
      String? kitShippedAt,
      String? kitDeliveredAt,
      String? sampleReceivedAt,
      WorkspaceBookingLab lab,
      WorkspaceBookingTest test,
      List<WorkspaceTimelineEntry> timeline});

  @override
  $WorkspaceBookingLabCopyWith<$Res> get lab;
  @override
  $WorkspaceBookingTestCopyWith<$Res> get test;
}

/// @nodoc
class __$$WorkspaceBookingImplCopyWithImpl<$Res>
    extends _$WorkspaceBookingCopyWithImpl<$Res, _$WorkspaceBookingImpl>
    implements _$$WorkspaceBookingImplCopyWith<$Res> {
  __$$WorkspaceBookingImplCopyWithImpl(_$WorkspaceBookingImpl _value,
      $Res Function(_$WorkspaceBookingImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? bookingType = null,
    Object? scheduledAt = null,
    Object? totalPriceEgp = null,
    Object? homeAddress = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? paymentReference = freezed,
    Object? paymentPaidAt = freezed,
    Object? paymentFailedAt = freezed,
    Object? paymentFailureReason = freezed,
    Object? kitStatus = freezed,
    Object? kitTrackingNumber = freezed,
    Object? kitShippedAt = freezed,
    Object? kitDeliveredAt = freezed,
    Object? sampleReceivedAt = freezed,
    Object? lab = null,
    Object? test = null,
    Object? timeline = null,
  }) {
    return _then(_$WorkspaceBookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      bookingType: null == bookingType
          ? _value.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
              as BookingType,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      totalPriceEgp: null == totalPriceEgp
          ? _value.totalPriceEgp
          : totalPriceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      homeAddress: freezed == homeAddress
          ? _value.homeAddress
          : homeAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentPaidAt: freezed == paymentPaidAt
          ? _value.paymentPaidAt
          : paymentPaidAt // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentFailedAt: freezed == paymentFailedAt
          ? _value.paymentFailedAt
          : paymentFailedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentFailureReason: freezed == paymentFailureReason
          ? _value.paymentFailureReason
          : paymentFailureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      kitStatus: freezed == kitStatus
          ? _value.kitStatus
          : kitStatus // ignore: cast_nullable_to_non_nullable
              as KitStatus?,
      kitTrackingNumber: freezed == kitTrackingNumber
          ? _value.kitTrackingNumber
          : kitTrackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      kitShippedAt: freezed == kitShippedAt
          ? _value.kitShippedAt
          : kitShippedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      kitDeliveredAt: freezed == kitDeliveredAt
          ? _value.kitDeliveredAt
          : kitDeliveredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      sampleReceivedAt: freezed == sampleReceivedAt
          ? _value.sampleReceivedAt
          : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookingLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookingTest,
      timeline: null == timeline
          ? _value._timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceTimelineEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceBookingImpl implements _WorkspaceBooking {
  const _$WorkspaceBookingImpl(
      {required this.id,
      required this.status,
      required this.bookingType,
      required this.scheduledAt,
      required this.totalPriceEgp,
      this.homeAddress,
      required this.paymentMethod,
      required this.paymentStatus,
      this.paymentReference,
      this.paymentPaidAt,
      this.paymentFailedAt,
      this.paymentFailureReason,
      this.kitStatus,
      this.kitTrackingNumber,
      this.kitShippedAt,
      this.kitDeliveredAt,
      this.sampleReceivedAt,
      required this.lab,
      required this.test,
      required final List<WorkspaceTimelineEntry> timeline})
      : _timeline = timeline;

  factory _$WorkspaceBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceBookingImplFromJson(json);

  @override
  final String id;
  @override
  final BookingStatus status;
  @override
  final BookingType bookingType;
  @override
  final String scheduledAt;
  @override
  final int totalPriceEgp;
  @override
  final String? homeAddress;
  @override
  final PaymentMethod paymentMethod;
  @override
  final PaymentStatus paymentStatus;
  @override
  final String? paymentReference;
  @override
  final String? paymentPaidAt;
  @override
  final String? paymentFailedAt;
  @override
  final String? paymentFailureReason;
  @override
  final KitStatus? kitStatus;
  @override
  final String? kitTrackingNumber;
  @override
  final String? kitShippedAt;
  @override
  final String? kitDeliveredAt;
  @override
  final String? sampleReceivedAt;
  @override
  final WorkspaceBookingLab lab;
  @override
  final WorkspaceBookingTest test;
  final List<WorkspaceTimelineEntry> _timeline;
  @override
  List<WorkspaceTimelineEntry> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  String toString() {
    return 'WorkspaceBooking(id: $id, status: $status, bookingType: $bookingType, scheduledAt: $scheduledAt, totalPriceEgp: $totalPriceEgp, homeAddress: $homeAddress, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentPaidAt: $paymentPaidAt, paymentFailedAt: $paymentFailedAt, paymentFailureReason: $paymentFailureReason, kitStatus: $kitStatus, kitTrackingNumber: $kitTrackingNumber, kitShippedAt: $kitShippedAt, kitDeliveredAt: $kitDeliveredAt, sampleReceivedAt: $sampleReceivedAt, lab: $lab, test: $test, timeline: $timeline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.totalPriceEgp, totalPriceEgp) ||
                other.totalPriceEgp == totalPriceEgp) &&
            (identical(other.homeAddress, homeAddress) ||
                other.homeAddress == homeAddress) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentReference, paymentReference) ||
                other.paymentReference == paymentReference) &&
            (identical(other.paymentPaidAt, paymentPaidAt) ||
                other.paymentPaidAt == paymentPaidAt) &&
            (identical(other.paymentFailedAt, paymentFailedAt) ||
                other.paymentFailedAt == paymentFailedAt) &&
            (identical(other.paymentFailureReason, paymentFailureReason) ||
                other.paymentFailureReason == paymentFailureReason) &&
            (identical(other.kitStatus, kitStatus) ||
                other.kitStatus == kitStatus) &&
            (identical(other.kitTrackingNumber, kitTrackingNumber) ||
                other.kitTrackingNumber == kitTrackingNumber) &&
            (identical(other.kitShippedAt, kitShippedAt) ||
                other.kitShippedAt == kitShippedAt) &&
            (identical(other.kitDeliveredAt, kitDeliveredAt) ||
                other.kitDeliveredAt == kitDeliveredAt) &&
            (identical(other.sampleReceivedAt, sampleReceivedAt) ||
                other.sampleReceivedAt == sampleReceivedAt) &&
            (identical(other.lab, lab) || other.lab == lab) &&
            (identical(other.test, test) || other.test == test) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        status,
        bookingType,
        scheduledAt,
        totalPriceEgp,
        homeAddress,
        paymentMethod,
        paymentStatus,
        paymentReference,
        paymentPaidAt,
        paymentFailedAt,
        paymentFailureReason,
        kitStatus,
        kitTrackingNumber,
        kitShippedAt,
        kitDeliveredAt,
        sampleReceivedAt,
        lab,
        test,
        const DeepCollectionEquality().hash(_timeline)
      ]);

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceBookingImplCopyWith<_$WorkspaceBookingImpl> get copyWith =>
      __$$WorkspaceBookingImplCopyWithImpl<_$WorkspaceBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceBookingImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceBooking implements WorkspaceBooking {
  const factory _WorkspaceBooking(
          {required final String id,
          required final BookingStatus status,
          required final BookingType bookingType,
          required final String scheduledAt,
          required final int totalPriceEgp,
          final String? homeAddress,
          required final PaymentMethod paymentMethod,
          required final PaymentStatus paymentStatus,
          final String? paymentReference,
          final String? paymentPaidAt,
          final String? paymentFailedAt,
          final String? paymentFailureReason,
          final KitStatus? kitStatus,
          final String? kitTrackingNumber,
          final String? kitShippedAt,
          final String? kitDeliveredAt,
          final String? sampleReceivedAt,
          required final WorkspaceBookingLab lab,
          required final WorkspaceBookingTest test,
          required final List<WorkspaceTimelineEntry> timeline}) =
      _$WorkspaceBookingImpl;

  factory _WorkspaceBooking.fromJson(Map<String, dynamic> json) =
      _$WorkspaceBookingImpl.fromJson;

  @override
  String get id;
  @override
  BookingStatus get status;
  @override
  BookingType get bookingType;
  @override
  String get scheduledAt;
  @override
  int get totalPriceEgp;
  @override
  String? get homeAddress;
  @override
  PaymentMethod get paymentMethod;
  @override
  PaymentStatus get paymentStatus;
  @override
  String? get paymentReference;
  @override
  String? get paymentPaidAt;
  @override
  String? get paymentFailedAt;
  @override
  String? get paymentFailureReason;
  @override
  KitStatus? get kitStatus;
  @override
  String? get kitTrackingNumber;
  @override
  String? get kitShippedAt;
  @override
  String? get kitDeliveredAt;
  @override
  String? get sampleReceivedAt;
  @override
  WorkspaceBookingLab get lab;
  @override
  WorkspaceBookingTest get test;
  @override
  List<WorkspaceTimelineEntry> get timeline;

  /// Create a copy of WorkspaceBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceBookingImplCopyWith<_$WorkspaceBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResultFile _$ResultFileFromJson(Map<String, dynamic> json) {
  return _ResultFile.fromJson(json);
}

/// @nodoc
mixin _$ResultFile {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this ResultFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultFileCopyWith<ResultFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultFileCopyWith<$Res> {
  factory $ResultFileCopyWith(
          ResultFile value, $Res Function(ResultFile) then) =
      _$ResultFileCopyWithImpl<$Res, ResultFile>;
  @useResult
  $Res call(
      {String id,
      String fileName,
      String fileUrl,
      String mimeType,
      int sizeBytes,
      String uploadedAt});
}

/// @nodoc
class _$ResultFileCopyWithImpl<$Res, $Val extends ResultFile>
    implements $ResultFileCopyWith<$Res> {
  _$ResultFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? uploadedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultFileImplCopyWith<$Res>
    implements $ResultFileCopyWith<$Res> {
  factory _$$ResultFileImplCopyWith(
          _$ResultFileImpl value, $Res Function(_$ResultFileImpl) then) =
      __$$ResultFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fileName,
      String fileUrl,
      String mimeType,
      int sizeBytes,
      String uploadedAt});
}

/// @nodoc
class __$$ResultFileImplCopyWithImpl<$Res>
    extends _$ResultFileCopyWithImpl<$Res, _$ResultFileImpl>
    implements _$$ResultFileImplCopyWith<$Res> {
  __$$ResultFileImplCopyWithImpl(
      _$ResultFileImpl _value, $Res Function(_$ResultFileImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? uploadedAt = null,
  }) {
    return _then(_$ResultFileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultFileImpl implements _ResultFile {
  const _$ResultFileImpl(
      {required this.id,
      required this.fileName,
      required this.fileUrl,
      required this.mimeType,
      required this.sizeBytes,
      required this.uploadedAt});

  factory _$ResultFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultFileImplFromJson(json);

  @override
  final String id;
  @override
  final String fileName;
  @override
  final String fileUrl;
  @override
  final String mimeType;
  @override
  final int sizeBytes;
  @override
  final String uploadedAt;

  @override
  String toString() {
    return 'ResultFile(id: $id, fileName: $fileName, fileUrl: $fileUrl, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultFileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, fileName, fileUrl, mimeType, sizeBytes, uploadedAt);

  /// Create a copy of ResultFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultFileImplCopyWith<_$ResultFileImpl> get copyWith =>
      __$$ResultFileImplCopyWithImpl<_$ResultFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultFileImplToJson(
      this,
    );
  }
}

abstract class _ResultFile implements ResultFile {
  const factory _ResultFile(
      {required final String id,
      required final String fileName,
      required final String fileUrl,
      required final String mimeType,
      required final int sizeBytes,
      required final String uploadedAt}) = _$ResultFileImpl;

  factory _ResultFile.fromJson(Map<String, dynamic> json) =
      _$ResultFileImpl.fromJson;

  @override
  String get id;
  @override
  String get fileName;
  @override
  String get fileUrl;
  @override
  String get mimeType;
  @override
  int get sizeBytes;
  @override
  String get uploadedAt;

  /// Create a copy of ResultFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultFileImplCopyWith<_$ResultFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SummaryHighlightItem _$SummaryHighlightItemFromJson(Map<String, dynamic> json) {
  return _SummaryHighlightItem.fromJson(json);
}

/// @nodoc
mixin _$SummaryHighlightItem {
  String get key => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;

  /// Serializes this SummaryHighlightItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SummaryHighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryHighlightItemCopyWith<SummaryHighlightItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryHighlightItemCopyWith<$Res> {
  factory $SummaryHighlightItemCopyWith(SummaryHighlightItem value,
          $Res Function(SummaryHighlightItem) then) =
      _$SummaryHighlightItemCopyWithImpl<$Res, SummaryHighlightItem>;
  @useResult
  $Res call({String key, String label, String value, String kind});
}

/// @nodoc
class _$SummaryHighlightItemCopyWithImpl<$Res,
        $Val extends SummaryHighlightItem>
    implements $SummaryHighlightItemCopyWith<$Res> {
  _$SummaryHighlightItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SummaryHighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? value = null,
    Object? kind = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SummaryHighlightItemImplCopyWith<$Res>
    implements $SummaryHighlightItemCopyWith<$Res> {
  factory _$$SummaryHighlightItemImplCopyWith(_$SummaryHighlightItemImpl value,
          $Res Function(_$SummaryHighlightItemImpl) then) =
      __$$SummaryHighlightItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String label, String value, String kind});
}

/// @nodoc
class __$$SummaryHighlightItemImplCopyWithImpl<$Res>
    extends _$SummaryHighlightItemCopyWithImpl<$Res, _$SummaryHighlightItemImpl>
    implements _$$SummaryHighlightItemImplCopyWith<$Res> {
  __$$SummaryHighlightItemImplCopyWithImpl(_$SummaryHighlightItemImpl _value,
      $Res Function(_$SummaryHighlightItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SummaryHighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? value = null,
    Object? kind = null,
  }) {
    return _then(_$SummaryHighlightItemImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryHighlightItemImpl implements _SummaryHighlightItem {
  const _$SummaryHighlightItemImpl(
      {required this.key,
      required this.label,
      required this.value,
      required this.kind});

  factory _$SummaryHighlightItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryHighlightItemImplFromJson(json);

  @override
  final String key;
  @override
  final String label;
  @override
  final String value;
  @override
  final String kind;

  @override
  String toString() {
    return 'SummaryHighlightItem(key: $key, label: $label, value: $value, kind: $kind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryHighlightItemImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, label, value, kind);

  /// Create a copy of SummaryHighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryHighlightItemImplCopyWith<_$SummaryHighlightItemImpl>
      get copyWith =>
          __$$SummaryHighlightItemImplCopyWithImpl<_$SummaryHighlightItemImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryHighlightItemImplToJson(
      this,
    );
  }
}

abstract class _SummaryHighlightItem implements SummaryHighlightItem {
  const factory _SummaryHighlightItem(
      {required final String key,
      required final String label,
      required final String value,
      required final String kind}) = _$SummaryHighlightItemImpl;

  factory _SummaryHighlightItem.fromJson(Map<String, dynamic> json) =
      _$SummaryHighlightItemImpl.fromJson;

  @override
  String get key;
  @override
  String get label;
  @override
  String get value;
  @override
  String get kind;

  /// Create a copy of SummaryHighlightItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryHighlightItemImplCopyWith<_$SummaryHighlightItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SummaryHighlights _$SummaryHighlightsFromJson(Map<String, dynamic> json) {
  return _SummaryHighlights.fromJson(json);
}

/// @nodoc
mixin _$SummaryHighlights {
  List<SummaryHighlightItem> get items => throw _privateConstructorUsedError;

  /// Serializes this SummaryHighlights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SummaryHighlights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryHighlightsCopyWith<SummaryHighlights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryHighlightsCopyWith<$Res> {
  factory $SummaryHighlightsCopyWith(
          SummaryHighlights value, $Res Function(SummaryHighlights) then) =
      _$SummaryHighlightsCopyWithImpl<$Res, SummaryHighlights>;
  @useResult
  $Res call({List<SummaryHighlightItem> items});
}

/// @nodoc
class _$SummaryHighlightsCopyWithImpl<$Res, $Val extends SummaryHighlights>
    implements $SummaryHighlightsCopyWith<$Res> {
  _$SummaryHighlightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SummaryHighlights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SummaryHighlightItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SummaryHighlightsImplCopyWith<$Res>
    implements $SummaryHighlightsCopyWith<$Res> {
  factory _$$SummaryHighlightsImplCopyWith(_$SummaryHighlightsImpl value,
          $Res Function(_$SummaryHighlightsImpl) then) =
      __$$SummaryHighlightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SummaryHighlightItem> items});
}

/// @nodoc
class __$$SummaryHighlightsImplCopyWithImpl<$Res>
    extends _$SummaryHighlightsCopyWithImpl<$Res, _$SummaryHighlightsImpl>
    implements _$$SummaryHighlightsImplCopyWith<$Res> {
  __$$SummaryHighlightsImplCopyWithImpl(_$SummaryHighlightsImpl _value,
      $Res Function(_$SummaryHighlightsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SummaryHighlights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$SummaryHighlightsImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SummaryHighlightItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryHighlightsImpl implements _SummaryHighlights {
  const _$SummaryHighlightsImpl(
      {required final List<SummaryHighlightItem> items})
      : _items = items;

  factory _$SummaryHighlightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryHighlightsImplFromJson(json);

  final List<SummaryHighlightItem> _items;
  @override
  List<SummaryHighlightItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'SummaryHighlights(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryHighlightsImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of SummaryHighlights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryHighlightsImplCopyWith<_$SummaryHighlightsImpl> get copyWith =>
      __$$SummaryHighlightsImplCopyWithImpl<_$SummaryHighlightsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryHighlightsImplToJson(
      this,
    );
  }
}

abstract class _SummaryHighlights implements SummaryHighlights {
  const factory _SummaryHighlights(
          {required final List<SummaryHighlightItem> items}) =
      _$SummaryHighlightsImpl;

  factory _SummaryHighlights.fromJson(Map<String, dynamic> json) =
      _$SummaryHighlightsImpl.fromJson;

  @override
  List<SummaryHighlightItem> get items;

  /// Create a copy of SummaryHighlights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryHighlightsImplCopyWith<_$SummaryHighlightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResultSummary _$ResultSummaryFromJson(Map<String, dynamic> json) {
  return _ResultSummary.fromJson(json);
}

/// @nodoc
mixin _$ResultSummary {
  String get summary => throw _privateConstructorUsedError;
  SummaryHighlights get highlights => throw _privateConstructorUsedError;

  /// Serializes this ResultSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultSummaryCopyWith<ResultSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultSummaryCopyWith<$Res> {
  factory $ResultSummaryCopyWith(
          ResultSummary value, $Res Function(ResultSummary) then) =
      _$ResultSummaryCopyWithImpl<$Res, ResultSummary>;
  @useResult
  $Res call({String summary, SummaryHighlights highlights});

  $SummaryHighlightsCopyWith<$Res> get highlights;
}

/// @nodoc
class _$ResultSummaryCopyWithImpl<$Res, $Val extends ResultSummary>
    implements $ResultSummaryCopyWith<$Res> {
  _$ResultSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? highlights = null,
  }) {
    return _then(_value.copyWith(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as SummaryHighlights,
    ) as $Val);
  }

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryHighlightsCopyWith<$Res> get highlights {
    return $SummaryHighlightsCopyWith<$Res>(_value.highlights, (value) {
      return _then(_value.copyWith(highlights: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResultSummaryImplCopyWith<$Res>
    implements $ResultSummaryCopyWith<$Res> {
  factory _$$ResultSummaryImplCopyWith(
          _$ResultSummaryImpl value, $Res Function(_$ResultSummaryImpl) then) =
      __$$ResultSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String summary, SummaryHighlights highlights});

  @override
  $SummaryHighlightsCopyWith<$Res> get highlights;
}

/// @nodoc
class __$$ResultSummaryImplCopyWithImpl<$Res>
    extends _$ResultSummaryCopyWithImpl<$Res, _$ResultSummaryImpl>
    implements _$$ResultSummaryImplCopyWith<$Res> {
  __$$ResultSummaryImplCopyWithImpl(
      _$ResultSummaryImpl _value, $Res Function(_$ResultSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? highlights = null,
  }) {
    return _then(_$ResultSummaryImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as SummaryHighlights,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultSummaryImpl implements _ResultSummary {
  const _$ResultSummaryImpl({required this.summary, required this.highlights});

  factory _$ResultSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultSummaryImplFromJson(json);

  @override
  final String summary;
  @override
  final SummaryHighlights highlights;

  @override
  String toString() {
    return 'ResultSummary(summary: $summary, highlights: $highlights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultSummaryImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.highlights, highlights) ||
                other.highlights == highlights));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, summary, highlights);

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultSummaryImplCopyWith<_$ResultSummaryImpl> get copyWith =>
      __$$ResultSummaryImplCopyWithImpl<_$ResultSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultSummaryImplToJson(
      this,
    );
  }
}

abstract class _ResultSummary implements ResultSummary {
  const factory _ResultSummary(
      {required final String summary,
      required final SummaryHighlights highlights}) = _$ResultSummaryImpl;

  factory _ResultSummary.fromJson(Map<String, dynamic> json) =
      _$ResultSummaryImpl.fromJson;

  @override
  String get summary;
  @override
  SummaryHighlights get highlights;

  /// Create a copy of ResultSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultSummaryImplCopyWith<_$ResultSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceResultReview _$WorkspaceResultReviewFromJson(
    Map<String, dynamic> json) {
  return _WorkspaceResultReview.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceResultReview {
  String get id => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  ReviewStatus get status => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceResultReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceResultReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceResultReviewCopyWith<WorkspaceResultReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceResultReviewCopyWith<$Res> {
  factory $WorkspaceResultReviewCopyWith(WorkspaceResultReview value,
          $Res Function(WorkspaceResultReview) then) =
      _$WorkspaceResultReviewCopyWithImpl<$Res, WorkspaceResultReview>;
  @useResult
  $Res call(
      {String id,
      int rating,
      String? comment,
      ReviewStatus status,
      String createdAt});
}

/// @nodoc
class _$WorkspaceResultReviewCopyWithImpl<$Res,
        $Val extends WorkspaceResultReview>
    implements $WorkspaceResultReviewCopyWith<$Res> {
  _$WorkspaceResultReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceResultReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReviewStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceResultReviewImplCopyWith<$Res>
    implements $WorkspaceResultReviewCopyWith<$Res> {
  factory _$$WorkspaceResultReviewImplCopyWith(
          _$WorkspaceResultReviewImpl value,
          $Res Function(_$WorkspaceResultReviewImpl) then) =
      __$$WorkspaceResultReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int rating,
      String? comment,
      ReviewStatus status,
      String createdAt});
}

/// @nodoc
class __$$WorkspaceResultReviewImplCopyWithImpl<$Res>
    extends _$WorkspaceResultReviewCopyWithImpl<$Res,
        _$WorkspaceResultReviewImpl>
    implements _$$WorkspaceResultReviewImplCopyWith<$Res> {
  __$$WorkspaceResultReviewImplCopyWithImpl(_$WorkspaceResultReviewImpl _value,
      $Res Function(_$WorkspaceResultReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceResultReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$WorkspaceResultReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReviewStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceResultReviewImpl implements _WorkspaceResultReview {
  const _$WorkspaceResultReviewImpl(
      {required this.id,
      required this.rating,
      this.comment,
      required this.status,
      required this.createdAt});

  factory _$WorkspaceResultReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceResultReviewImplFromJson(json);

  @override
  final String id;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final ReviewStatus status;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'WorkspaceResultReview(id: $id, rating: $rating, comment: $comment, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceResultReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, rating, comment, status, createdAt);

  /// Create a copy of WorkspaceResultReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceResultReviewImplCopyWith<_$WorkspaceResultReviewImpl>
      get copyWith => __$$WorkspaceResultReviewImplCopyWithImpl<
          _$WorkspaceResultReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceResultReviewImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceResultReview implements WorkspaceResultReview {
  const factory _WorkspaceResultReview(
      {required final String id,
      required final int rating,
      final String? comment,
      required final ReviewStatus status,
      required final String createdAt}) = _$WorkspaceResultReviewImpl;

  factory _WorkspaceResultReview.fromJson(Map<String, dynamic> json) =
      _$WorkspaceResultReviewImpl.fromJson;

  @override
  String get id;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  ReviewStatus get status;
  @override
  String get createdAt;

  /// Create a copy of WorkspaceResultReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceResultReviewImplCopyWith<_$WorkspaceResultReviewImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkspaceResult _$WorkspaceResultFromJson(Map<String, dynamic> json) {
  return _WorkspaceResult.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceResult {
  String get bookingId => throw _privateConstructorUsedError;
  BookingStatus get bookingStatus => throw _privateConstructorUsedError;
  String get scheduledAt => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get testName => throw _privateConstructorUsedError;
  ResultStatus get resultStatus => throw _privateConstructorUsedError;
  bool get hasStructuredData => throw _privateConstructorUsedError;
  int get structuredObservationCount => throw _privateConstructorUsedError;
  ResultFile? get file => throw _privateConstructorUsedError;
  ResultSummary? get summary => throw _privateConstructorUsedError;
  WorkspaceResultReview? get review => throw _privateConstructorUsedError;
  bool get canReview => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceResultCopyWith<WorkspaceResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceResultCopyWith<$Res> {
  factory $WorkspaceResultCopyWith(
          WorkspaceResult value, $Res Function(WorkspaceResult) then) =
      _$WorkspaceResultCopyWithImpl<$Res, WorkspaceResult>;
  @useResult
  $Res call(
      {String bookingId,
      BookingStatus bookingStatus,
      String scheduledAt,
      String labName,
      String testName,
      ResultStatus resultStatus,
      bool hasStructuredData,
      int structuredObservationCount,
      ResultFile? file,
      ResultSummary? summary,
      WorkspaceResultReview? review,
      bool canReview});

  $ResultFileCopyWith<$Res>? get file;
  $ResultSummaryCopyWith<$Res>? get summary;
  $WorkspaceResultReviewCopyWith<$Res>? get review;
}

/// @nodoc
class _$WorkspaceResultCopyWithImpl<$Res, $Val extends WorkspaceResult>
    implements $WorkspaceResultCopyWith<$Res> {
  _$WorkspaceResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? bookingStatus = null,
    Object? scheduledAt = null,
    Object? labName = null,
    Object? testName = null,
    Object? resultStatus = null,
    Object? hasStructuredData = null,
    Object? structuredObservationCount = null,
    Object? file = freezed,
    Object? summary = freezed,
    Object? review = freezed,
    Object? canReview = null,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
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
      resultStatus: null == resultStatus
          ? _value.resultStatus
          : resultStatus // ignore: cast_nullable_to_non_nullable
              as ResultStatus,
      hasStructuredData: null == hasStructuredData
          ? _value.hasStructuredData
          : hasStructuredData // ignore: cast_nullable_to_non_nullable
              as bool,
      structuredObservationCount: null == structuredObservationCount
          ? _value.structuredObservationCount
          : structuredObservationCount // ignore: cast_nullable_to_non_nullable
              as int,
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as ResultFile?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ResultSummary?,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as WorkspaceResultReview?,
      canReview: null == canReview
          ? _value.canReview
          : canReview // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultFileCopyWith<$Res>? get file {
    if (_value.file == null) {
      return null;
    }

    return $ResultFileCopyWith<$Res>(_value.file!, (value) {
      return _then(_value.copyWith(file: value) as $Val);
    });
  }

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultSummaryCopyWith<$Res>? get summary {
    if (_value.summary == null) {
      return null;
    }

    return $ResultSummaryCopyWith<$Res>(_value.summary!, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkspaceResultReviewCopyWith<$Res>? get review {
    if (_value.review == null) {
      return null;
    }

    return $WorkspaceResultReviewCopyWith<$Res>(_value.review!, (value) {
      return _then(_value.copyWith(review: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkspaceResultImplCopyWith<$Res>
    implements $WorkspaceResultCopyWith<$Res> {
  factory _$$WorkspaceResultImplCopyWith(_$WorkspaceResultImpl value,
          $Res Function(_$WorkspaceResultImpl) then) =
      __$$WorkspaceResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      BookingStatus bookingStatus,
      String scheduledAt,
      String labName,
      String testName,
      ResultStatus resultStatus,
      bool hasStructuredData,
      int structuredObservationCount,
      ResultFile? file,
      ResultSummary? summary,
      WorkspaceResultReview? review,
      bool canReview});

  @override
  $ResultFileCopyWith<$Res>? get file;
  @override
  $ResultSummaryCopyWith<$Res>? get summary;
  @override
  $WorkspaceResultReviewCopyWith<$Res>? get review;
}

/// @nodoc
class __$$WorkspaceResultImplCopyWithImpl<$Res>
    extends _$WorkspaceResultCopyWithImpl<$Res, _$WorkspaceResultImpl>
    implements _$$WorkspaceResultImplCopyWith<$Res> {
  __$$WorkspaceResultImplCopyWithImpl(
      _$WorkspaceResultImpl _value, $Res Function(_$WorkspaceResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? bookingStatus = null,
    Object? scheduledAt = null,
    Object? labName = null,
    Object? testName = null,
    Object? resultStatus = null,
    Object? hasStructuredData = null,
    Object? structuredObservationCount = null,
    Object? file = freezed,
    Object? summary = freezed,
    Object? review = freezed,
    Object? canReview = null,
  }) {
    return _then(_$WorkspaceResultImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
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
      resultStatus: null == resultStatus
          ? _value.resultStatus
          : resultStatus // ignore: cast_nullable_to_non_nullable
              as ResultStatus,
      hasStructuredData: null == hasStructuredData
          ? _value.hasStructuredData
          : hasStructuredData // ignore: cast_nullable_to_non_nullable
              as bool,
      structuredObservationCount: null == structuredObservationCount
          ? _value.structuredObservationCount
          : structuredObservationCount // ignore: cast_nullable_to_non_nullable
              as int,
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as ResultFile?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ResultSummary?,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as WorkspaceResultReview?,
      canReview: null == canReview
          ? _value.canReview
          : canReview // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceResultImpl implements _WorkspaceResult {
  const _$WorkspaceResultImpl(
      {required this.bookingId,
      required this.bookingStatus,
      required this.scheduledAt,
      required this.labName,
      required this.testName,
      required this.resultStatus,
      required this.hasStructuredData,
      required this.structuredObservationCount,
      this.file,
      this.summary,
      this.review,
      required this.canReview});

  factory _$WorkspaceResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceResultImplFromJson(json);

  @override
  final String bookingId;
  @override
  final BookingStatus bookingStatus;
  @override
  final String scheduledAt;
  @override
  final String labName;
  @override
  final String testName;
  @override
  final ResultStatus resultStatus;
  @override
  final bool hasStructuredData;
  @override
  final int structuredObservationCount;
  @override
  final ResultFile? file;
  @override
  final ResultSummary? summary;
  @override
  final WorkspaceResultReview? review;
  @override
  final bool canReview;

  @override
  String toString() {
    return 'WorkspaceResult(bookingId: $bookingId, bookingStatus: $bookingStatus, scheduledAt: $scheduledAt, labName: $labName, testName: $testName, resultStatus: $resultStatus, hasStructuredData: $hasStructuredData, structuredObservationCount: $structuredObservationCount, file: $file, summary: $summary, review: $review, canReview: $canReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceResultImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.testName, testName) ||
                other.testName == testName) &&
            (identical(other.resultStatus, resultStatus) ||
                other.resultStatus == resultStatus) &&
            (identical(other.hasStructuredData, hasStructuredData) ||
                other.hasStructuredData == hasStructuredData) &&
            (identical(other.structuredObservationCount,
                    structuredObservationCount) ||
                other.structuredObservationCount ==
                    structuredObservationCount) &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.canReview, canReview) ||
                other.canReview == canReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      bookingStatus,
      scheduledAt,
      labName,
      testName,
      resultStatus,
      hasStructuredData,
      structuredObservationCount,
      file,
      summary,
      review,
      canReview);

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceResultImplCopyWith<_$WorkspaceResultImpl> get copyWith =>
      __$$WorkspaceResultImplCopyWithImpl<_$WorkspaceResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceResultImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceResult implements WorkspaceResult {
  const factory _WorkspaceResult(
      {required final String bookingId,
      required final BookingStatus bookingStatus,
      required final String scheduledAt,
      required final String labName,
      required final String testName,
      required final ResultStatus resultStatus,
      required final bool hasStructuredData,
      required final int structuredObservationCount,
      final ResultFile? file,
      final ResultSummary? summary,
      final WorkspaceResultReview? review,
      required final bool canReview}) = _$WorkspaceResultImpl;

  factory _WorkspaceResult.fromJson(Map<String, dynamic> json) =
      _$WorkspaceResultImpl.fromJson;

  @override
  String get bookingId;
  @override
  BookingStatus get bookingStatus;
  @override
  String get scheduledAt;
  @override
  String get labName;
  @override
  String get testName;
  @override
  ResultStatus get resultStatus;
  @override
  bool get hasStructuredData;
  @override
  int get structuredObservationCount;
  @override
  ResultFile? get file;
  @override
  ResultSummary? get summary;
  @override
  WorkspaceResultReview? get review;
  @override
  bool get canReview;

  /// Create a copy of WorkspaceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceResultImplCopyWith<_$WorkspaceResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceProfile _$WorkspaceProfileFromJson(Map<String, dynamic> json) {
  return _WorkspaceProfile.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceProfile {
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  LabHistorySharing get labHistorySharing => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceProfileCopyWith<WorkspaceProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceProfileCopyWith<$Res> {
  factory $WorkspaceProfileCopyWith(
          WorkspaceProfile value, $Res Function(WorkspaceProfile) then) =
      _$WorkspaceProfileCopyWithImpl<$Res, WorkspaceProfile>;
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String address,
      String email,
      LabHistorySharing labHistorySharing});
}

/// @nodoc
class _$WorkspaceProfileCopyWithImpl<$Res, $Val extends WorkspaceProfile>
    implements $WorkspaceProfileCopyWith<$Res> {
  _$WorkspaceProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? address = null,
    Object? email = null,
    Object? labHistorySharing = null,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      labHistorySharing: null == labHistorySharing
          ? _value.labHistorySharing
          : labHistorySharing // ignore: cast_nullable_to_non_nullable
              as LabHistorySharing,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceProfileImplCopyWith<$Res>
    implements $WorkspaceProfileCopyWith<$Res> {
  factory _$$WorkspaceProfileImplCopyWith(_$WorkspaceProfileImpl value,
          $Res Function(_$WorkspaceProfileImpl) then) =
      __$$WorkspaceProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fullName,
      String phone,
      String address,
      String email,
      LabHistorySharing labHistorySharing});
}

/// @nodoc
class __$$WorkspaceProfileImplCopyWithImpl<$Res>
    extends _$WorkspaceProfileCopyWithImpl<$Res, _$WorkspaceProfileImpl>
    implements _$$WorkspaceProfileImplCopyWith<$Res> {
  __$$WorkspaceProfileImplCopyWithImpl(_$WorkspaceProfileImpl _value,
      $Res Function(_$WorkspaceProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? phone = null,
    Object? address = null,
    Object? email = null,
    Object? labHistorySharing = null,
  }) {
    return _then(_$WorkspaceProfileImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      labHistorySharing: null == labHistorySharing
          ? _value.labHistorySharing
          : labHistorySharing // ignore: cast_nullable_to_non_nullable
              as LabHistorySharing,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceProfileImpl implements _WorkspaceProfile {
  const _$WorkspaceProfileImpl(
      {required this.fullName,
      required this.phone,
      required this.address,
      required this.email,
      required this.labHistorySharing});

  factory _$WorkspaceProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceProfileImplFromJson(json);

  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String address;
  @override
  final String email;
  @override
  final LabHistorySharing labHistorySharing;

  @override
  String toString() {
    return 'WorkspaceProfile(fullName: $fullName, phone: $phone, address: $address, email: $email, labHistorySharing: $labHistorySharing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceProfileImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.labHistorySharing, labHistorySharing) ||
                other.labHistorySharing == labHistorySharing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, fullName, phone, address, email, labHistorySharing);

  /// Create a copy of WorkspaceProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceProfileImplCopyWith<_$WorkspaceProfileImpl> get copyWith =>
      __$$WorkspaceProfileImplCopyWithImpl<_$WorkspaceProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceProfileImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceProfile implements WorkspaceProfile {
  const factory _WorkspaceProfile(
          {required final String fullName,
          required final String phone,
          required final String address,
          required final String email,
          required final LabHistorySharing labHistorySharing}) =
      _$WorkspaceProfileImpl;

  factory _WorkspaceProfile.fromJson(Map<String, dynamic> json) =
      _$WorkspaceProfileImpl.fromJson;

  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get address;
  @override
  String get email;
  @override
  LabHistorySharing get labHistorySharing;

  /// Create a copy of WorkspaceProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceProfileImplCopyWith<_$WorkspaceProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceBookings _$WorkspaceBookingsFromJson(Map<String, dynamic> json) {
  return _WorkspaceBookings.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceBookings {
  List<WorkspaceBooking> get upcoming => throw _privateConstructorUsedError;
  List<WorkspaceBooking> get past => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceBookings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceBookings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceBookingsCopyWith<WorkspaceBookings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceBookingsCopyWith<$Res> {
  factory $WorkspaceBookingsCopyWith(
          WorkspaceBookings value, $Res Function(WorkspaceBookings) then) =
      _$WorkspaceBookingsCopyWithImpl<$Res, WorkspaceBookings>;
  @useResult
  $Res call({List<WorkspaceBooking> upcoming, List<WorkspaceBooking> past});
}

/// @nodoc
class _$WorkspaceBookingsCopyWithImpl<$Res, $Val extends WorkspaceBookings>
    implements $WorkspaceBookingsCopyWith<$Res> {
  _$WorkspaceBookingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceBookings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upcoming = null,
    Object? past = null,
  }) {
    return _then(_value.copyWith(
      upcoming: null == upcoming
          ? _value.upcoming
          : upcoming // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceBooking>,
      past: null == past
          ? _value.past
          : past // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceBooking>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceBookingsImplCopyWith<$Res>
    implements $WorkspaceBookingsCopyWith<$Res> {
  factory _$$WorkspaceBookingsImplCopyWith(_$WorkspaceBookingsImpl value,
          $Res Function(_$WorkspaceBookingsImpl) then) =
      __$$WorkspaceBookingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<WorkspaceBooking> upcoming, List<WorkspaceBooking> past});
}

/// @nodoc
class __$$WorkspaceBookingsImplCopyWithImpl<$Res>
    extends _$WorkspaceBookingsCopyWithImpl<$Res, _$WorkspaceBookingsImpl>
    implements _$$WorkspaceBookingsImplCopyWith<$Res> {
  __$$WorkspaceBookingsImplCopyWithImpl(_$WorkspaceBookingsImpl _value,
      $Res Function(_$WorkspaceBookingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceBookings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upcoming = null,
    Object? past = null,
  }) {
    return _then(_$WorkspaceBookingsImpl(
      upcoming: null == upcoming
          ? _value._upcoming
          : upcoming // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceBooking>,
      past: null == past
          ? _value._past
          : past // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceBooking>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceBookingsImpl implements _WorkspaceBookings {
  const _$WorkspaceBookingsImpl(
      {required final List<WorkspaceBooking> upcoming,
      required final List<WorkspaceBooking> past})
      : _upcoming = upcoming,
        _past = past;

  factory _$WorkspaceBookingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceBookingsImplFromJson(json);

  final List<WorkspaceBooking> _upcoming;
  @override
  List<WorkspaceBooking> get upcoming {
    if (_upcoming is EqualUnmodifiableListView) return _upcoming;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcoming);
  }

  final List<WorkspaceBooking> _past;
  @override
  List<WorkspaceBooking> get past {
    if (_past is EqualUnmodifiableListView) return _past;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_past);
  }

  @override
  String toString() {
    return 'WorkspaceBookings(upcoming: $upcoming, past: $past)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceBookingsImpl &&
            const DeepCollectionEquality().equals(other._upcoming, _upcoming) &&
            const DeepCollectionEquality().equals(other._past, _past));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_upcoming),
      const DeepCollectionEquality().hash(_past));

  /// Create a copy of WorkspaceBookings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceBookingsImplCopyWith<_$WorkspaceBookingsImpl> get copyWith =>
      __$$WorkspaceBookingsImplCopyWithImpl<_$WorkspaceBookingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceBookingsImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceBookings implements WorkspaceBookings {
  const factory _WorkspaceBookings(
      {required final List<WorkspaceBooking> upcoming,
      required final List<WorkspaceBooking> past}) = _$WorkspaceBookingsImpl;

  factory _WorkspaceBookings.fromJson(Map<String, dynamic> json) =
      _$WorkspaceBookingsImpl.fromJson;

  @override
  List<WorkspaceBooking> get upcoming;
  @override
  List<WorkspaceBooking> get past;

  /// Create a copy of WorkspaceBookings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceBookingsImplCopyWith<_$WorkspaceBookingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientWorkspaceResponse _$PatientWorkspaceResponseFromJson(
    Map<String, dynamic> json) {
  return _PatientWorkspaceResponse.fromJson(json);
}

/// @nodoc
mixin _$PatientWorkspaceResponse {
  WorkspaceProfile get profile => throw _privateConstructorUsedError;
  WorkspaceBookings get bookings => throw _privateConstructorUsedError;
  List<WorkspaceResult> get results => throw _privateConstructorUsedError;

  /// Serializes this PatientWorkspaceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientWorkspaceResponseCopyWith<PatientWorkspaceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientWorkspaceResponseCopyWith<$Res> {
  factory $PatientWorkspaceResponseCopyWith(PatientWorkspaceResponse value,
          $Res Function(PatientWorkspaceResponse) then) =
      _$PatientWorkspaceResponseCopyWithImpl<$Res, PatientWorkspaceResponse>;
  @useResult
  $Res call(
      {WorkspaceProfile profile,
      WorkspaceBookings bookings,
      List<WorkspaceResult> results});

  $WorkspaceProfileCopyWith<$Res> get profile;
  $WorkspaceBookingsCopyWith<$Res> get bookings;
}

/// @nodoc
class _$PatientWorkspaceResponseCopyWithImpl<$Res,
        $Val extends PatientWorkspaceResponse>
    implements $PatientWorkspaceResponseCopyWith<$Res> {
  _$PatientWorkspaceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? bookings = null,
    Object? results = null,
  }) {
    return _then(_value.copyWith(
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as WorkspaceProfile,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookings,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceResult>,
    ) as $Val);
  }

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkspaceProfileCopyWith<$Res> get profile {
    return $WorkspaceProfileCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkspaceBookingsCopyWith<$Res> get bookings {
    return $WorkspaceBookingsCopyWith<$Res>(_value.bookings, (value) {
      return _then(_value.copyWith(bookings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PatientWorkspaceResponseImplCopyWith<$Res>
    implements $PatientWorkspaceResponseCopyWith<$Res> {
  factory _$$PatientWorkspaceResponseImplCopyWith(
          _$PatientWorkspaceResponseImpl value,
          $Res Function(_$PatientWorkspaceResponseImpl) then) =
      __$$PatientWorkspaceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WorkspaceProfile profile,
      WorkspaceBookings bookings,
      List<WorkspaceResult> results});

  @override
  $WorkspaceProfileCopyWith<$Res> get profile;
  @override
  $WorkspaceBookingsCopyWith<$Res> get bookings;
}

/// @nodoc
class __$$PatientWorkspaceResponseImplCopyWithImpl<$Res>
    extends _$PatientWorkspaceResponseCopyWithImpl<$Res,
        _$PatientWorkspaceResponseImpl>
    implements _$$PatientWorkspaceResponseImplCopyWith<$Res> {
  __$$PatientWorkspaceResponseImplCopyWithImpl(
      _$PatientWorkspaceResponseImpl _value,
      $Res Function(_$PatientWorkspaceResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? bookings = null,
    Object? results = null,
  }) {
    return _then(_$PatientWorkspaceResponseImpl(
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as WorkspaceProfile,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as WorkspaceBookings,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<WorkspaceResult>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientWorkspaceResponseImpl implements _PatientWorkspaceResponse {
  const _$PatientWorkspaceResponseImpl(
      {required this.profile,
      required this.bookings,
      required final List<WorkspaceResult> results})
      : _results = results;

  factory _$PatientWorkspaceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientWorkspaceResponseImplFromJson(json);

  @override
  final WorkspaceProfile profile;
  @override
  final WorkspaceBookings bookings;
  final List<WorkspaceResult> _results;
  @override
  List<WorkspaceResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'PatientWorkspaceResponse(profile: $profile, bookings: $bookings, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientWorkspaceResponseImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.bookings, bookings) ||
                other.bookings == bookings) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, profile, bookings,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientWorkspaceResponseImplCopyWith<_$PatientWorkspaceResponseImpl>
      get copyWith => __$$PatientWorkspaceResponseImplCopyWithImpl<
          _$PatientWorkspaceResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientWorkspaceResponseImplToJson(
      this,
    );
  }
}

abstract class _PatientWorkspaceResponse implements PatientWorkspaceResponse {
  const factory _PatientWorkspaceResponse(
          {required final WorkspaceProfile profile,
          required final WorkspaceBookings bookings,
          required final List<WorkspaceResult> results}) =
      _$PatientWorkspaceResponseImpl;

  factory _PatientWorkspaceResponse.fromJson(Map<String, dynamic> json) =
      _$PatientWorkspaceResponseImpl.fromJson;

  @override
  WorkspaceProfile get profile;
  @override
  WorkspaceBookings get bookings;
  @override
  List<WorkspaceResult> get results;

  /// Create a copy of PatientWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientWorkspaceResponseImplCopyWith<_$PatientWorkspaceResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
