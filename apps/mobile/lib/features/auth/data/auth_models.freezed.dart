// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LabProfile _$LabProfileFromJson(Map<String, dynamic> json) {
  return _LabProfile.fromJson(json);
}

/// @nodoc
mixin _$LabProfile {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'lab_name')
  String get labName => throw _privateConstructorUsedError;
  @JsonKey(name: 'onboarding_status')
  LabOnboardingStatus get onboardingStatus =>
      throw _privateConstructorUsedError;

  /// Serializes this LabProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabProfileCopyWith<LabProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabProfileCopyWith<$Res> {
  factory $LabProfileCopyWith(
          LabProfile value, $Res Function(LabProfile) then) =
      _$LabProfileCopyWithImpl<$Res, LabProfile>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'lab_name') String labName,
      @JsonKey(name: 'onboarding_status')
      LabOnboardingStatus onboardingStatus});
}

/// @nodoc
class _$LabProfileCopyWithImpl<$Res, $Val extends LabProfile>
    implements $LabProfileCopyWith<$Res> {
  _$LabProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? labName = null,
    Object? onboardingStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingStatus: null == onboardingStatus
          ? _value.onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as LabOnboardingStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabProfileImplCopyWith<$Res>
    implements $LabProfileCopyWith<$Res> {
  factory _$$LabProfileImplCopyWith(
          _$LabProfileImpl value, $Res Function(_$LabProfileImpl) then) =
      __$$LabProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'lab_name') String labName,
      @JsonKey(name: 'onboarding_status')
      LabOnboardingStatus onboardingStatus});
}

/// @nodoc
class __$$LabProfileImplCopyWithImpl<$Res>
    extends _$LabProfileCopyWithImpl<$Res, _$LabProfileImpl>
    implements _$$LabProfileImplCopyWith<$Res> {
  __$$LabProfileImplCopyWithImpl(
      _$LabProfileImpl _value, $Res Function(_$LabProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? labName = null,
    Object? onboardingStatus = null,
  }) {
    return _then(_$LabProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingStatus: null == onboardingStatus
          ? _value.onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as LabOnboardingStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabProfileImpl implements _LabProfile {
  const _$LabProfileImpl(
      {required this.id,
      @JsonKey(name: 'lab_name') required this.labName,
      @JsonKey(name: 'onboarding_status') required this.onboardingStatus});

  factory _$LabProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabProfileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'lab_name')
  final String labName;
  @override
  @JsonKey(name: 'onboarding_status')
  final LabOnboardingStatus onboardingStatus;

  @override
  String toString() {
    return 'LabProfile(id: $id, labName: $labName, onboardingStatus: $onboardingStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.onboardingStatus, onboardingStatus) ||
                other.onboardingStatus == onboardingStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, labName, onboardingStatus);

  /// Create a copy of LabProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabProfileImplCopyWith<_$LabProfileImpl> get copyWith =>
      __$$LabProfileImplCopyWithImpl<_$LabProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabProfileImplToJson(
      this,
    );
  }
}

abstract class _LabProfile implements LabProfile {
  const factory _LabProfile(
      {required final String id,
      @JsonKey(name: 'lab_name') required final String labName,
      @JsonKey(name: 'onboarding_status')
      required final LabOnboardingStatus onboardingStatus}) = _$LabProfileImpl;

  factory _LabProfile.fromJson(Map<String, dynamic> json) =
      _$LabProfileImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'lab_name')
  String get labName;
  @override
  @JsonKey(name: 'onboarding_status')
  LabOnboardingStatus get onboardingStatus;

  /// Create a copy of LabProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabProfileImplCopyWith<_$LabProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientProfile _$PatientProfileFromJson(Map<String, dynamic> json) {
  return _PatientProfile.fromJson(json);
}

