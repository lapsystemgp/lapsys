import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// Maps to the `Role` enum in the backend Prisma schema.
enum UserRole {
  @JsonValue('Patient')
  patient,
  @JsonValue('LabStaff')
  labStaff,
  @JsonValue('Admin')
  admin,
}

// Maps to `LabOnboardingStatus` in Prisma.
enum LabOnboardingStatus {
  @JsonValue('PendingReview')
  pendingReview,
  @JsonValue('Active')
  active,
  @JsonValue('Rejected')
  rejected,
  @JsonValue('Suspended')
  suspended,
}

@freezed
class LabProfile with _$LabProfile {
  const factory LabProfile({
    required String id,
    required String labName,
    required LabOnboardingStatus onboardingStatus,
  }) = _LabProfile;

  factory LabProfile.fromJson(Map<String, dynamic> json) =>
      _$LabProfileFromJson(json);
}

@freezed
class PatientProfile with _$PatientProfile {
  const factory PatientProfile({
    required String id,
    String? fullName,
  }) = _PatientProfile;

  factory PatientProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientProfileFromJson(json);
}

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    required UserRole role,
    LabProfile? labProfile,
    PatientProfile? patientProfile,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    required AuthUser user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
