// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingSlot _$BookingSlotFromJson(Map<String, dynamic> json) {
  return _BookingSlot.fromJson(json);
}

/// @nodoc
mixin _$BookingSlot {
  String get id => throw _privateConstructorUsedError;
  String get startsAt => throw _privateConstructorUsedError;
  String get endsAt => throw _privateConstructorUsedError;

  /// Serializes this BookingSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingSlotCopyWith<BookingSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingSlotCopyWith<$Res> {
  factory $BookingSlotCopyWith(
          BookingSlot value, $Res Function(BookingSlot) then) =
      _$BookingSlotCopyWithImpl<$Res, BookingSlot>;
  @useResult
  $Res call({String id, String startsAt, String endsAt});
}

/// @nodoc
class _$BookingSlotCopyWithImpl<$Res, $Val extends BookingSlot>
    implements $BookingSlotCopyWith<$Res> {
  _$BookingSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startsAt = null,
    Object? endsAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as String,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingSlotImplCopyWith<$Res>
    implements $BookingSlotCopyWith<$Res> {
  factory _$$BookingSlotImplCopyWith(
          _$BookingSlotImpl value, $Res Function(_$BookingSlotImpl) then) =
      __$$BookingSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String startsAt, String endsAt});
}

/// @nodoc
class __$$BookingSlotImplCopyWithImpl<$Res>
    extends _$BookingSlotCopyWithImpl<$Res, _$BookingSlotImpl>
    implements _$$BookingSlotImplCopyWith<$Res> {
  __$$BookingSlotImplCopyWithImpl(
      _$BookingSlotImpl _value, $Res Function(_$BookingSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startsAt = null,
    Object? endsAt = null,
  }) {
    return _then(_$BookingSlotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as String,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingSlotImpl implements _BookingSlot {
  const _$BookingSlotImpl(
      {required this.id, required this.startsAt, required this.endsAt});

  factory _$BookingSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingSlotImplFromJson(json);

  @override
  final String id;
  @override
  final String startsAt;
  @override
  final String endsAt;

  @override
  String toString() {
    return 'BookingSlot(id: $id, startsAt: $startsAt, endsAt: $endsAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startsAt, endsAt);

  /// Create a copy of BookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingSlotImplCopyWith<_$BookingSlotImpl> get copyWith =>
      __$$BookingSlotImplCopyWithImpl<_$BookingSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingSlotImplToJson(
      this,
    );
  }
}

abstract class _BookingSlot implements BookingSlot {
  const factory _BookingSlot(
      {required final String id,
      required final String startsAt,
      required final String endsAt}) = _$BookingSlotImpl;

  factory _BookingSlot.fromJson(Map<String, dynamic> json) =
      _$BookingSlotImpl.fromJson;

  @override
  String get id;
  @override
  String get startsAt;
  @override
  String get endsAt;

  /// Create a copy of BookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingSlotImplCopyWith<_$BookingSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingAvailabilityResponse _$BookingAvailabilityResponseFromJson(
    Map<String, dynamic> json) {
  return _BookingAvailabilityResponse.fromJson(json);
}

/// @nodoc
mixin _$BookingAvailabilityResponse {
  List<BookingSlot> get items => throw _privateConstructorUsedError;

  /// Serializes this BookingAvailabilityResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingAvailabilityResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingAvailabilityResponseCopyWith<BookingAvailabilityResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingAvailabilityResponseCopyWith<$Res> {
  factory $BookingAvailabilityResponseCopyWith(
          BookingAvailabilityResponse value,
          $Res Function(BookingAvailabilityResponse) then) =
      _$BookingAvailabilityResponseCopyWithImpl<$Res,
          BookingAvailabilityResponse>;
  @useResult
  $Res call({List<BookingSlot> items});
}

/// @nodoc
class _$BookingAvailabilityResponseCopyWithImpl<$Res,
        $Val extends BookingAvailabilityResponse>
    implements $BookingAvailabilityResponseCopyWith<$Res> {
  _$BookingAvailabilityResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingAvailabilityResponse
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
              as List<BookingSlot>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingAvailabilityResponseImplCopyWith<$Res>
    implements $BookingAvailabilityResponseCopyWith<$Res> {
  factory _$$BookingAvailabilityResponseImplCopyWith(
          _$BookingAvailabilityResponseImpl value,
          $Res Function(_$BookingAvailabilityResponseImpl) then) =
      __$$BookingAvailabilityResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BookingSlot> items});
}

/// @nodoc
class __$$BookingAvailabilityResponseImplCopyWithImpl<$Res>
    extends _$BookingAvailabilityResponseCopyWithImpl<$Res,
        _$BookingAvailabilityResponseImpl>
    implements _$$BookingAvailabilityResponseImplCopyWith<$Res> {
  __$$BookingAvailabilityResponseImplCopyWithImpl(
      _$BookingAvailabilityResponseImpl _value,
      $Res Function(_$BookingAvailabilityResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingAvailabilityResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$BookingAvailabilityResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BookingSlot>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingAvailabilityResponseImpl
    implements _BookingAvailabilityResponse {
  const _$BookingAvailabilityResponseImpl(
      {required final List<BookingSlot> items})
      : _items = items;

  factory _$BookingAvailabilityResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$BookingAvailabilityResponseImplFromJson(json);

  final List<BookingSlot> _items;
  @override
  List<BookingSlot> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'BookingAvailabilityResponse(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingAvailabilityResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of BookingAvailabilityResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingAvailabilityResponseImplCopyWith<_$BookingAvailabilityResponseImpl>
      get copyWith => __$$BookingAvailabilityResponseImplCopyWithImpl<
          _$BookingAvailabilityResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingAvailabilityResponseImplToJson(
      this,
    );
  }
}

abstract class _BookingAvailabilityResponse
    implements BookingAvailabilityResponse {
  const factory _BookingAvailabilityResponse(
          {required final List<BookingSlot> items}) =
      _$BookingAvailabilityResponseImpl;

  factory _BookingAvailabilityResponse.fromJson(Map<String, dynamic> json) =
      _$BookingAvailabilityResponseImpl.fromJson;

  @override
  List<BookingSlot> get items;

  /// Create a copy of BookingAvailabilityResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingAvailabilityResponseImplCopyWith<_$BookingAvailabilityResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BookingItemLab _$BookingItemLabFromJson(Map<String, dynamic> json) {
  return _BookingItemLab.fromJson(json);
}

/// @nodoc
mixin _$BookingItemLab {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  bool get homeTestKit => throw _privateConstructorUsedError;

  /// Serializes this BookingItemLab to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingItemLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingItemLabCopyWith<BookingItemLab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingItemLabCopyWith<$Res> {
  factory $BookingItemLabCopyWith(
          BookingItemLab value, $Res Function(BookingItemLab) then) =
      _$BookingItemLabCopyWithImpl<$Res, BookingItemLab>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      bool homeCollection,
      bool homeTestKit});
}

/// @nodoc
class _$BookingItemLabCopyWithImpl<$Res, $Val extends BookingItemLab>
    implements $BookingItemLabCopyWith<$Res> {
  _$BookingItemLabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingItemLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? homeCollection = null,
    Object? homeTestKit = null,
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
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingItemLabImplCopyWith<$Res>
    implements $BookingItemLabCopyWith<$Res> {
  factory _$$BookingItemLabImplCopyWith(_$BookingItemLabImpl value,
          $Res Function(_$BookingItemLabImpl) then) =
      __$$BookingItemLabImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      bool homeCollection,
      bool homeTestKit});
}

/// @nodoc
class __$$BookingItemLabImplCopyWithImpl<$Res>
    extends _$BookingItemLabCopyWithImpl<$Res, _$BookingItemLabImpl>
    implements _$$BookingItemLabImplCopyWith<$Res> {
  __$$BookingItemLabImplCopyWithImpl(
      _$BookingItemLabImpl _value, $Res Function(_$BookingItemLabImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingItemLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? homeCollection = null,
    Object? homeTestKit = null,
  }) {
    return _then(_$BookingItemLabImpl(
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
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingItemLabImpl implements _BookingItemLab {
  const _$BookingItemLabImpl(
      {required this.id,
      required this.name,
      required this.address,
      required this.homeCollection,
      required this.homeTestKit});

  factory _$BookingItemLabImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingItemLabImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final bool homeCollection;
  @override
  final bool homeTestKit;

  @override
  String toString() {
    return 'BookingItemLab(id: $id, name: $name, address: $address, homeCollection: $homeCollection, homeTestKit: $homeTestKit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingItemLabImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.homeCollection, homeCollection) ||
                other.homeCollection == homeCollection) &&
            (identical(other.homeTestKit, homeTestKit) ||
                other.homeTestKit == homeTestKit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, address, homeCollection, homeTestKit);

  /// Create a copy of BookingItemLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingItemLabImplCopyWith<_$BookingItemLabImpl> get copyWith =>
      __$$BookingItemLabImplCopyWithImpl<_$BookingItemLabImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingItemLabImplToJson(
      this,
    );
  }
}

abstract class _BookingItemLab implements BookingItemLab {
  const factory _BookingItemLab(
      {required final String id,
      required final String name,
      required final String address,
      required final bool homeCollection,
      required final bool homeTestKit}) = _$BookingItemLabImpl;

  factory _BookingItemLab.fromJson(Map<String, dynamic> json) =
      _$BookingItemLabImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  bool get homeCollection;
  @override
  bool get homeTestKit;

  /// Create a copy of BookingItemLab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingItemLabImplCopyWith<_$BookingItemLabImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingItemTest _$BookingItemTestFromJson(Map<String, dynamic> json) {
  return _BookingItemTest.fromJson(json);
}

/// @nodoc
mixin _$BookingItemTest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;

  /// Serializes this BookingItemTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingItemTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingItemTestCopyWith<BookingItemTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingItemTestCopyWith<$Res> {
  factory $BookingItemTestCopyWith(
          BookingItemTest value, $Res Function(BookingItemTest) then) =
      _$BookingItemTestCopyWithImpl<$Res, BookingItemTest>;
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class _$BookingItemTestCopyWithImpl<$Res, $Val extends BookingItemTest>
    implements $BookingItemTestCopyWith<$Res> {
  _$BookingItemTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingItemTest
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
abstract class _$$BookingItemTestImplCopyWith<$Res>
    implements $BookingItemTestCopyWith<$Res> {
  factory _$$BookingItemTestImplCopyWith(_$BookingItemTestImpl value,
          $Res Function(_$BookingItemTestImpl) then) =
      __$$BookingItemTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class __$$BookingItemTestImplCopyWithImpl<$Res>
    extends _$BookingItemTestCopyWithImpl<$Res, _$BookingItemTestImpl>
    implements _$$BookingItemTestImplCopyWith<$Res> {
  __$$BookingItemTestImplCopyWithImpl(
      _$BookingItemTestImpl _value, $Res Function(_$BookingItemTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingItemTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? priceEgp = null,
  }) {
    return _then(_$BookingItemTestImpl(
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
class _$BookingItemTestImpl implements _BookingItemTest {
  const _$BookingItemTestImpl(
      {required this.id, required this.name, required this.priceEgp});

  factory _$BookingItemTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingItemTestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int priceEgp;

  @override
  String toString() {
    return 'BookingItemTest(id: $id, name: $name, priceEgp: $priceEgp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingItemTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, priceEgp);

  /// Create a copy of BookingItemTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingItemTestImplCopyWith<_$BookingItemTestImpl> get copyWith =>
      __$$BookingItemTestImplCopyWithImpl<_$BookingItemTestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingItemTestImplToJson(
      this,
    );
  }
}

abstract class _BookingItemTest implements BookingItemTest {
  const factory _BookingItemTest(
      {required final String id,
      required final String name,
      required final int priceEgp}) = _$BookingItemTestImpl;

  factory _BookingItemTest.fromJson(Map<String, dynamic> json) =
      _$BookingItemTestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get priceEgp;

  /// Create a copy of BookingItemTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingItemTestImplCopyWith<_$BookingItemTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingTimelineEntry _$BookingTimelineEntryFromJson(Map<String, dynamic> json) {
  return _BookingTimelineEntry.fromJson(json);
}

/// @nodoc
mixin _$BookingTimelineEntry {
  String get id => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BookingTimelineEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingTimelineEntryCopyWith<BookingTimelineEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingTimelineEntryCopyWith<$Res> {
  factory $BookingTimelineEntryCopyWith(BookingTimelineEntry value,
          $Res Function(BookingTimelineEntry) then) =
      _$BookingTimelineEntryCopyWithImpl<$Res, BookingTimelineEntry>;
  @useResult
  $Res call({String id, BookingStatus status, String? note, String createdAt});
}

/// @nodoc
class _$BookingTimelineEntryCopyWithImpl<$Res,
        $Val extends BookingTimelineEntry>
    implements $BookingTimelineEntryCopyWith<$Res> {
  _$BookingTimelineEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingTimelineEntry
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
              as BookingStatus,
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
abstract class _$$BookingTimelineEntryImplCopyWith<$Res>
    implements $BookingTimelineEntryCopyWith<$Res> {
  factory _$$BookingTimelineEntryImplCopyWith(_$BookingTimelineEntryImpl value,
          $Res Function(_$BookingTimelineEntryImpl) then) =
      __$$BookingTimelineEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, BookingStatus status, String? note, String createdAt});
}

/// @nodoc
class __$$BookingTimelineEntryImplCopyWithImpl<$Res>
    extends _$BookingTimelineEntryCopyWithImpl<$Res, _$BookingTimelineEntryImpl>
    implements _$$BookingTimelineEntryImplCopyWith<$Res> {
  __$$BookingTimelineEntryImplCopyWithImpl(_$BookingTimelineEntryImpl _value,
      $Res Function(_$BookingTimelineEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$BookingTimelineEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
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
class _$BookingTimelineEntryImpl implements _BookingTimelineEntry {
  const _$BookingTimelineEntryImpl(
      {required this.id,
      required this.status,
      this.note,
      required this.createdAt});

  factory _$BookingTimelineEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingTimelineEntryImplFromJson(json);

  @override
  final String id;
  @override
  final BookingStatus status;
  @override
  final String? note;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'BookingTimelineEntry(id: $id, status: $status, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingTimelineEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, note, createdAt);

  /// Create a copy of BookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingTimelineEntryImplCopyWith<_$BookingTimelineEntryImpl>
      get copyWith =>
          __$$BookingTimelineEntryImplCopyWithImpl<_$BookingTimelineEntryImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingTimelineEntryImplToJson(
      this,
    );
  }
}

abstract class _BookingTimelineEntry implements BookingTimelineEntry {
  const factory _BookingTimelineEntry(
      {required final String id,
      required final BookingStatus status,
      final String? note,
      required final String createdAt}) = _$BookingTimelineEntryImpl;

  factory _BookingTimelineEntry.fromJson(Map<String, dynamic> json) =
      _$BookingTimelineEntryImpl.fromJson;

  @override
  String get id;
  @override
  BookingStatus get status;
  @override
  String? get note;
  @override
  String get createdAt;

  /// Create a copy of BookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingTimelineEntryImplCopyWith<_$BookingTimelineEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BookingItem _$BookingItemFromJson(Map<String, dynamic> json) {
  return _BookingItem.fromJson(json);
}

/// @nodoc
mixin _$BookingItem {
  String get id => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  BookingType get bookingType => throw _privateConstructorUsedError;
  String get scheduledAt => throw _privateConstructorUsedError;
  String? get homeAddress => throw _privateConstructorUsedError;
  int get totalPriceEgp => throw _privateConstructorUsedError;
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
  String? get createdAt => throw _privateConstructorUsedError;
  BookingItemLab get lab => throw _privateConstructorUsedError;
  BookingItemTest get test => throw _privateConstructorUsedError;
  List<BookingTimelineEntry> get timeline => throw _privateConstructorUsedError;

  /// Serializes this BookingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingItemCopyWith<BookingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingItemCopyWith<$Res> {
  factory $BookingItemCopyWith(
          BookingItem value, $Res Function(BookingItem) then) =
      _$BookingItemCopyWithImpl<$Res, BookingItem>;
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      BookingType bookingType,
      String scheduledAt,
      String? homeAddress,
      int totalPriceEgp,
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
      String? createdAt,
      BookingItemLab lab,
      BookingItemTest test,
      List<BookingTimelineEntry> timeline});

  $BookingItemLabCopyWith<$Res> get lab;
  $BookingItemTestCopyWith<$Res> get test;
}

/// @nodoc
class _$BookingItemCopyWithImpl<$Res, $Val extends BookingItem>
    implements $BookingItemCopyWith<$Res> {
  _$BookingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? bookingType = null,
    Object? scheduledAt = null,
    Object? homeAddress = freezed,
    Object? totalPriceEgp = null,
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
    Object? createdAt = freezed,
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
      homeAddress: freezed == homeAddress
          ? _value.homeAddress
          : homeAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPriceEgp: null == totalPriceEgp
          ? _value.totalPriceEgp
          : totalPriceEgp // ignore: cast_nullable_to_non_nullable
              as int,
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as BookingItemLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as BookingItemTest,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<BookingTimelineEntry>,
    ) as $Val);
  }

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingItemLabCopyWith<$Res> get lab {
    return $BookingItemLabCopyWith<$Res>(_value.lab, (value) {
      return _then(_value.copyWith(lab: value) as $Val);
    });
  }

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingItemTestCopyWith<$Res> get test {
    return $BookingItemTestCopyWith<$Res>(_value.test, (value) {
      return _then(_value.copyWith(test: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingItemImplCopyWith<$Res>
    implements $BookingItemCopyWith<$Res> {
  factory _$$BookingItemImplCopyWith(
          _$BookingItemImpl value, $Res Function(_$BookingItemImpl) then) =
      __$$BookingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      BookingType bookingType,
      String scheduledAt,
      String? homeAddress,
      int totalPriceEgp,
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
      String? createdAt,
      BookingItemLab lab,
      BookingItemTest test,
      List<BookingTimelineEntry> timeline});

  @override
  $BookingItemLabCopyWith<$Res> get lab;
  @override
  $BookingItemTestCopyWith<$Res> get test;
}

/// @nodoc
class __$$BookingItemImplCopyWithImpl<$Res>
    extends _$BookingItemCopyWithImpl<$Res, _$BookingItemImpl>
    implements _$$BookingItemImplCopyWith<$Res> {
  __$$BookingItemImplCopyWithImpl(
      _$BookingItemImpl _value, $Res Function(_$BookingItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? bookingType = null,
    Object? scheduledAt = null,
    Object? homeAddress = freezed,
    Object? totalPriceEgp = null,
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
    Object? createdAt = freezed,
    Object? lab = null,
    Object? test = null,
    Object? timeline = null,
  }) {
    return _then(_$BookingItemImpl(
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
      homeAddress: freezed == homeAddress
          ? _value.homeAddress
          : homeAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPriceEgp: null == totalPriceEgp
          ? _value.totalPriceEgp
          : totalPriceEgp // ignore: cast_nullable_to_non_nullable
              as int,
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as BookingItemLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as BookingItemTest,
      timeline: null == timeline
          ? _value._timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<BookingTimelineEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingItemImpl implements _BookingItem {
  const _$BookingItemImpl(
      {required this.id,
      required this.status,
      required this.bookingType,
      required this.scheduledAt,
      this.homeAddress,
      required this.totalPriceEgp,
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
      this.createdAt,
      required this.lab,
      required this.test,
      required final List<BookingTimelineEntry> timeline})
      : _timeline = timeline;

  factory _$BookingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingItemImplFromJson(json);

  @override
  final String id;
  @override
  final BookingStatus status;
  @override
  final BookingType bookingType;
  @override
  final String scheduledAt;
  @override
  final String? homeAddress;
  @override
  final int totalPriceEgp;
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
  final String? createdAt;
  @override
  final BookingItemLab lab;
  @override
  final BookingItemTest test;
  final List<BookingTimelineEntry> _timeline;
  @override
  List<BookingTimelineEntry> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  String toString() {
    return 'BookingItem(id: $id, status: $status, bookingType: $bookingType, scheduledAt: $scheduledAt, homeAddress: $homeAddress, totalPriceEgp: $totalPriceEgp, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentPaidAt: $paymentPaidAt, paymentFailedAt: $paymentFailedAt, paymentFailureReason: $paymentFailureReason, kitStatus: $kitStatus, kitTrackingNumber: $kitTrackingNumber, kitShippedAt: $kitShippedAt, kitDeliveredAt: $kitDeliveredAt, sampleReceivedAt: $sampleReceivedAt, createdAt: $createdAt, lab: $lab, test: $test, timeline: $timeline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.homeAddress, homeAddress) ||
                other.homeAddress == homeAddress) &&
            (identical(other.totalPriceEgp, totalPriceEgp) ||
                other.totalPriceEgp == totalPriceEgp) &&
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
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
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
        homeAddress,
        totalPriceEgp,
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
        createdAt,
        lab,
        test,
        const DeepCollectionEquality().hash(_timeline)
      ]);

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingItemImplCopyWith<_$BookingItemImpl> get copyWith =>
      __$$BookingItemImplCopyWithImpl<_$BookingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingItemImplToJson(
      this,
    );
  }
}

abstract class _BookingItem implements BookingItem {
  const factory _BookingItem(
      {required final String id,
      required final BookingStatus status,
      required final BookingType bookingType,
      required final String scheduledAt,
      final String? homeAddress,
      required final int totalPriceEgp,
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
      final String? createdAt,
      required final BookingItemLab lab,
      required final BookingItemTest test,
      required final List<BookingTimelineEntry> timeline}) = _$BookingItemImpl;

  factory _BookingItem.fromJson(Map<String, dynamic> json) =
      _$BookingItemImpl.fromJson;

  @override
  String get id;
  @override
  BookingStatus get status;
  @override
  BookingType get bookingType;
  @override
  String get scheduledAt;
  @override
  String? get homeAddress;
  @override
  int get totalPriceEgp;
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
  String? get createdAt;
  @override
  BookingItemLab get lab;
  @override
  BookingItemTest get test;
  @override
  List<BookingTimelineEntry> get timeline;

  /// Create a copy of BookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingItemImplCopyWith<_$BookingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingListResponse _$BookingListResponseFromJson(Map<String, dynamic> json) {
  return _BookingListResponse.fromJson(json);
}

/// @nodoc
mixin _$BookingListResponse {
  List<BookingItem> get items => throw _privateConstructorUsedError;

  /// Serializes this BookingListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingListResponseCopyWith<BookingListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingListResponseCopyWith<$Res> {
  factory $BookingListResponseCopyWith(
          BookingListResponse value, $Res Function(BookingListResponse) then) =
      _$BookingListResponseCopyWithImpl<$Res, BookingListResponse>;
  @useResult
  $Res call({List<BookingItem> items});
}

/// @nodoc
class _$BookingListResponseCopyWithImpl<$Res, $Val extends BookingListResponse>
    implements $BookingListResponseCopyWith<$Res> {
  _$BookingListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingListResponse
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
              as List<BookingItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingListResponseImplCopyWith<$Res>
    implements $BookingListResponseCopyWith<$Res> {
  factory _$$BookingListResponseImplCopyWith(_$BookingListResponseImpl value,
          $Res Function(_$BookingListResponseImpl) then) =
      __$$BookingListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BookingItem> items});
}

/// @nodoc
class __$$BookingListResponseImplCopyWithImpl<$Res>
    extends _$BookingListResponseCopyWithImpl<$Res, _$BookingListResponseImpl>
    implements _$$BookingListResponseImplCopyWith<$Res> {
  __$$BookingListResponseImplCopyWithImpl(_$BookingListResponseImpl _value,
      $Res Function(_$BookingListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$BookingListResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BookingItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingListResponseImpl implements _BookingListResponse {
  const _$BookingListResponseImpl({required final List<BookingItem> items})
      : _items = items;

  factory _$BookingListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingListResponseImplFromJson(json);

  final List<BookingItem> _items;
  @override
  List<BookingItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'BookingListResponse(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of BookingListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingListResponseImplCopyWith<_$BookingListResponseImpl> get copyWith =>
      __$$BookingListResponseImplCopyWithImpl<_$BookingListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingListResponseImplToJson(
      this,
    );
  }
}

abstract class _BookingListResponse implements BookingListResponse {
  const factory _BookingListResponse({required final List<BookingItem> items}) =
      _$BookingListResponseImpl;

  factory _BookingListResponse.fromJson(Map<String, dynamic> json) =
      _$BookingListResponseImpl.fromJson;

  @override
  List<BookingItem> get items;

  /// Create a copy of BookingListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingListResponseImplCopyWith<_$BookingListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BookingFlowParams {
  String get labId => throw _privateConstructorUsedError;
  String get testId => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get testName => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;
  bool get supportsHomeCollection => throw _privateConstructorUsedError;
  bool get supportsHomeTestKit => throw _privateConstructorUsedError;
  String? get preparation => throw _privateConstructorUsedError;

  /// Create a copy of BookingFlowParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingFlowParamsCopyWith<BookingFlowParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingFlowParamsCopyWith<$Res> {
  factory $BookingFlowParamsCopyWith(
          BookingFlowParams value, $Res Function(BookingFlowParams) then) =
      _$BookingFlowParamsCopyWithImpl<$Res, BookingFlowParams>;
  @useResult
  $Res call(
      {String labId,
      String testId,
      String labName,
      String testName,
      int priceEgp,
      bool supportsHomeCollection,
      bool supportsHomeTestKit,
      String? preparation});
}

/// @nodoc
class _$BookingFlowParamsCopyWithImpl<$Res, $Val extends BookingFlowParams>
    implements $BookingFlowParamsCopyWith<$Res> {
  _$BookingFlowParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingFlowParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labId = null,
    Object? testId = null,
    Object? labName = null,
    Object? testName = null,
    Object? priceEgp = null,
    Object? supportsHomeCollection = null,
    Object? supportsHomeTestKit = null,
    Object? preparation = freezed,
  }) {
    return _then(_value.copyWith(
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      supportsHomeCollection: null == supportsHomeCollection
          ? _value.supportsHomeCollection
          : supportsHomeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsHomeTestKit: null == supportsHomeTestKit
          ? _value.supportsHomeTestKit
          : supportsHomeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingFlowParamsImplCopyWith<$Res>
    implements $BookingFlowParamsCopyWith<$Res> {
  factory _$$BookingFlowParamsImplCopyWith(_$BookingFlowParamsImpl value,
          $Res Function(_$BookingFlowParamsImpl) then) =
      __$$BookingFlowParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String labId,
      String testId,
      String labName,
      String testName,
      int priceEgp,
      bool supportsHomeCollection,
      bool supportsHomeTestKit,
      String? preparation});
}

/// @nodoc
class __$$BookingFlowParamsImplCopyWithImpl<$Res>
    extends _$BookingFlowParamsCopyWithImpl<$Res, _$BookingFlowParamsImpl>
    implements _$$BookingFlowParamsImplCopyWith<$Res> {
  __$$BookingFlowParamsImplCopyWithImpl(_$BookingFlowParamsImpl _value,
      $Res Function(_$BookingFlowParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labId = null,
    Object? testId = null,
    Object? labName = null,
    Object? testName = null,
    Object? priceEgp = null,
    Object? supportsHomeCollection = null,
    Object? supportsHomeTestKit = null,
    Object? preparation = freezed,
  }) {
    return _then(_$BookingFlowParamsImpl(
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      supportsHomeCollection: null == supportsHomeCollection
          ? _value.supportsHomeCollection
          : supportsHomeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsHomeTestKit: null == supportsHomeTestKit
          ? _value.supportsHomeTestKit
          : supportsHomeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BookingFlowParamsImpl implements _BookingFlowParams {
  const _$BookingFlowParamsImpl(
      {required this.labId,
      required this.testId,
      required this.labName,
      required this.testName,
      required this.priceEgp,
      required this.supportsHomeCollection,
      required this.supportsHomeTestKit,
      this.preparation});

  @override
  final String labId;
  @override
  final String testId;
  @override
  final String labName;
  @override
  final String testName;
  @override
  final int priceEgp;
  @override
  final bool supportsHomeCollection;
  @override
  final bool supportsHomeTestKit;
  @override
  final String? preparation;

  @override
  String toString() {
    return 'BookingFlowParams(labId: $labId, testId: $testId, labName: $labName, testName: $testName, priceEgp: $priceEgp, supportsHomeCollection: $supportsHomeCollection, supportsHomeTestKit: $supportsHomeTestKit, preparation: $preparation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingFlowParamsImpl &&
            (identical(other.labId, labId) || other.labId == labId) &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.testName, testName) ||
                other.testName == testName) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp) &&
            (identical(other.supportsHomeCollection, supportsHomeCollection) ||
                other.supportsHomeCollection == supportsHomeCollection) &&
            (identical(other.supportsHomeTestKit, supportsHomeTestKit) ||
                other.supportsHomeTestKit == supportsHomeTestKit) &&
            (identical(other.preparation, preparation) ||
                other.preparation == preparation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, labId, testId, labName, testName,
      priceEgp, supportsHomeCollection, supportsHomeTestKit, preparation);

  /// Create a copy of BookingFlowParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingFlowParamsImplCopyWith<_$BookingFlowParamsImpl> get copyWith =>
      __$$BookingFlowParamsImplCopyWithImpl<_$BookingFlowParamsImpl>(
          this, _$identity);
}

abstract class _BookingFlowParams implements BookingFlowParams {
  const factory _BookingFlowParams(
      {required final String labId,
      required final String testId,
      required final String labName,
      required final String testName,
      required final int priceEgp,
      required final bool supportsHomeCollection,
      required final bool supportsHomeTestKit,
      final String? preparation}) = _$BookingFlowParamsImpl;

  @override
  String get labId;
  @override
  String get testId;
  @override
  String get labName;
  @override
  String get testName;
  @override
  int get priceEgp;
  @override
  bool get supportsHomeCollection;
  @override
  bool get supportsHomeTestKit;
  @override
  String? get preparation;

  /// Create a copy of BookingFlowParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingFlowParamsImplCopyWith<_$BookingFlowParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
