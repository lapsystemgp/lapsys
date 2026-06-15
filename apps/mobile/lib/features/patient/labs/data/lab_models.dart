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

// ─── Tests search (mirrors the frontend "Tests" tab) ─────────────────────────

/// One aggregated test row, grouped by name + category across all labs.
/// Returned by `GET /public/tests`.
@freezed
class PublicTestCard with _$PublicTestCard {
  const factory PublicTestCard({
    required String name,
    required String category,
    int? minPriceEgp,
    required int labCount,
  }) = _PublicTestCard;

  factory PublicTestCard.fromJson(Map<String, dynamic> json) =>
      _$PublicTestCardFromJson(json);
}

@freezed
class PublicTestListResponse with _$PublicTestListResponse {
  const factory PublicTestListResponse({
    required List<PublicTestCard> items,
    required Pagination pagination,
  }) = _PublicTestListResponse;

  factory PublicTestListResponse.fromJson(Map<String, dynamic> json) =>
      _$PublicTestListResponseFromJson(json);
}

// ─── Test offers (mirrors the frontend test-detail "nearest labs" view) ──────

/// One lab that offers a given test, with the coordinates needed to compute
/// distance client-side. Returned inside `GET /public/tests/by-name`.
@freezed
class TestOfferLab with _$TestOfferLab {
  const factory TestOfferLab({
    required String labTestId,
    required String labId,
    required String labName,
    required String address,
    required int priceEgp,
    double? rating,
    required int reviews,
    required bool homeCollection,
    required bool homeTestKit,
    String? accreditation,
    String? turnaroundTime,
    double? latitude,
    double? longitude,
  }) = _TestOfferLab;

  factory TestOfferLab.fromJson(Map<String, dynamic> json) =>
      _$TestOfferLabFromJson(json);
}

@freezed
class TestOffersResponse with _$TestOffersResponse {
  const factory TestOffersResponse({
    required String name,
    required String category,
    String? description,
    String? preparation,
    String? turnaroundTime,
    int? parametersCount,
    required List<TestOfferLab> labs,
  }) = _TestOffersResponse;

  factory TestOffersResponse.fromJson(Map<String, dynamic> json) =>
      _$TestOffersResponseFromJson(json);
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
    double? userLat,
    double? userLng,
  }) = _LabsFilter;
}
