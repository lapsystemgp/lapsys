// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabProfileImpl _$$LabProfileImplFromJson(Map<String, dynamic> json) =>
    _$LabProfileImpl(
      id: json['id'] as String,
      labName: json['labName'] as String,
      onboardingStatus:
          $enumDecode(_$LabOnboardingStatusEnumMap, json['onboardingStatus']),
    );

Map<String, dynamic> _$$LabProfileImplToJson(_$LabProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'labName': instance.labName,
      'onboardingStatus':
          _$LabOnboardingStatusEnumMap[instance.onboardingStatus]!,
    };

const _$LabOnboardingStatusEnumMap = {
  LabOnboardingStatus.pendingReview: 'PendingReview',
  LabOnboardingStatus.active: 'Active',
  LabOnboardingStatus.rejected: 'Rejected',
  LabOnboardingStatus.suspended: 'Suspended',
};

_$PatientProfileImpl _$$PatientProfileImplFromJson(Map<String, dynamic> json) =>
    _$PatientProfileImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$$PatientProfileImplToJson(
        _$PatientProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
    };

_$AuthUserImpl _$$AuthUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      labProfile: json['labProfile'] == null
          ? null
          : LabProfile.fromJson(json['labProfile'] as Map<String, dynamic>),
      patientProfile: json['patientProfile'] == null
          ? null
          : PatientProfile.fromJson(
              json['patientProfile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthUserImplToJson(_$AuthUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'labProfile': instance.labProfile,
      'patientProfile': instance.patientProfile,
    };

const _$UserRoleEnumMap = {
  UserRole.patient: 'Patient',
  UserRole.labStaff: 'LabStaff',
  UserRole.admin: 'Admin',
};

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };
