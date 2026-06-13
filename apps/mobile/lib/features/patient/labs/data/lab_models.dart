import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/pagination.dart';

part 'lab_models.freezed.dart';
part 'lab_models.g.dart';

@freezed
class PublicLabCard with _$PublicLabCard {
  const factory PublicLabCard({
    required String id,
    required String name,
    required String address,
    String? city,
    String? phone,
    String? contactEmail,
    String? accreditation,
    String? turnaroundTime,
    required bool homeCollection,
    required bool homeTestKit,
    double? rating,
    required int reviews,
    double? distanceKm,
    required int testsAvailable,
    int? startingFromEgp,
    int? priceForQueryEgp,
    String? imageEmoji,
  }) = _PublicLabCard;

  factory PublicLabCard.fromJson(Map<String, dynamic> json) =>
      _$PublicLabCardFromJson(json);
}

@freezed
class PublicLabListResponse with _$PublicLabListResponse {
  const factory PublicLabListResponse({
    required List<PublicLabCard> items,
    required Pagination pagination,
  }) = _PublicLabListResponse;

  factory PublicLabListResponse.fromJson(Map<String, dynamic> json) =>
      _$PublicLabListResponseFromJson(json);
}

@freezed
class PublicReview with _$PublicReview {
  const factory PublicReview({
    required String id,
    required int rating,
    String? comment,
    required String createdAt,
    required String patientName,
  }) = _PublicReview;

  factory PublicReview.fromJson(Map<String, dynamic> json) =>
      _$PublicReviewFromJson(json);
}

@freezed
class PublicLabTest with _$PublicLabTest {
  const factory PublicLabTest({
    required String id,
    required String name,
    required String category,
    required int priceEgp,
    String? description,
    String? preparation,
    String? turnaroundTime,
    int? parametersCount,
  }) = _PublicLabTest;

  factory PublicLabTest.fromJson(Map<String, dynamic> json) =>
      _$PublicLabTestFromJson(json);
}

@freezed
class PublicLabDetailResponse with _$PublicLabDetailResponse {
  const factory PublicLabDetailResponse({
    required PublicLabCard lab,
    required List<PublicLabTest> tests,
    required Pagination pagination,
    required List<PublicReview> reviewItems,
  }) = _PublicLabDetailResponse;

  factory PublicLabDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PublicLabDetailResponseFromJson(json);
}

// ─── Labs filter (used as FutureProvider.family key) ─────────────────────────

@freezed
class LabsFilter with _$LabsFilter {
  const factory LabsFilter({
    String? q,
    String? city,
    String? sort,
    int? maxPriceEgp,
    @Default(false) bool homeCollectionOnly,
    @Default(1) int page,
  }) = _LabsFilter;
}