/// @nodoc
mixin _$PatientProfile {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;

  /// Serializes this PatientProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientProfileCopyWith<PatientProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientProfileCopyWith<$Res> {
  factory $PatientProfileCopyWith(
          PatientProfile value, $Res Function(PatientProfile) then) =
      _$PatientProfileCopyWithImpl<$Res, PatientProfile>;
  @useResult
  $Res call({String id, @JsonKey(name: 'full_name') String? fullName});
}

/// @nodoc
class _$PatientProfileCopyWithImpl<$Res, $Val extends PatientProfile>
    implements $PatientProfileCopyWith<$Res> {
  _$PatientProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientProfileImplCopyWith<$Res>
    implements $PatientProfileCopyWith<$Res> {
  factory _$$PatientProfileImplCopyWith(_$PatientProfileImpl value,
          $Res Function(_$PatientProfileImpl) then) =
      __$$PatientProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, @JsonKey(name: 'full_name') String? fullName});
}

/// @nodoc
class __$$PatientProfileImplCopyWithImpl<$Res>
    extends _$PatientProfileCopyWithImpl<$Res, _$PatientProfileImpl>
    implements _$$PatientProfileImplCopyWith<$Res> {
  __$$PatientProfileImplCopyWithImpl(
      _$PatientProfileImpl _value, $Res Function(_$PatientProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of PatientProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
  }) {
    return _then(_$PatientProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientProfileImpl implements _PatientProfile {
  const _$PatientProfileImpl(
      {required this.id, @JsonKey(name: 'full_name') this.fullName});

  factory _$PatientProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientProfileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;

  @override
  String toString() {
    return 'PatientProfile(id: $id, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName);

  /// Create a copy of PatientProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientProfileImplCopyWith<_$PatientProfileImpl> get copyWith =>
      __$$PatientProfileImplCopyWithImpl<_$PatientProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientProfileImplToJson(
      this,
    );
  }
}

abstract class _PatientProfile implements PatientProfile {
  const factory _PatientProfile(
          {required final String id,
          @JsonKey(name: 'full_name') final String? fullName}) =
      _$PatientProfileImpl;

  factory _PatientProfile.fromJson(Map<String, dynamic> json) =
      _$PatientProfileImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;

  /// Create a copy of PatientProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientProfileImplCopyWith<_$PatientProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return _AuthUser.fromJson(json);
}

/// @nodoc
mixin _$AuthUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'lab_profile')
  LabProfile? get labProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_profile')
  PatientProfile? get patientProfile => throw _privateConstructorUsedError;

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthUserCopyWith<AuthUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthUserCopyWith<$Res> {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) then) =
      _$AuthUserCopyWithImpl<$Res, AuthUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      UserRole role,
      @JsonKey(name: 'lab_profile') LabProfile? labProfile,
      @JsonKey(name: 'patient_profile') PatientProfile? patientProfile});

  $LabProfileCopyWith<$Res>? get labProfile;
  $PatientProfileCopyWith<$Res>? get patientProfile;
}

