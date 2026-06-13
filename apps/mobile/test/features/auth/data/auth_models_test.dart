import 'package:flutter_test/flutter_test.dart';
import 'package:testly/features/auth/data/auth_models.dart';

void main() {
  group('AuthModels — JSON serialisation', () {
    group('AuthUser', () {
      const patientJson = {
        'id': 'u-1',
        'email': 'patient@testly.com',
        'role': 'Patient',
        'lab_profile': null,
        'patient_profile': {'id': 'pp-1', 'full_name': 'Mazen Amir'},
      };

      test('deserialises a patient user from the /auth/me response shape', () {
        final user = AuthUser.fromJson(patientJson);
        expect(user.id, 'u-1');
        expect(user.email, 'patient@testly.com');
        expect(user.role, UserRole.patient);
        expect(user.labProfile, isNull);
        expect(user.patientProfile?.fullName, 'Mazen Amir');
      });

      test('serialises back to the original map', () {
        final user = AuthUser.fromJson(patientJson);
        final json = user.toJson();
        expect(json['id'], 'u-1');
        expect(json['email'], 'patient@testly.com');
        expect(json['role'], 'Patient');
      });

      test('deserialises a LabStaff user with an Active lab profile', () {
        final json = {
          'id': 'u-2',
          'email': 'alborglaboratories@testly.com',
          'role': 'LabStaff',
          'lab_profile': {
            'id': 'lp-1',
            'lab_name': 'Alborg Laboratories',
            'onboarding_status': 'Active',
          },
          'patient_profile': null,
        };
        final user = AuthUser.fromJson(json);
        expect(user.role, UserRole.labStaff);
        expect(user.labProfile?.onboardingStatus, LabOnboardingStatus.active);
        expect(user.labProfile?.labName, 'Alborg Laboratories');
      });

      test('maps PendingReview onboarding status correctly', () {
        final json = {
          'id': 'u-3',
          'email': 'pendinglab@testly.com',
          'role': 'LabStaff',
          'lab_profile': {
            'id': 'lp-2',
            'lab_name': 'Pending Lab',
            'onboarding_status': 'PendingReview',
          },
          'patient_profile': null,
        };
        final user = AuthUser.fromJson(json);
        expect(user.labProfile?.onboardingStatus, LabOnboardingStatus.pendingReview);
      });

      test('maps Admin role correctly', () {
        final json = {
          'id': 'u-admin',
          'email': 'admin@testly.com',
          'role': 'Admin',
          'lab_profile': null,
          'patient_profile': null,
        };
        final user = AuthUser.fromJson(json);
        expect(user.role, UserRole.admin);
      });
    });

    group('LoginResponse', () {
      test('maps access_token, refresh_token, and nested user', () {
        final json = {
          'access_token': 'tok-access',
          'refresh_token': 'tok-refresh',
          'user': {
            'id': 'u-1',
            'email': 'patient@testly.com',
            'role': 'Patient',
            'lab_profile': null,
            'patient_profile': null,
          },
        };
        final response = LoginResponse.fromJson(json);
        expect(response.accessToken, 'tok-access');
        expect(response.refreshToken, 'tok-refresh');
        expect(response.user.email, 'patient@testly.com');
      });
    });

    group('LabProfile', () {
      test('deserialises all onboarding statuses', () {
        for (final entry in {
          'PendingReview': LabOnboardingStatus.pendingReview,
          'Active': LabOnboardingStatus.active,
          'Rejected': LabOnboardingStatus.rejected,
          'Suspended': LabOnboardingStatus.suspended,
        }.entries) {
          final lp = LabProfile.fromJson({
            'id': 'lp-x',
            'lab_name': 'Lab',
            'onboarding_status': entry.key,
          });
          expect(lp.onboardingStatus, entry.value,
              reason: '${entry.key} should map to ${entry.value}');
        }
      });
    });
  });
}
