// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthPointImpl _$$HealthPointImplFromJson(Map<String, dynamic> json) =>
    _$HealthPointImpl(
      testDate: json['testDate'] as String,
      value: (json['value'] as num).toDouble(),
      comparable: json['comparable'] as bool,
      comparabilityNote: json['comparabilityNote'] as String?,
      bookingId: json['bookingId'] as String,
      labName: json['labName'] as String,
      labTestName: json['labTestName'] as String,
      refLow: (json['refLow'] as num?)?.toDouble(),
      refHigh: (json['refHigh'] as num?)?.toDouble(),
      abnormal: json['abnormal'] as bool?,
    );

Map<String, dynamic> _$$HealthPointImplToJson(_$HealthPointImpl instance) =>
    <String, dynamic>{
      'testDate': instance.testDate,
      'value': instance.value,
      'comparable': instance.comparable,
      'comparabilityNote': instance.comparabilityNote,
      'bookingId': instance.bookingId,
      'labName': instance.labName,
      'labTestName': instance.labTestName,
      'refLow': instance.refLow,
      'refHigh': instance.refHigh,
      'abnormal': instance.abnormal,
    };

_$HealthTrendImpl _$$HealthTrendImplFromJson(Map<String, dynamic> json) =>
    _$HealthTrendImpl(
      direction: json['direction'] as String,
      narrative: json['narrative'] as String,
      qualitativeNote: json['qualitativeNote'] as String?,
    );

Map<String, dynamic> _$$HealthTrendImplToJson(_$HealthTrendImpl instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'narrative': instance.narrative,
      'qualitativeNote': instance.qualitativeNote,
    };

_$HealthSeriesImpl _$$HealthSeriesImplFromJson(Map<String, dynamic> json) =>
    _$HealthSeriesImpl(
      canonicalCode: json['canonicalCode'] as String,
      displayName: json['displayName'] as String,
      chartUnit: json['chartUnit'] as String,
      category: json['category'] as String?,
      labTestName: json['labTestName'] as String?,
      trend: HealthTrend.fromJson(json['trend'] as Map<String, dynamic>),
      points: (json['points'] as List<dynamic>)
          .map((e) => HealthPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HealthSeriesImplToJson(_$HealthSeriesImpl instance) =>
    <String, dynamic>{
      'canonicalCode': instance.canonicalCode,
      'displayName': instance.displayName,
      'chartUnit': instance.chartUnit,
      'category': instance.category,
      'labTestName': instance.labTestName,
      'trend': instance.trend,
      'points': instance.points,
    };

_$LabTestGroupImpl _$$LabTestGroupImplFromJson(Map<String, dynamic> json) =>
    _$LabTestGroupImpl(
      labTestName: json['labTestName'] as String,
      series: (json['series'] as List<dynamic>)
          .map((e) => HealthSeries.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LabTestGroupImplToJson(_$LabTestGroupImpl instance) =>
    <String, dynamic>{
      'labTestName': instance.labTestName,
      'series': instance.series,
    };

_$PdfOnlyBookingImpl _$$PdfOnlyBookingImplFromJson(Map<String, dynamic> json) =>
    _$PdfOnlyBookingImpl(
      bookingId: json['bookingId'] as String,
      scheduledAt: json['scheduledAt'] as String,
      labName: json['labName'] as String,
      testName: json['testName'] as String,
    );

Map<String, dynamic> _$$PdfOnlyBookingImplToJson(
        _$PdfOnlyBookingImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'scheduledAt': instance.scheduledAt,
      'labName': instance.labName,
      'testName': instance.testName,
    };

_$HealthProfileResponseImpl _$$HealthProfileResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthProfileResponseImpl(
      range: json['range'] as String,
      groupBy: json['groupBy'] as String,
      series: (json['series'] as List<dynamic>)
          .map((e) => HealthSeries.fromJson(e as Map<String, dynamic>))
          .toList(),
      labTestGroups: (json['labTestGroups'] as List<dynamic>)
          .map((e) => LabTestGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      pdfOnlyBookings: (json['pdfOnlyBookings'] as List<dynamic>)
          .map((e) => PdfOnlyBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasStructuredData: json['hasStructuredData'] as bool,
      disclaimer: json['disclaimer'] as String,
    );

Map<String, dynamic> _$$HealthProfileResponseImplToJson(
        _$HealthProfileResponseImpl instance) =>
    <String, dynamic>{
      'range': instance.range,
      'groupBy': instance.groupBy,
      'series': instance.series,
      'labTestGroups': instance.labTestGroups,
      'pdfOnlyBookings': instance.pdfOnlyBookings,
      'hasStructuredData': instance.hasStructuredData,
      'disclaimer': instance.disclaimer,
    };