/// @nodoc
class _$AuthUserCopyWithImpl<$Res, $Val extends AuthUser>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? labProfile = freezed,
    Object? patientProfile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      labProfile: freezed == labProfile
          ? _value.labProfile
          : labProfile // ignore: cast_nullable_to_non_nullable
              as LabProfile?,
      patientProfile: freezed == patientProfile
          ? _value.patientProfile
          : patientProfile // ignore: cast_nullable_to_non_nullable
              as PatientProfile?,
    ) as $Val);
  }

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabProfileCopyWith<$Res>? get labProfile {
    if (_value.labProfile == null) {
      return null;
    }

    return $LabProfileCopyWith<$Res>(_value.labProfile!, (value) {
      return _then(_value.copyWith(labProfile: value) as $Val);
    });
  }

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientProfileCopyWith<$Res>? get patientProfile {
    if (_value.patientProfile == null) {
      return null;
    }

    return $PatientProfileCopyWith<$Res>(_value.patientProfile!, (value) {
      return _then(_value.copyWith(patientProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthUserImplCopyWith<$Res>
    implements $AuthUserCopyWith<$Res> {
  factory _$$AuthUserImplCopyWith(
          _$AuthUserImpl value, $Res Function(_$AuthUserImpl) then) =
      __$$AuthUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      UserRole role,
      @JsonKey(name: 'lab_profile') LabProfile? labProfile,
      @JsonKey(name: 'patient_profile') PatientProfile? patientProfile});

  @override
  $LabProfileCopyWith<$Res>? get labProfile;
  @override
  $PatientProfileCopyWith<$Res>? get patientProfile;
}

/// @nodoc
class __$$AuthUserImplCopyWithImpl<$Res>
    extends _$AuthUserCopyWithImpl<$Res, _$AuthUserImpl>
    implements _$$AuthUserImplCopyWith<$Res> {
  __$$AuthUserImplCopyWithImpl(
      _$AuthUserImpl _value, $Res Function(_$AuthUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? labProfile = freezed,
    Object? patientProfile = freezed,
  }) {
    return _then(_$AuthUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      labProfile: freezed == labProfile
          ? _value.labProfile
          : labProfile // ignore: cast_nullable_to_non_nullable
              as LabProfile?,
      patientProfile: freezed == patientProfile
          ? _value.patientProfile
          : patientProfile // ignore: cast_nullable_to_non_nullable
              as PatientProfile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthUserImpl implements _AuthUser {
  const _$AuthUserImpl(
      {required this.id,
      required this.email,
      required this.role,
      @JsonKey(name: 'lab_profile') this.labProfile,
      @JsonKey(name: 'patient_profile') this.patientProfile});

  factory _$AuthUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final UserRole role;
  @override
  @JsonKey(name: 'lab_profile')
  final LabProfile? labProfile;
  @override
  @JsonKey(name: 'patient_profile')
  final PatientProfile? patientProfile;

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, role: $role, labProfile: $labProfile, patientProfile: $patientProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.labProfile, labProfile) ||
                other.labProfile == labProfile) &&
            (identical(other.patientProfile, patientProfile) ||
                other.patientProfile == patientProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, role, labProfile, patientProfile);

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      __$$AuthUserImplCopyWithImpl<_$AuthUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthUserImplToJson(
      this,
    );
  }
}

abstract class _AuthUser implements AuthUser {
  const factory _AuthUser(
      {required final String id,
      required final String email,
      required final UserRole role,
      @JsonKey(name: 'lab_profile') final LabProfile? labProfile,
      @JsonKey(name: 'patient_profile')
      final PatientProfile? patientProfile}) = _$AuthUserImpl;

  factory _AuthUser.fromJson(Map<String, dynamic> json) =
      _$AuthUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  UserRole get role;
  @override
  @JsonKey(name: 'lab_profile')
  LabProfile? get labProfile;
  @override
  @JsonKey(name: 'patient_profile')
  PatientProfile? get patientProfile;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String get refreshToken => throw _privateConstructorUsedError;
  AuthUser get user => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
          LoginResponse value, $Res Function(LoginResponse) then) =
      _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'refresh_token') String refreshToken,
      AuthUser user});

  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser,
    ) as $Val);
  }

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res> get user {
    return $AuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
          _$LoginResponseImpl value, $Res Function(_$LoginResponseImpl) then) =
      __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'refresh_token') String refreshToken,
      AuthUser user});

  @override
  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
      _$LoginResponseImpl _value, $Res Function(_$LoginResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = null,
  }) {
    return _then(_$LoginResponseImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as AuthUser,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl(
      {@JsonKey(name: 'access_token') required this.accessToken,
      @JsonKey(name: 'refresh_token') required this.refreshToken,
      required this.user});

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @override
  final AuthUser user;

  @override
  String toString() {
    return 'LoginResponse(accessToken: $accessToken, refreshToken: $refreshToken, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken, user);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(
      this,
    );
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse(
      {@JsonKey(name: 'access_token') required final String accessToken,
      @JsonKey(name: 'refresh_token') required final String refreshToken,
      required final AuthUser user}) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  String get refreshToken;
  @override
  AuthUser get user;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
