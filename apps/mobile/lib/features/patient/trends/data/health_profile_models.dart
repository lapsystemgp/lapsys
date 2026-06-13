import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_profile_models.freezed.dart';
part 'health_profile_models.g.dart';

@freezed
class HealthPoint with _$HealthPoint {
  const factory HealthPoint({
    required String testDate,
    required double value,
    required bool comparable,
    String? comparabilityNote,
    required String bookingId,
    required String labName,
    required String labTestName,
    double? refLow,
    double? refHigh,
    bool? abnormal,
  }) = _HealthPoint;

  factory HealthPoint.fromJson(Map<String, dynamic> json) =>
      _$HealthPointFromJson(json);
}

@freezed
class HealthTrend with _$HealthTrend {
  const factory HealthTrend({
    required String direction,
    required String narrative,
    String? qualitativeNote,
  }) = _HealthTrend;

  factory HealthTrend.fromJson(Map<String, dynamic> json) =>
      _$HealthTrendFromJson(json);
}

@freezed
class HealthSeries with _$HealthSeries {
  const factory HealthSeries({
    required String canonicalCode,
    required String displayName,
    required String chartUnit,
    String? category,
    String? labTestName,
    required HealthTrend trend,
    required List<HealthPoint> points,
  }) = _HealthSeries;

  factory HealthSeries.fromJson(Map<String, dynamic> json) =>
      _$HealthSeriesFromJson(json);
}

@freezed
class LabTestGroup with _$LabTestGroup {
  const factory LabTestGroup({
    required String labTestName,
    required List<HealthSeries> series,
  }) = _LabTestGroup;

  factory LabTestGroup.fromJson(Map<String, dynamic> json) =>
      _$LabTestGroupFromJson(json);
}

@freezed
class PdfOnlyBooking with _$PdfOnlyBooking {
  const factory PdfOnlyBooking({
    required String bookingId,
    required String scheduledAt,
    required String labName,
    required String testName,
  }) = _PdfOnlyBooking;

  factory PdfOnlyBooking.fromJson(Map<String, dynamic> json) =>
      _$PdfOnlyBookingFromJson(json);
}

@freezed
class HealthProfileResponse with _$HealthProfileResponse {
  const factory HealthProfileResponse({
    required String range,
    required String groupBy,
    required List<HealthSeries> series,
    required List<LabTestGroup> labTestGroups,
    required List<PdfOnlyBooking> pdfOnlyBookings,
    required bool hasStructuredData,
    required String disclaimer,
  }) = _HealthProfileResponse;

  factory HealthProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileResponseFromJson(json);
}
