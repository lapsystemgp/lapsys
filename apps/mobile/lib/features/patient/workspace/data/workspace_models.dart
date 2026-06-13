import 'package:freezed_annotation/freezed_annotation.dart';
import '../../booking/data/booking_models.dart';

part 'workspace_models.freezed.dart';
part 'workspace_models.g.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum ResultStatus {
  @JsonValue('Pending') pending,
  @JsonValue('Uploaded') uploaded,
  @JsonValue('Delivered') delivered,
}

enum ReviewStatus {
  @JsonValue('Pending') pending,
  @JsonValue('Published') published,
  @JsonValue('Rejected') rejected,
}

enum LabHistorySharing {
  @JsonValue('SAME_LAB_ONLY') sameLabOnly,
  @JsonValue('FULL_HISTORY_AUTHORIZED') fullHistoryAuthorized,
}

// ─── Workspace booking (from /patient/workspace) ─────────────────────────────

@freezed
class WorkspaceBookingLab with _$WorkspaceBookingLab {
  const factory WorkspaceBookingLab({
    required String id,
    required String name,
    required String address,
  }) = _WorkspaceBookingLab;

  factory WorkspaceBookingLab.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceBookingLabFromJson(json);
}

@freezed
class WorkspaceBookingTest with _$WorkspaceBookingTest {
  const factory WorkspaceBookingTest({
    required String id,
    required String name,
    required int priceEgp,
  }) = _WorkspaceBookingTest;

  factory WorkspaceBookingTest.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceBookingTestFromJson(json);
}

@freezed
class WorkspaceTimelineEntry with _$WorkspaceTimelineEntry {
  const factory WorkspaceTimelineEntry({
    required String id,
    required String status,
    String? note,
    required String createdAt,
  }) = _WorkspaceTimelineEntry;

  factory WorkspaceTimelineEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceTimelineEntryFromJson(json);
}

@freezed
class WorkspaceBooking with _$WorkspaceBooking {
  const factory WorkspaceBooking({
    required String id,
    required BookingStatus status,
    required BookingType bookingType,
    required String scheduledAt,
    required int totalPriceEgp,
    String? homeAddress,
    required PaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
    String? paymentReference,
    String? paymentPaidAt,
    String? paymentFailedAt,
    String? paymentFailureReason,
    KitStatus? kitStatus,
    String? kitTrackingNumber,
    String? kitShippedAt,
    String? kitDeliveredAt,
    String? sampleReceivedAt,
    required WorkspaceBookingLab lab,
    required WorkspaceBookingTest test,
    required List<WorkspaceTimelineEntry> timeline,
  }) = _WorkspaceBooking;

  factory WorkspaceBooking.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceBookingFromJson(json);
}

// ─── Result ──────────────────────────────────────────────────────────────────

@freezed
class ResultFile with _$ResultFile {
  const factory ResultFile({
    required String id,
    required String fileName,
    required String fileUrl,
    required String mimeType,
    required int sizeBytes,
    required String uploadedAt,
  }) = _ResultFile;

  factory ResultFile.fromJson(Map<String, dynamic> json) =>
      _$ResultFileFromJson(json);
}

@freezed
class SummaryHighlightItem with _$SummaryHighlightItem {
  const factory SummaryHighlightItem({
    required String key,
    required String label,
    required String value,
    required String kind,
  }) = _SummaryHighlightItem;

  factory SummaryHighlightItem.fromJson(Map<String, dynamic> json) =>
      _$SummaryHighlightItemFromJson(json);
}

@freezed
class SummaryHighlights with _$SummaryHighlights {
  const factory SummaryHighlights({
    required List<SummaryHighlightItem> items,
  }) = _SummaryHighlights;

  factory SummaryHighlights.fromJson(Map<String, dynamic> json) =>
      _$SummaryHighlightsFromJson(json);
}

@freezed
class ResultSummary with _$ResultSummary {
  const factory ResultSummary({
    required String summary,
    required SummaryHighlights highlights,
  }) = _ResultSummary;

  factory ResultSummary.fromJson(Map<String, dynamic> json) =>
      _$ResultSummaryFromJson(json);
}

@freezed
class WorkspaceResultReview with _$WorkspaceResultReview {
  const factory WorkspaceResultReview({
    required String id,
    required int rating,
    String? comment,
    required ReviewStatus status,
    required String createdAt,
  }) = _WorkspaceResultReview;

  factory WorkspaceResultReview.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceResultReviewFromJson(json);
}

@freezed
class WorkspaceResult with _$WorkspaceResult {
  const factory WorkspaceResult({
    required String bookingId,
    required BookingStatus bookingStatus,
    required String scheduledAt,
    required String labName,
    required String testName,
    required ResultStatus resultStatus,
    required bool hasStructuredData,
    required int structuredObservationCount,
    ResultFile? file,
    ResultSummary? summary,
    WorkspaceResultReview? review,
    required bool canReview,
  }) = _WorkspaceResult;

  factory WorkspaceResult.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceResultFromJson(json);
}

// ─── Profile ─────────────────────────────────────────────────────────────────

@freezed
class WorkspaceProfile with _$WorkspaceProfile {
  const factory WorkspaceProfile({
    required String fullName,
    required String phone,
    required String address,
    required String email,
    required LabHistorySharing labHistorySharing,
  }) = _WorkspaceProfile;

  factory WorkspaceProfile.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceProfileFromJson(json);
}

// ─── Workspace response ──────────────────────────────────────────────────────

@freezed
class WorkspaceBookings with _$WorkspaceBookings {
  const factory WorkspaceBookings({
    required List<WorkspaceBooking> upcoming,
    required List<WorkspaceBooking> past,
  }) = _WorkspaceBookings;

  factory WorkspaceBookings.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceBookingsFromJson(json);
}

@freezed
class PatientWorkspaceResponse with _$PatientWorkspaceResponse {
  const factory PatientWorkspaceResponse({
    required WorkspaceProfile profile,
    required WorkspaceBookings bookings,
    required List<WorkspaceResult> results,
  }) = _PatientWorkspaceResponse;

  factory PatientWorkspaceResponse.fromJson(Map<String, dynamic> json) =>
      _$PatientWorkspaceResponseFromJson(json);
}
