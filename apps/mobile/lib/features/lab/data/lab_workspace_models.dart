import 'package:freezed_annotation/freezed_annotation.dart';
import '../../patient/booking/data/booking_models.dart';

part 'lab_workspace_models.freezed.dart';
part 'lab_workspace_models.g.dart';

// ─── Lab info ─────────────────────────────────────────────────────────────────

@freezed
class LabInfo with _$LabInfo {
  const factory LabInfo({
    required String id,
    required String name,
    required String address,
    required bool homeCollection,
    required bool homeTestKit,
  }) = _LabInfo;

  factory LabInfo.fromJson(Map<String, dynamic> json) =>
      _$LabInfoFromJson(json);
}

// ─── Booking items (lab view includes patient field) ─────────────────────────

@freezed
class LabBookingPatient with _$LabBookingPatient {
  const factory LabBookingPatient({
    required String id,
    String? fullName,
    String? phone,
  }) = _LabBookingPatient;

  factory LabBookingPatient.fromJson(Map<String, dynamic> json) =>
      _$LabBookingPatientFromJson(json);
}

@freezed
class LabBookingLab with _$LabBookingLab {
  const factory LabBookingLab({
    required String id,
    required String name,
    required String address,
    required bool homeCollection,
    required bool homeTestKit,
  }) = _LabBookingLab;

  factory LabBookingLab.fromJson(Map<String, dynamic> json) =>
      _$LabBookingLabFromJson(json);
}

@freezed
class LabBookingTest with _$LabBookingTest {
  const factory LabBookingTest({
    required String id,
    required String name,
    required int priceEgp,
  }) = _LabBookingTest;

  factory LabBookingTest.fromJson(Map<String, dynamic> json) =>
      _$LabBookingTestFromJson(json);
}

@freezed
class LabBookingSlot with _$LabBookingSlot {
  const factory LabBookingSlot({
    required String id,
    required String startsAt,
    required String endsAt,
  }) = _LabBookingSlot;

  factory LabBookingSlot.fromJson(Map<String, dynamic> json) =>
      _$LabBookingSlotFromJson(json);
}

@freezed
class LabBookingTimelineEntry with _$LabBookingTimelineEntry {
  const factory LabBookingTimelineEntry({
    required String id,
    required BookingStatus status,
    String? note,
    String? actorUserId,
    required String createdAt,
  }) = _LabBookingTimelineEntry;

  factory LabBookingTimelineEntry.fromJson(Map<String, dynamic> json) =>
      _$LabBookingTimelineEntryFromJson(json);
}

@freezed
class LabBookingItem with _$LabBookingItem {
  const factory LabBookingItem({
    required String id,
    required BookingStatus status,
    required BookingType bookingType,
    required String scheduledAt,
    String? homeAddress,
    required int totalPriceEgp,
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
    required String createdAt,
    required LabBookingPatient patient,
    required LabBookingLab lab,
    required LabBookingTest test,
    LabBookingSlot? slot,
    required List<LabBookingTimelineEntry> timeline,
  }) = _LabBookingItem;

  factory LabBookingItem.fromJson(Map<String, dynamic> json) =>
      _$LabBookingItemFromJson(json);
}

// ─── Tests & schedule ────────────────────────────────────────────────────────

@freezed
class LabTest with _$LabTest {
  const factory LabTest({
    required String id,
    required String name,
    required String category,
    required int priceEgp,
    @Default('') String description,
    @Default('') String preparation,
    @Default('') String turnaroundTime,
    int? parametersCount,
    required bool isActive,
  }) = _LabTest;

  factory LabTest.fromJson(Map<String, dynamic> json) =>
      _$LabTestFromJson(json);
}

@freezed
class LabScheduleSlot with _$LabScheduleSlot {
  const factory LabScheduleSlot({
    required String id,
    required String startsAt,
    required String endsAt,
    required int capacity,
    required bool isActive,
  }) = _LabScheduleSlot;

  factory LabScheduleSlot.fromJson(Map<String, dynamic> json) =>
      _$LabScheduleSlotFromJson(json);
}

// ─── Analytics ───────────────────────────────────────────────────────────────

@freezed
class LabTopTest with _$LabTopTest {
  const factory LabTopTest({
    required String testId,
    required String testName,
    required int count,
  }) = _LabTopTest;

  factory LabTopTest.fromJson(Map<String, dynamic> json) =>
      _$LabTopTestFromJson(json);
}

@freezed
class LabAnalytics with _$LabAnalytics {
  const factory LabAnalytics({
    required int totalBookings,
    required int completedBookings,
    required int pendingResults,
    required int revenueEstimateEgp,
    required double capacityUsagePercent,
    required List<LabTopTest> topTests,
  }) = _LabAnalytics;

  factory LabAnalytics.fromJson(Map<String, dynamic> json) =>
      _$LabAnalyticsFromJson(json);
}

// ─── Workspace response ──────────────────────────────────────────────────────

@freezed
class LabWorkspaceResponse with _$LabWorkspaceResponse {
  const factory LabWorkspaceResponse({
    required LabInfo lab,
    required List<LabBookingItem> bookings,
    required List<LabTest> tests,
    required List<LabScheduleSlot> schedule,
    required LabAnalytics analytics,
  }) = _LabWorkspaceResponse;

  factory LabWorkspaceResponse.fromJson(Map<String, dynamic> json) =>
      _$LabWorkspaceResponseFromJson(json);
}
