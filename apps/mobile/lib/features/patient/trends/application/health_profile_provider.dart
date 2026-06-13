import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_profile_models.dart';
import '../../workspace/data/patient_repository.dart';

typedef HealthProfileParams = ({String range, String groupBy});

final healthProfileProvider = FutureProvider.autoDispose
    .family<HealthProfileResponse, HealthProfileParams>(
  (ref, params) async {
    return ref.read(patientRepositoryProvider).getHealthProfile(
          range: params.range,
          groupBy: params.groupBy,
        );
  },
);
