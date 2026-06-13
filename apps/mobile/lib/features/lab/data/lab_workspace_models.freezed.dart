// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_workspace_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LabInfo _$LabInfoFromJson(Map<String, dynamic> json) {
  return _LabInfo.fromJson(json);
}

/// @nodoc
mixin _$LabInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  bool get homeTestKit => throw _privateConstructorUsedError;

  /// Serializes this LabInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabInfoCopyWith<LabInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabInfoCopyWith<$Res> {
  factory $LabInfoCopyWith(LabInfo value, $Res Function(LabInfo) then) =
      _$LabInfoCopyWithImpl<$Res, LabInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      bool homeCollection,
      bool homeTestKit});
}

/// @nodoc
class _$LabInfoCopyWithImpl<$Res, $Val extends LabInfo>
    implements $LabInfoCopyWith<$Res> {
  _$LabInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabInfo
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
abstract class _$$LabInfoImplCopyWith<$Res> implements $LabInfoCopyWith<$Res> {
  factory _$$LabInfoImplCopyWith(
          _$LabInfoImpl value, $Res Function(_$LabInfoImpl) then) =
      __$$LabInfoImplCopyWithImpl<$Res>;
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
class __$$LabInfoImplCopyWithImpl<$Res>
    extends _$LabInfoCopyWithImpl<$Res, _$LabInfoImpl>
    implements _$$LabInfoImplCopyWith<$Res> {
  __$$LabInfoImplCopyWithImpl(
      _$LabInfoImpl _value, $Res Function(_$LabInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabInfo
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
    return _then(_$LabInfoImpl(
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
class _$LabInfoImpl implements _LabInfo {
  const _$LabInfoImpl(
      {required this.id,
      required this.name,
      required this.address,
      required this.homeCollection,
      required this.homeTestKit});

  factory _$LabInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabInfoImplFromJson(json);

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
    return 'LabInfo(id: $id, name: $name, address: $address, homeCollection: $homeCollection, homeTestKit: $homeTestKit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabInfoImpl &&
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

  /// Create a copy of LabInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabInfoImplCopyWith<_$LabInfoImpl> get copyWith =>
      __$$LabInfoImplCopyWithImpl<_$LabInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabInfoImplToJson(
      this,
    );
  }
}

abstract class _LabInfo implements LabInfo {
  const factory _LabInfo(
      {required final String id,
      required final String name,
      required final String address,
      required final bool homeCollection,
      required final bool homeTestKit}) = _$LabInfoImpl;

  factory _LabInfo.fromJson(Map<String, dynamic> json) = _$LabInfoImpl.fromJson;

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

  /// Create a copy of LabInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabInfoImplCopyWith<_$LabInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabBookingPatient _$LabBookingPatientFromJson(Map<String, dynamic> json) {
  return _LabBookingPatient.fromJson(json);
}

/// @nodoc
mixin _$LabBookingPatient {
  String get id => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this LabBookingPatient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingPatient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingPatientCopyWith<LabBookingPatient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingPatientCopyWith<$Res> {
  factory $LabBookingPatientCopyWith(
          LabBookingPatient value, $Res Function(LabBookingPatient) then) =
      _$LabBookingPatientCopyWithImpl<$Res, LabBookingPatient>;
  @useResult
  $Res call({String id, String? fullName, String? phone});
}

/// @nodoc
class _$LabBookingPatientCopyWithImpl<$Res, $Val extends LabBookingPatient>
    implements $LabBookingPatientCopyWith<$Res> {
  _$LabBookingPatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingPatient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabBookingPatientImplCopyWith<$Res>
    implements $LabBookingPatientCopyWith<$Res> {
  factory _$$LabBookingPatientImplCopyWith(_$LabBookingPatientImpl value,
          $Res Function(_$LabBookingPatientImpl) then) =
      __$$LabBookingPatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? fullName, String? phone});
}

/// @nodoc
class __$$LabBookingPatientImplCopyWithImpl<$Res>
    extends _$LabBookingPatientCopyWithImpl<$Res, _$LabBookingPatientImpl>
    implements _$$LabBookingPatientImplCopyWith<$Res> {
  __$$LabBookingPatientImplCopyWithImpl(_$LabBookingPatientImpl _value,
      $Res Function(_$LabBookingPatientImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingPatient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$LabBookingPatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabBookingPatientImpl implements _LabBookingPatient {
  const _$LabBookingPatientImpl({required this.id, this.fullName, this.phone});

  factory _$LabBookingPatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingPatientImplFromJson(json);

  @override
  final String id;
  @override
  final String? fullName;
  @override
  final String? phone;

  @override
  String toString() {
    return 'LabBookingPatient(id: $id, fullName: $fullName, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingPatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, phone);

  /// Create a copy of LabBookingPatient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingPatientImplCopyWith<_$LabBookingPatientImpl> get copyWith =>
      __$$LabBookingPatientImplCopyWithImpl<_$LabBookingPatientImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingPatientImplToJson(
      this,
    );
  }
}

abstract class _LabBookingPatient implements LabBookingPatient {
  const factory _LabBookingPatient(
      {required final String id,
      final String? fullName,
      final String? phone}) = _$LabBookingPatientImpl;

  factory _LabBookingPatient.fromJson(Map<String, dynamic> json) =
      _$LabBookingPatientImpl.fromJson;

  @override
  String get id;
  @override
  String? get fullName;
  @override
  String? get phone;

  /// Create a copy of LabBookingPatient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingPatientImplCopyWith<_$LabBookingPatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabBookingLab _$LabBookingLabFromJson(Map<String, dynamic> json) {
  return _LabBookingLab.fromJson(json);
}

/// @nodoc
mixin _$LabBookingLab {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  bool get homeTestKit => throw _privateConstructorUsedError;

  /// Serializes this LabBookingLab to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingLabCopyWith<LabBookingLab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingLabCopyWith<$Res> {
  factory $LabBookingLabCopyWith(
          LabBookingLab value, $Res Function(LabBookingLab) then) =
      _$LabBookingLabCopyWithImpl<$Res, LabBookingLab>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      bool homeCollection,
      bool homeTestKit});
}

/// @nodoc
class _$LabBookingLabCopyWithImpl<$Res, $Val extends LabBookingLab>
    implements $LabBookingLabCopyWith<$Res> {
  _$LabBookingLabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingLab
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
abstract class _$$LabBookingLabImplCopyWith<$Res>
    implements $LabBookingLabCopyWith<$Res> {
  factory _$$LabBookingLabImplCopyWith(
          _$LabBookingLabImpl value, $Res Function(_$LabBookingLabImpl) then) =
      __$$LabBookingLabImplCopyWithImpl<$Res>;
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
class __$$LabBookingLabImplCopyWithImpl<$Res>
    extends _$LabBookingLabCopyWithImpl<$Res, _$LabBookingLabImpl>
    implements _$$LabBookingLabImplCopyWith<$Res> {
  __$$LabBookingLabImplCopyWithImpl(
      _$LabBookingLabImpl _value, $Res Function(_$LabBookingLabImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingLab
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
    return _then(_$LabBookingLabImpl(
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
class _$LabBookingLabImpl implements _LabBookingLab {
  const _$LabBookingLabImpl(
      {required this.id,
      required this.name,
      required this.address,
      required this.homeCollection,
      required this.homeTestKit});

  factory _$LabBookingLabImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingLabImplFromJson(json);

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
    return 'LabBookingLab(id: $id, name: $name, address: $address, homeCollection: $homeCollection, homeTestKit: $homeTestKit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingLabImpl &&
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

  /// Create a copy of LabBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingLabImplCopyWith<_$LabBookingLabImpl> get copyWith =>
      __$$LabBookingLabImplCopyWithImpl<_$LabBookingLabImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingLabImplToJson(
      this,
    );
  }
}

abstract class _LabBookingLab implements LabBookingLab {
  const factory _LabBookingLab(
      {required final String id,
      required final String name,
      required final String address,
      required final bool homeCollection,
      required final bool homeTestKit}) = _$LabBookingLabImpl;

  factory _LabBookingLab.fromJson(Map<String, dynamic> json) =
      _$LabBookingLabImpl.fromJson;

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

  /// Create a copy of LabBookingLab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingLabImplCopyWith<_$LabBookingLabImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabBookingTest _$LabBookingTestFromJson(Map<String, dynamic> json) {
  return _LabBookingTest.fromJson(json);
}

/// @nodoc
mixin _$LabBookingTest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;

  /// Serializes this LabBookingTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingTestCopyWith<LabBookingTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingTestCopyWith<$Res> {
  factory $LabBookingTestCopyWith(
          LabBookingTest value, $Res Function(LabBookingTest) then) =
      _$LabBookingTestCopyWithImpl<$Res, LabBookingTest>;
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class _$LabBookingTestCopyWithImpl<$Res, $Val extends LabBookingTest>
    implements $LabBookingTestCopyWith<$Res> {
  _$LabBookingTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingTest
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
abstract class _$$LabBookingTestImplCopyWith<$Res>
    implements $LabBookingTestCopyWith<$Res> {
  factory _$$LabBookingTestImplCopyWith(_$LabBookingTestImpl value,
          $Res Function(_$LabBookingTestImpl) then) =
      __$$LabBookingTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int priceEgp});
}

/// @nodoc
class __$$LabBookingTestImplCopyWithImpl<$Res>
    extends _$LabBookingTestCopyWithImpl<$Res, _$LabBookingTestImpl>
    implements _$$LabBookingTestImplCopyWith<$Res> {
  __$$LabBookingTestImplCopyWithImpl(
      _$LabBookingTestImpl _value, $Res Function(_$LabBookingTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? priceEgp = null,
  }) {
    return _then(_$LabBookingTestImpl(
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
class _$LabBookingTestImpl implements _LabBookingTest {
  const _$LabBookingTestImpl(
      {required this.id, required this.name, required this.priceEgp});

  factory _$LabBookingTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingTestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int priceEgp;

  @override
  String toString() {
    return 'LabBookingTest(id: $id, name: $name, priceEgp: $priceEgp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, priceEgp);

  /// Create a copy of LabBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingTestImplCopyWith<_$LabBookingTestImpl> get copyWith =>
      __$$LabBookingTestImplCopyWithImpl<_$LabBookingTestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingTestImplToJson(
      this,
    );
  }
}

abstract class _LabBookingTest implements LabBookingTest {
  const factory _LabBookingTest(
      {required final String id,
      required final String name,
      required final int priceEgp}) = _$LabBookingTestImpl;

  factory _LabBookingTest.fromJson(Map<String, dynamic> json) =
      _$LabBookingTestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get priceEgp;

  /// Create a copy of LabBookingTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingTestImplCopyWith<_$LabBookingTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabBookingSlot _$LabBookingSlotFromJson(Map<String, dynamic> json) {
  return _LabBookingSlot.fromJson(json);
}

/// @nodoc
mixin _$LabBookingSlot {
  String get id => throw _privateConstructorUsedError;
  String get startsAt => throw _privateConstructorUsedError;
  String get endsAt => throw _privateConstructorUsedError;

  /// Serializes this LabBookingSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingSlotCopyWith<LabBookingSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingSlotCopyWith<$Res> {
  factory $LabBookingSlotCopyWith(
          LabBookingSlot value, $Res Function(LabBookingSlot) then) =
      _$LabBookingSlotCopyWithImpl<$Res, LabBookingSlot>;
  @useResult
  $Res call({String id, String startsAt, String endsAt});
}

/// @nodoc
class _$LabBookingSlotCopyWithImpl<$Res, $Val extends LabBookingSlot>
    implements $LabBookingSlotCopyWith<$Res> {
  _$LabBookingSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingSlot
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
abstract class _$$LabBookingSlotImplCopyWith<$Res>
    implements $LabBookingSlotCopyWith<$Res> {
  factory _$$LabBookingSlotImplCopyWith(_$LabBookingSlotImpl value,
          $Res Function(_$LabBookingSlotImpl) then) =
      __$$LabBookingSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String startsAt, String endsAt});
}

/// @nodoc
class __$$LabBookingSlotImplCopyWithImpl<$Res>
    extends _$LabBookingSlotCopyWithImpl<$Res, _$LabBookingSlotImpl>
    implements _$$LabBookingSlotImplCopyWith<$Res> {
  __$$LabBookingSlotImplCopyWithImpl(
      _$LabBookingSlotImpl _value, $Res Function(_$LabBookingSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startsAt = null,
    Object? endsAt = null,
  }) {
    return _then(_$LabBookingSlotImpl(
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
class _$LabBookingSlotImpl implements _LabBookingSlot {
  const _$LabBookingSlotImpl(
      {required this.id, required this.startsAt, required this.endsAt});

  factory _$LabBookingSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingSlotImplFromJson(json);

  @override
  final String id;
  @override
  final String startsAt;
  @override
  final String endsAt;

  @override
  String toString() {
    return 'LabBookingSlot(id: $id, startsAt: $startsAt, endsAt: $endsAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startsAt, endsAt);

  /// Create a copy of LabBookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingSlotImplCopyWith<_$LabBookingSlotImpl> get copyWith =>
      __$$LabBookingSlotImplCopyWithImpl<_$LabBookingSlotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingSlotImplToJson(
      this,
    );
  }
}

abstract class _LabBookingSlot implements LabBookingSlot {
  const factory _LabBookingSlot(
      {required final String id,
      required final String startsAt,
      required final String endsAt}) = _$LabBookingSlotImpl;

  factory _LabBookingSlot.fromJson(Map<String, dynamic> json) =
      _$LabBookingSlotImpl.fromJson;

  @override
  String get id;
  @override
  String get startsAt;
  @override
  String get endsAt;

  /// Create a copy of LabBookingSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingSlotImplCopyWith<_$LabBookingSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabBookingTimelineEntry _$LabBookingTimelineEntryFromJson(
    Map<String, dynamic> json) {
  return _LabBookingTimelineEntry.fromJson(json);
}

/// @nodoc
mixin _$LabBookingTimelineEntry {
  String get id => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get actorUserId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LabBookingTimelineEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingTimelineEntryCopyWith<LabBookingTimelineEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingTimelineEntryCopyWith<$Res> {
  factory $LabBookingTimelineEntryCopyWith(LabBookingTimelineEntry value,
          $Res Function(LabBookingTimelineEntry) then) =
      _$LabBookingTimelineEntryCopyWithImpl<$Res, LabBookingTimelineEntry>;
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      String? note,
      String? actorUserId,
      String createdAt});
}

/// @nodoc
class _$LabBookingTimelineEntryCopyWithImpl<$Res,
        $Val extends LabBookingTimelineEntry>
    implements $LabBookingTimelineEntryCopyWith<$Res> {
  _$LabBookingTimelineEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? note = freezed,
    Object? actorUserId = freezed,
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
      actorUserId: freezed == actorUserId
          ? _value.actorUserId
          : actorUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabBookingTimelineEntryImplCopyWith<$Res>
    implements $LabBookingTimelineEntryCopyWith<$Res> {
  factory _$$LabBookingTimelineEntryImplCopyWith(
          _$LabBookingTimelineEntryImpl value,
          $Res Function(_$LabBookingTimelineEntryImpl) then) =
      __$$LabBookingTimelineEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      BookingStatus status,
      String? note,
      String? actorUserId,
      String createdAt});
}

/// @nodoc
class __$$LabBookingTimelineEntryImplCopyWithImpl<$Res>
    extends _$LabBookingTimelineEntryCopyWithImpl<$Res,
        _$LabBookingTimelineEntryImpl>
    implements _$$LabBookingTimelineEntryImplCopyWith<$Res> {
  __$$LabBookingTimelineEntryImplCopyWithImpl(
      _$LabBookingTimelineEntryImpl _value,
      $Res Function(_$LabBookingTimelineEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? note = freezed,
    Object? actorUserId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$LabBookingTimelineEntryImpl(
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
      actorUserId: freezed == actorUserId
          ? _value.actorUserId
          : actorUserId // ignore: cast_nullable_to_non_nullable
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
class _$LabBookingTimelineEntryImpl implements _LabBookingTimelineEntry {
  const _$LabBookingTimelineEntryImpl(
      {required this.id,
      required this.status,
      this.note,
      this.actorUserId,
      required this.createdAt});

  factory _$LabBookingTimelineEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingTimelineEntryImplFromJson(json);

  @override
  final String id;
  @override
  final BookingStatus status;
  @override
  final String? note;
  @override
  final String? actorUserId;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'LabBookingTimelineEntry(id: $id, status: $status, note: $note, actorUserId: $actorUserId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingTimelineEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.actorUserId, actorUserId) ||
                other.actorUserId == actorUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, status, note, actorUserId, createdAt);

  /// Create a copy of LabBookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingTimelineEntryImplCopyWith<_$LabBookingTimelineEntryImpl>
      get copyWith => __$$LabBookingTimelineEntryImplCopyWithImpl<
          _$LabBookingTimelineEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingTimelineEntryImplToJson(
      this,
    );
  }
}

abstract class _LabBookingTimelineEntry implements LabBookingTimelineEntry {
  const factory _LabBookingTimelineEntry(
      {required final String id,
      required final BookingStatus status,
      final String? note,
      final String? actorUserId,
      required final String createdAt}) = _$LabBookingTimelineEntryImpl;

  factory _LabBookingTimelineEntry.fromJson(Map<String, dynamic> json) =
      _$LabBookingTimelineEntryImpl.fromJson;

  @override
  String get id;
  @override
  BookingStatus get status;
  @override
  String? get note;
  @override
  String? get actorUserId;
  @override
  String get createdAt;

  /// Create a copy of LabBookingTimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingTimelineEntryImplCopyWith<_$LabBookingTimelineEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LabBookingItem _$LabBookingItemFromJson(Map<String, dynamic> json) {
  return _LabBookingItem.fromJson(json);
}

/// @nodoc
mixin _$LabBookingItem {
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
  String get createdAt => throw _privateConstructorUsedError;
  LabBookingPatient get patient => throw _privateConstructorUsedError;
  LabBookingLab get lab => throw _privateConstructorUsedError;
  LabBookingTest get test => throw _privateConstructorUsedError;
  LabBookingSlot? get slot => throw _privateConstructorUsedError;
  List<LabBookingTimelineEntry> get timeline =>
      throw _privateConstructorUsedError;

  /// Serializes this LabBookingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabBookingItemCopyWith<LabBookingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabBookingItemCopyWith<$Res> {
  factory $LabBookingItemCopyWith(
          LabBookingItem value, $Res Function(LabBookingItem) then) =
      _$LabBookingItemCopyWithImpl<$Res, LabBookingItem>;
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
      String createdAt,
      LabBookingPatient patient,
      LabBookingLab lab,
      LabBookingTest test,
      LabBookingSlot? slot,
      List<LabBookingTimelineEntry> timeline});

  $LabBookingPatientCopyWith<$Res> get patient;
  $LabBookingLabCopyWith<$Res> get lab;
  $LabBookingTestCopyWith<$Res> get test;
  $LabBookingSlotCopyWith<$Res>? get slot;
}

/// @nodoc
class _$LabBookingItemCopyWithImpl<$Res, $Val extends LabBookingItem>
    implements $LabBookingItemCopyWith<$Res> {
  _$LabBookingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabBookingItem
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
    Object? createdAt = null,
    Object? patient = null,
    Object? lab = null,
    Object? test = null,
    Object? slot = freezed,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      patient: null == patient
          ? _value.patient
          : patient // ignore: cast_nullable_to_non_nullable
              as LabBookingPatient,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as LabBookingLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as LabBookingTest,
      slot: freezed == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as LabBookingSlot?,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<LabBookingTimelineEntry>,
    ) as $Val);
  }

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabBookingPatientCopyWith<$Res> get patient {
    return $LabBookingPatientCopyWith<$Res>(_value.patient, (value) {
      return _then(_value.copyWith(patient: value) as $Val);
    });
  }

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabBookingLabCopyWith<$Res> get lab {
    return $LabBookingLabCopyWith<$Res>(_value.lab, (value) {
      return _then(_value.copyWith(lab: value) as $Val);
    });
  }

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabBookingTestCopyWith<$Res> get test {
    return $LabBookingTestCopyWith<$Res>(_value.test, (value) {
      return _then(_value.copyWith(test: value) as $Val);
    });
  }

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabBookingSlotCopyWith<$Res>? get slot {
    if (_value.slot == null) {
      return null;
    }

    return $LabBookingSlotCopyWith<$Res>(_value.slot!, (value) {
      return _then(_value.copyWith(slot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LabBookingItemImplCopyWith<$Res>
    implements $LabBookingItemCopyWith<$Res> {
  factory _$$LabBookingItemImplCopyWith(_$LabBookingItemImpl value,
          $Res Function(_$LabBookingItemImpl) then) =
      __$$LabBookingItemImplCopyWithImpl<$Res>;
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
      String createdAt,
      LabBookingPatient patient,
      LabBookingLab lab,
      LabBookingTest test,
      LabBookingSlot? slot,
      List<LabBookingTimelineEntry> timeline});

  @override
  $LabBookingPatientCopyWith<$Res> get patient;
  @override
  $LabBookingLabCopyWith<$Res> get lab;
  @override
  $LabBookingTestCopyWith<$Res> get test;
  @override
  $LabBookingSlotCopyWith<$Res>? get slot;
}

/// @nodoc
class __$$LabBookingItemImplCopyWithImpl<$Res>
    extends _$LabBookingItemCopyWithImpl<$Res, _$LabBookingItemImpl>
    implements _$$LabBookingItemImplCopyWith<$Res> {
  __$$LabBookingItemImplCopyWithImpl(
      _$LabBookingItemImpl _value, $Res Function(_$LabBookingItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabBookingItem
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
    Object? createdAt = null,
    Object? patient = null,
    Object? lab = null,
    Object? test = null,
    Object? slot = freezed,
    Object? timeline = null,
  }) {
    return _then(_$LabBookingItemImpl(
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      patient: null == patient
          ? _value.patient
          : patient // ignore: cast_nullable_to_non_nullable
              as LabBookingPatient,
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as LabBookingLab,
      test: null == test
          ? _value.test
          : test // ignore: cast_nullable_to_non_nullable
              as LabBookingTest,
      slot: freezed == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as LabBookingSlot?,
      timeline: null == timeline
          ? _value._timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<LabBookingTimelineEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabBookingItemImpl implements _LabBookingItem {
  const _$LabBookingItemImpl(
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
      required this.createdAt,
      required this.patient,
      required this.lab,
      required this.test,
      this.slot,
      required final List<LabBookingTimelineEntry> timeline})
      : _timeline = timeline;

  factory _$LabBookingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabBookingItemImplFromJson(json);

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
  final String createdAt;
  @override
  final LabBookingPatient patient;
  @override
  final LabBookingLab lab;
  @override
  final LabBookingTest test;
  @override
  final LabBookingSlot? slot;
  final List<LabBookingTimelineEntry> _timeline;
  @override
  List<LabBookingTimelineEntry> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  String toString() {
    return 'LabBookingItem(id: $id, status: $status, bookingType: $bookingType, scheduledAt: $scheduledAt, homeAddress: $homeAddress, totalPriceEgp: $totalPriceEgp, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentPaidAt: $paymentPaidAt, paymentFailedAt: $paymentFailedAt, paymentFailureReason: $paymentFailureReason, kitStatus: $kitStatus, kitTrackingNumber: $kitTrackingNumber, kitShippedAt: $kitShippedAt, kitDeliveredAt: $kitDeliveredAt, sampleReceivedAt: $sampleReceivedAt, createdAt: $createdAt, patient: $patient, lab: $lab, test: $test, slot: $slot, timeline: $timeline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabBookingItemImpl &&
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
            (identical(other.patient, patient) || other.patient == patient) &&
            (identical(other.lab, lab) || other.lab == lab) &&
            (identical(other.test, test) || other.test == test) &&
            (identical(other.slot, slot) || other.slot == slot) &&
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
        patient,
        lab,
        test,
        slot,
        const DeepCollectionEquality().hash(_timeline)
      ]);

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabBookingItemImplCopyWith<_$LabBookingItemImpl> get copyWith =>
      __$$LabBookingItemImplCopyWithImpl<_$LabBookingItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabBookingItemImplToJson(
      this,
    );
  }
}

abstract class _LabBookingItem implements LabBookingItem {
  const factory _LabBookingItem(
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
          required final String createdAt,
          required final LabBookingPatient patient,
          required final LabBookingLab lab,
          required final LabBookingTest test,
          final LabBookingSlot? slot,
          required final List<LabBookingTimelineEntry> timeline}) =
      _$LabBookingItemImpl;

  factory _LabBookingItem.fromJson(Map<String, dynamic> json) =
      _$LabBookingItemImpl.fromJson;

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
  String get createdAt;
  @override
  LabBookingPatient get patient;
  @override
  LabBookingLab get lab;
  @override
  LabBookingTest get test;
  @override
  LabBookingSlot? get slot;
  @override
  List<LabBookingTimelineEntry> get timeline;

  /// Create a copy of LabBookingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabBookingItemImplCopyWith<_$LabBookingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabTest _$LabTestFromJson(Map<String, dynamic> json) {
  return _LabTest.fromJson(json);
}

/// @nodoc
mixin _$LabTest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get preparation => throw _privateConstructorUsedError;
  String get turnaroundTime => throw _privateConstructorUsedError;
  int? get parametersCount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this LabTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabTestCopyWith<LabTest> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabTestCopyWith<$Res> {
  factory $LabTestCopyWith(LabTest value, $Res Function(LabTest) then) =
      _$LabTestCopyWithImpl<$Res, LabTest>;
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      int priceEgp,
      String description,
      String preparation,
      String turnaroundTime,
      int? parametersCount,
      bool isActive});
}

/// @nodoc
class _$LabTestCopyWithImpl<$Res, $Val extends LabTest>
    implements $LabTestCopyWith<$Res> {
  _$LabTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? priceEgp = null,
    Object? description = null,
    Object? preparation = null,
    Object? turnaroundTime = null,
    Object? parametersCount = freezed,
    Object? isActive = null,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preparation: null == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String,
      turnaroundTime: null == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabTestImplCopyWith<$Res> implements $LabTestCopyWith<$Res> {
  factory _$$LabTestImplCopyWith(
          _$LabTestImpl value, $Res Function(_$LabTestImpl) then) =
      __$$LabTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      int priceEgp,
      String description,
      String preparation,
      String turnaroundTime,
      int? parametersCount,
      bool isActive});
}

/// @nodoc
class __$$LabTestImplCopyWithImpl<$Res>
    extends _$LabTestCopyWithImpl<$Res, _$LabTestImpl>
    implements _$$LabTestImplCopyWith<$Res> {
  __$$LabTestImplCopyWithImpl(
      _$LabTestImpl _value, $Res Function(_$LabTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? priceEgp = null,
    Object? description = null,
    Object? preparation = null,
    Object? turnaroundTime = null,
    Object? parametersCount = freezed,
    Object? isActive = null,
  }) {
    return _then(_$LabTestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preparation: null == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String,
      turnaroundTime: null == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabTestImpl implements _LabTest {
  const _$LabTestImpl(
      {required this.id,
      required this.name,
      required this.category,
      required this.priceEgp,
      this.description = '',
      this.preparation = '',
      this.turnaroundTime = '',
      this.parametersCount,
      required this.isActive});

  factory _$LabTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabTestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  @override
  final int priceEgp;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String preparation;
  @override
  @JsonKey()
  final String turnaroundTime;
  @override
  final int? parametersCount;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'LabTest(id: $id, name: $name, category: $category, priceEgp: $priceEgp, description: $description, preparation: $preparation, turnaroundTime: $turnaroundTime, parametersCount: $parametersCount, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.preparation, preparation) ||
                other.preparation == preparation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime) &&
            (identical(other.parametersCount, parametersCount) ||
                other.parametersCount == parametersCount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, category, priceEgp,
      description, preparation, turnaroundTime, parametersCount, isActive);

  /// Create a copy of LabTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabTestImplCopyWith<_$LabTestImpl> get copyWith =>
      __$$LabTestImplCopyWithImpl<_$LabTestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabTestImplToJson(
      this,
    );
  }
}

abstract class _LabTest implements LabTest {
  const factory _LabTest(
      {required final String id,
      required final String name,
      required final String category,
      required final int priceEgp,
      final String description,
      final String preparation,
      final String turnaroundTime,
      final int? parametersCount,
      required final bool isActive}) = _$LabTestImpl;

  factory _LabTest.fromJson(Map<String, dynamic> json) = _$LabTestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category;
  @override
  int get priceEgp;
  @override
  String get description;
  @override
  String get preparation;
  @override
  String get turnaroundTime;
  @override
  int? get parametersCount;
  @override
  bool get isActive;

  /// Create a copy of LabTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabTestImplCopyWith<_$LabTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabScheduleSlot _$LabScheduleSlotFromJson(Map<String, dynamic> json) {
  return _LabScheduleSlot.fromJson(json);
}

/// @nodoc
mixin _$LabScheduleSlot {
  String get id => throw _privateConstructorUsedError;
  String get startsAt => throw _privateConstructorUsedError;
  String get endsAt => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this LabScheduleSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabScheduleSlotCopyWith<LabScheduleSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabScheduleSlotCopyWith<$Res> {
  factory $LabScheduleSlotCopyWith(
          LabScheduleSlot value, $Res Function(LabScheduleSlot) then) =
      _$LabScheduleSlotCopyWithImpl<$Res, LabScheduleSlot>;
  @useResult
  $Res call(
      {String id, String startsAt, String endsAt, int capacity, bool isActive});
}

/// @nodoc
class _$LabScheduleSlotCopyWithImpl<$Res, $Val extends LabScheduleSlot>
    implements $LabScheduleSlotCopyWith<$Res> {
  _$LabScheduleSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? capacity = null,
    Object? isActive = null,
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
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabScheduleSlotImplCopyWith<$Res>
    implements $LabScheduleSlotCopyWith<$Res> {
  factory _$$LabScheduleSlotImplCopyWith(_$LabScheduleSlotImpl value,
          $Res Function(_$LabScheduleSlotImpl) then) =
      __$$LabScheduleSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String startsAt, String endsAt, int capacity, bool isActive});
}

/// @nodoc
class __$$LabScheduleSlotImplCopyWithImpl<$Res>
    extends _$LabScheduleSlotCopyWithImpl<$Res, _$LabScheduleSlotImpl>
    implements _$$LabScheduleSlotImplCopyWith<$Res> {
  __$$LabScheduleSlotImplCopyWithImpl(
      _$LabScheduleSlotImpl _value, $Res Function(_$LabScheduleSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? capacity = null,
    Object? isActive = null,
  }) {
    return _then(_$LabScheduleSlotImpl(
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
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabScheduleSlotImpl implements _LabScheduleSlot {
  const _$LabScheduleSlotImpl(
      {required this.id,
      required this.startsAt,
      required this.endsAt,
      required this.capacity,
      required this.isActive});

  factory _$LabScheduleSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabScheduleSlotImplFromJson(json);

  @override
  final String id;
  @override
  final String startsAt;
  @override
  final String endsAt;
  @override
  final int capacity;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'LabScheduleSlot(id: $id, startsAt: $startsAt, endsAt: $endsAt, capacity: $capacity, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabScheduleSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startsAt, endsAt, capacity, isActive);

  /// Create a copy of LabScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabScheduleSlotImplCopyWith<_$LabScheduleSlotImpl> get copyWith =>
      __$$LabScheduleSlotImplCopyWithImpl<_$LabScheduleSlotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabScheduleSlotImplToJson(
      this,
    );
  }
}

abstract class _LabScheduleSlot implements LabScheduleSlot {
  const factory _LabScheduleSlot(
      {required final String id,
      required final String startsAt,
      required final String endsAt,
      required final int capacity,
      required final bool isActive}) = _$LabScheduleSlotImpl;

  factory _LabScheduleSlot.fromJson(Map<String, dynamic> json) =
      _$LabScheduleSlotImpl.fromJson;

  @override
  String get id;
  @override
  String get startsAt;
  @override
  String get endsAt;
  @override
  int get capacity;
  @override
  bool get isActive;

  /// Create a copy of LabScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabScheduleSlotImplCopyWith<_$LabScheduleSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabTopTest _$LabTopTestFromJson(Map<String, dynamic> json) {
  return _LabTopTest.fromJson(json);
}

/// @nodoc
mixin _$LabTopTest {
  String get testId => throw _privateConstructorUsedError;
  String get testName => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this LabTopTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabTopTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabTopTestCopyWith<LabTopTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabTopTestCopyWith<$Res> {
  factory $LabTopTestCopyWith(
          LabTopTest value, $Res Function(LabTopTest) then) =
      _$LabTopTestCopyWithImpl<$Res, LabTopTest>;
  @useResult
  $Res call({String testId, String testName, int count});
}

/// @nodoc
class _$LabTopTestCopyWithImpl<$Res, $Val extends LabTopTest>
    implements $LabTopTestCopyWith<$Res> {
  _$LabTopTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabTopTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? testName = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabTopTestImplCopyWith<$Res>
    implements $LabTopTestCopyWith<$Res> {
  factory _$$LabTopTestImplCopyWith(
          _$LabTopTestImpl value, $Res Function(_$LabTopTestImpl) then) =
      __$$LabTopTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String testId, String testName, int count});
}

/// @nodoc
class __$$LabTopTestImplCopyWithImpl<$Res>
    extends _$LabTopTestCopyWithImpl<$Res, _$LabTopTestImpl>
    implements _$$LabTopTestImplCopyWith<$Res> {
  __$$LabTopTestImplCopyWithImpl(
      _$LabTopTestImpl _value, $Res Function(_$LabTopTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabTopTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? testName = null,
    Object? count = null,
  }) {
    return _then(_$LabTopTestImpl(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      testName: null == testName
          ? _value.testName
          : testName // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabTopTestImpl implements _LabTopTest {
  const _$LabTopTestImpl(
      {required this.testId, required this.testName, required this.count});

  factory _$LabTopTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabTopTestImplFromJson(json);

  @override
  final String testId;
  @override
  final String testName;
  @override
  final int count;

  @override
  String toString() {
    return 'LabTopTest(testId: $testId, testName: $testName, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabTopTestImpl &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.testName, testName) ||
                other.testName == testName) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, testId, testName, count);

  /// Create a copy of LabTopTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabTopTestImplCopyWith<_$LabTopTestImpl> get copyWith =>
      __$$LabTopTestImplCopyWithImpl<_$LabTopTestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabTopTestImplToJson(
      this,
    );
  }
}

abstract class _LabTopTest implements LabTopTest {
  const factory _LabTopTest(
      {required final String testId,
      required final String testName,
      required final int count}) = _$LabTopTestImpl;

  factory _LabTopTest.fromJson(Map<String, dynamic> json) =
      _$LabTopTestImpl.fromJson;

  @override
  String get testId;
  @override
  String get testName;
  @override
  int get count;

  /// Create a copy of LabTopTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabTopTestImplCopyWith<_$LabTopTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabAnalytics _$LabAnalyticsFromJson(Map<String, dynamic> json) {
  return _LabAnalytics.fromJson(json);
}

/// @nodoc
mixin _$LabAnalytics {
  int get totalBookings => throw _privateConstructorUsedError;
  int get completedBookings => throw _privateConstructorUsedError;
  int get pendingResults => throw _privateConstructorUsedError;
  int get revenueEstimateEgp => throw _privateConstructorUsedError;
  double get capacityUsagePercent => throw _privateConstructorUsedError;
  List<LabTopTest> get topTests => throw _privateConstructorUsedError;

  /// Serializes this LabAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabAnalyticsCopyWith<LabAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabAnalyticsCopyWith<$Res> {
  factory $LabAnalyticsCopyWith(
          LabAnalytics value, $Res Function(LabAnalytics) then) =
      _$LabAnalyticsCopyWithImpl<$Res, LabAnalytics>;
  @useResult
  $Res call(
      {int totalBookings,
      int completedBookings,
      int pendingResults,
      int revenueEstimateEgp,
      double capacityUsagePercent,
      List<LabTopTest> topTests});
}

/// @nodoc
class _$LabAnalyticsCopyWithImpl<$Res, $Val extends LabAnalytics>
    implements $LabAnalyticsCopyWith<$Res> {
  _$LabAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? pendingResults = null,
    Object? revenueEstimateEgp = null,
    Object? capacityUsagePercent = null,
    Object? topTests = null,
  }) {
    return _then(_value.copyWith(
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingResults: null == pendingResults
          ? _value.pendingResults
          : pendingResults // ignore: cast_nullable_to_non_nullable
              as int,
      revenueEstimateEgp: null == revenueEstimateEgp
          ? _value.revenueEstimateEgp
          : revenueEstimateEgp // ignore: cast_nullable_to_non_nullable
              as int,
      capacityUsagePercent: null == capacityUsagePercent
          ? _value.capacityUsagePercent
          : capacityUsagePercent // ignore: cast_nullable_to_non_nullable
              as double,
      topTests: null == topTests
          ? _value.topTests
          : topTests // ignore: cast_nullable_to_non_nullable
              as List<LabTopTest>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabAnalyticsImplCopyWith<$Res>
    implements $LabAnalyticsCopyWith<$Res> {
  factory _$$LabAnalyticsImplCopyWith(
          _$LabAnalyticsImpl value, $Res Function(_$LabAnalyticsImpl) then) =
      __$$LabAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalBookings,
      int completedBookings,
      int pendingResults,
      int revenueEstimateEgp,
      double capacityUsagePercent,
      List<LabTopTest> topTests});
}

/// @nodoc
class __$$LabAnalyticsImplCopyWithImpl<$Res>
    extends _$LabAnalyticsCopyWithImpl<$Res, _$LabAnalyticsImpl>
    implements _$$LabAnalyticsImplCopyWith<$Res> {
  __$$LabAnalyticsImplCopyWithImpl(
      _$LabAnalyticsImpl _value, $Res Function(_$LabAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? pendingResults = null,
    Object? revenueEstimateEgp = null,
    Object? capacityUsagePercent = null,
    Object? topTests = null,
  }) {
    return _then(_$LabAnalyticsImpl(
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingResults: null == pendingResults
          ? _value.pendingResults
          : pendingResults // ignore: cast_nullable_to_non_nullable
              as int,
      revenueEstimateEgp: null == revenueEstimateEgp
          ? _value.revenueEstimateEgp
          : revenueEstimateEgp // ignore: cast_nullable_to_non_nullable
              as int,
      capacityUsagePercent: null == capacityUsagePercent
          ? _value.capacityUsagePercent
          : capacityUsagePercent // ignore: cast_nullable_to_non_nullable
              as double,
      topTests: null == topTests
          ? _value._topTests
          : topTests // ignore: cast_nullable_to_non_nullable
              as List<LabTopTest>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabAnalyticsImpl implements _LabAnalytics {
  const _$LabAnalyticsImpl(
      {required this.totalBookings,
      required this.completedBookings,
      required this.pendingResults,
      required this.revenueEstimateEgp,
      required this.capacityUsagePercent,
      required final List<LabTopTest> topTests})
      : _topTests = topTests;

  factory _$LabAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabAnalyticsImplFromJson(json);

  @override
  final int totalBookings;
  @override
  final int completedBookings;
  @override
  final int pendingResults;
  @override
  final int revenueEstimateEgp;
  @override
  final double capacityUsagePercent;
  final List<LabTopTest> _topTests;
  @override
  List<LabTopTest> get topTests {
    if (_topTests is EqualUnmodifiableListView) return _topTests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topTests);
  }

  @override
  String toString() {
    return 'LabAnalytics(totalBookings: $totalBookings, completedBookings: $completedBookings, pendingResults: $pendingResults, revenueEstimateEgp: $revenueEstimateEgp, capacityUsagePercent: $capacityUsagePercent, topTests: $topTests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabAnalyticsImpl &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.completedBookings, completedBookings) ||
                other.completedBookings == completedBookings) &&
            (identical(other.pendingResults, pendingResults) ||
                other.pendingResults == pendingResults) &&
            (identical(other.revenueEstimateEgp, revenueEstimateEgp) ||
                other.revenueEstimateEgp == revenueEstimateEgp) &&
            (identical(other.capacityUsagePercent, capacityUsagePercent) ||
                other.capacityUsagePercent == capacityUsagePercent) &&
            const DeepCollectionEquality().equals(other._topTests, _topTests));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalBookings,
      completedBookings,
      pendingResults,
      revenueEstimateEgp,
      capacityUsagePercent,
      const DeepCollectionEquality().hash(_topTests));

  /// Create a copy of LabAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabAnalyticsImplCopyWith<_$LabAnalyticsImpl> get copyWith =>
      __$$LabAnalyticsImplCopyWithImpl<_$LabAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _LabAnalytics implements LabAnalytics {
  const factory _LabAnalytics(
      {required final int totalBookings,
      required final int completedBookings,
      required final int pendingResults,
      required final int revenueEstimateEgp,
      required final double capacityUsagePercent,
      required final List<LabTopTest> topTests}) = _$LabAnalyticsImpl;

  factory _LabAnalytics.fromJson(Map<String, dynamic> json) =
      _$LabAnalyticsImpl.fromJson;

  @override
  int get totalBookings;
  @override
  int get completedBookings;
  @override
  int get pendingResults;
  @override
  int get revenueEstimateEgp;
  @override
  double get capacityUsagePercent;
  @override
  List<LabTopTest> get topTests;

  /// Create a copy of LabAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabAnalyticsImplCopyWith<_$LabAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabWorkspaceResponse _$LabWorkspaceResponseFromJson(Map<String, dynamic> json) {
  return _LabWorkspaceResponse.fromJson(json);
}

/// @nodoc
mixin _$LabWorkspaceResponse {
  LabInfo get lab => throw _privateConstructorUsedError;
  List<LabBookingItem> get bookings => throw _privateConstructorUsedError;
  List<LabTest> get tests => throw _privateConstructorUsedError;
  List<LabScheduleSlot> get schedule => throw _privateConstructorUsedError;
  LabAnalytics get analytics => throw _privateConstructorUsedError;

  /// Serializes this LabWorkspaceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabWorkspaceResponseCopyWith<LabWorkspaceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabWorkspaceResponseCopyWith<$Res> {
  factory $LabWorkspaceResponseCopyWith(LabWorkspaceResponse value,
          $Res Function(LabWorkspaceResponse) then) =
      _$LabWorkspaceResponseCopyWithImpl<$Res, LabWorkspaceResponse>;
  @useResult
  $Res call(
      {LabInfo lab,
      List<LabBookingItem> bookings,
      List<LabTest> tests,
      List<LabScheduleSlot> schedule,
      LabAnalytics analytics});

  $LabInfoCopyWith<$Res> get lab;
  $LabAnalyticsCopyWith<$Res> get analytics;
}

/// @nodoc
class _$LabWorkspaceResponseCopyWithImpl<$Res,
        $Val extends LabWorkspaceResponse>
    implements $LabWorkspaceResponseCopyWith<$Res> {
  _$LabWorkspaceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lab = null,
    Object? bookings = null,
    Object? tests = null,
    Object? schedule = null,
    Object? analytics = null,
  }) {
    return _then(_value.copyWith(
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as LabInfo,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as List<LabBookingItem>,
      tests: null == tests
          ? _value.tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<LabTest>,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<LabScheduleSlot>,
      analytics: null == analytics
          ? _value.analytics
          : analytics // ignore: cast_nullable_to_non_nullable
              as LabAnalytics,
    ) as $Val);
  }

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabInfoCopyWith<$Res> get lab {
    return $LabInfoCopyWith<$Res>(_value.lab, (value) {
      return _then(_value.copyWith(lab: value) as $Val);
    });
  }

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabAnalyticsCopyWith<$Res> get analytics {
    return $LabAnalyticsCopyWith<$Res>(_value.analytics, (value) {
      return _then(_value.copyWith(analytics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LabWorkspaceResponseImplCopyWith<$Res>
    implements $LabWorkspaceResponseCopyWith<$Res> {
  factory _$$LabWorkspaceResponseImplCopyWith(_$LabWorkspaceResponseImpl value,
          $Res Function(_$LabWorkspaceResponseImpl) then) =
      __$$LabWorkspaceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LabInfo lab,
      List<LabBookingItem> bookings,
      List<LabTest> tests,
      List<LabScheduleSlot> schedule,
      LabAnalytics analytics});

  @override
  $LabInfoCopyWith<$Res> get lab;
  @override
  $LabAnalyticsCopyWith<$Res> get analytics;
}

/// @nodoc
class __$$LabWorkspaceResponseImplCopyWithImpl<$Res>
    extends _$LabWorkspaceResponseCopyWithImpl<$Res, _$LabWorkspaceResponseImpl>
    implements _$$LabWorkspaceResponseImplCopyWith<$Res> {
  __$$LabWorkspaceResponseImplCopyWithImpl(_$LabWorkspaceResponseImpl _value,
      $Res Function(_$LabWorkspaceResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lab = null,
    Object? bookings = null,
    Object? tests = null,
    Object? schedule = null,
    Object? analytics = null,
  }) {
    return _then(_$LabWorkspaceResponseImpl(
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as LabInfo,
      bookings: null == bookings
          ? _value._bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as List<LabBookingItem>,
      tests: null == tests
          ? _value._tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<LabTest>,
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<LabScheduleSlot>,
      analytics: null == analytics
          ? _value.analytics
          : analytics // ignore: cast_nullable_to_non_nullable
              as LabAnalytics,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabWorkspaceResponseImpl implements _LabWorkspaceResponse {
  const _$LabWorkspaceResponseImpl(
      {required this.lab,
      required final List<LabBookingItem> bookings,
      required final List<LabTest> tests,
      required final List<LabScheduleSlot> schedule,
      required this.analytics})
      : _bookings = bookings,
        _tests = tests,
        _schedule = schedule;

  factory _$LabWorkspaceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabWorkspaceResponseImplFromJson(json);

  @override
  final LabInfo lab;
  final List<LabBookingItem> _bookings;
  @override
  List<LabBookingItem> get bookings {
    if (_bookings is EqualUnmodifiableListView) return _bookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookings);
  }

  final List<LabTest> _tests;
  @override
  List<LabTest> get tests {
    if (_tests is EqualUnmodifiableListView) return _tests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tests);
  }

  final List<LabScheduleSlot> _schedule;
  @override
  List<LabScheduleSlot> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  @override
  final LabAnalytics analytics;

  @override
  String toString() {
    return 'LabWorkspaceResponse(lab: $lab, bookings: $bookings, tests: $tests, schedule: $schedule, analytics: $analytics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabWorkspaceResponseImpl &&
            (identical(other.lab, lab) || other.lab == lab) &&
            const DeepCollectionEquality().equals(other._bookings, _bookings) &&
            const DeepCollectionEquality().equals(other._tests, _tests) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.analytics, analytics) ||
                other.analytics == analytics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lab,
      const DeepCollectionEquality().hash(_bookings),
      const DeepCollectionEquality().hash(_tests),
      const DeepCollectionEquality().hash(_schedule),
      analytics);

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabWorkspaceResponseImplCopyWith<_$LabWorkspaceResponseImpl>
      get copyWith =>
          __$$LabWorkspaceResponseImplCopyWithImpl<_$LabWorkspaceResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabWorkspaceResponseImplToJson(
      this,
    );
  }
}

abstract class _LabWorkspaceResponse implements LabWorkspaceResponse {
  const factory _LabWorkspaceResponse(
      {required final LabInfo lab,
      required final List<LabBookingItem> bookings,
      required final List<LabTest> tests,
      required final List<LabScheduleSlot> schedule,
      required final LabAnalytics analytics}) = _$LabWorkspaceResponseImpl;

  factory _LabWorkspaceResponse.fromJson(Map<String, dynamic> json) =
      _$LabWorkspaceResponseImpl.fromJson;

  @override
  LabInfo get lab;
  @override
  List<LabBookingItem> get bookings;
  @override
  List<LabTest> get tests;
  @override
  List<LabScheduleSlot> get schedule;
  @override
  LabAnalytics get analytics;

  /// Create a copy of LabWorkspaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabWorkspaceResponseImplCopyWith<_$LabWorkspaceResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
