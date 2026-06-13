// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabProfileImpl _$$LabProfileImplFromJson(Map<String, dynamic> json) =>
    _$LabProfileImpl(
      id: json['id'] as String,
      labName: json['lab_name'] as String,
      onboardingStatus:
          $enumDecode(_$LabOnboardingStatusEnumMap, json['onboarding_status']),
    );

Map<String, dynamic> _$$LabProfileImplToJson(_$LabProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lab_name': instance.labName,
      'onboarding_status':
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
      fullName: json['full_name'] as String?,
    );

Map<String, dynamic> _$$PatientProfileImplToJson(
        _$PatientProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
    };

_$AuthUserImpl _$$AuthUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      labProfile: json['lab_profile'] == null
          ? null
          : LabProfile.fromJson(json['lab_profile'] as Map<String, dynamic>),
      patientProfile: json['patient_profile'] == null
          ? null
          : PatientProfile.fromJson(
              json['patient_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthUserImplToJson(_$AuthUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'lab_profile': instance.labProfile,
      'patient_profile': instance.patientProfile,
    };

const _$UserRoleEnumMap = {
  UserRole.patient: 'Patient',
  UserRole.labStaff: 'LabStaff',
  UserRole.admin: 'Admin',
};

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
    };
