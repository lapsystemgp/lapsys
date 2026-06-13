import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_models.freezed.dart';
part 'booking_models.g.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum BookingType {
  @JsonValue('LabVisit') labVisit,
  @JsonValue('HomeCollection') homeCollection,
  @JsonValue('HomeTestKit') homeTestKit,
}

enum BookingStatus {
  @JsonValue('Pending') pending,
  @JsonValue('Confirmed') confirmed,
  @JsonValue('Rejected') rejected,
  @JsonValue('Cancelled') cancelled,
  @JsonValue('Completed') completed,
}

enum PaymentMethod {
  @JsonValue('Online') online,
  @JsonValue('CashHomeCollection') cashHomeCollection,
  @JsonValue('CashLabVisit') cashLabVisit,
  @JsonValue('CashOnDelivery') cashOnDelivery,
}

enum PaymentStatus {
  @JsonValue('Pending') pending,
  @JsonValue('Paid') paid,
  @JsonValue('Failed') failed,
  @JsonValue('Refunded') refunded,
}

enum KitStatus {
  @JsonValue('AwaitingShipment') awaitingShipment,
  @JsonValue('Shipped') shipped,
  @JsonValue('Delivered') delivered,
  @JsonValue('SampleReceived') sampleReceived,
}

// ─── Slot ────────────────────────────────────────────────────────────────────

@freezed
class BookingSlot with _$BookingSlot {
  const factory BookingSlot({
    required String id,
    required String startsAt,
    required String endsAt,
  }) = _BookingSlot;

  factory BookingSlot.fromJson(Map<String, dynamic> json) =>
      _$BookingSlotFromJson(json);
}

@freezed
class BookingAvailabilityResponse with _$BookingAvailabilityResponse {
  const factory BookingAvailabilityResponse({
    required List<BookingSlot> items,
  }) = _BookingAvailabilityResponse;

  factory BookingAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingAvailabilityResponseFromJson(json);
}

// ─── Booking item (from /bookings/patient) ───────────────────────────────────

@freezed
class BookingItemLab with _$BookingItemLab {
  const factory BookingItemLab({
    required String id,
    required String name,
    required String address,
    required bool homeCollection,
    required bool homeTestKit,
  }) = _BookingItemLab;

  factory BookingItemLab.fromJson(Map<String, dynamic> json) =>
      _$BookingItemLabFromJson(json);
}

@freezed
class BookingItemTest with _$BookingItemTest {
  const factory BookingItemTest({
    required String id,
    required String name,
    required int priceEgp,
  }) = _BookingItemTest;

  factory BookingItemTest.fromJson(Map<String, dynamic> json) =>
      _$BookingItemTestFromJson(json);
}

@freezed
class BookingTimelineEntry with _$BookingTimelineEntry {
  const factory BookingTimelineEntry({
    required String id,
    required BookingStatus status,
    String? note,
    required String createdAt,
  }) = _BookingTimelineEntry;

  factory BookingTimelineEntry.fromJson(Map<String, dynamic> json) =>
      _$BookingTimelineEntryFromJson(json);
}

@freezed
class BookingItem with _$BookingItem {
  const factory BookingItem({
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
    String? createdAt,
    required BookingItemLab lab,
    required BookingItemTest test,
    required List<BookingTimelineEntry> timeline,
  }) = _BookingItem;

  factory BookingItem.fromJson(Map<String, dynamic> json) =>
      _$BookingItemFromJson(json);
}

@freezed
class BookingListResponse with _$BookingListResponse {
  const factory BookingListResponse({
    required List<BookingItem> items,
  }) = _BookingListResponse;

  factory BookingListResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingListResponseFromJson(json);
}

// ─── Booking flow state ──────────────────────────────────────────────────────

@freezed
class BookingFlowParams with _$BookingFlowParams {
  const factory BookingFlowParams({
    required String labId,
    required String testId,
    required String labName,
    required String testName,
    required int priceEgp,
    required bool supportsHomeCollection,
    required bool supportsHomeTestKit,
    String? preparation,
  }) = _BookingFlowParams;
}
