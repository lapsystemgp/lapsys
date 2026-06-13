import 'package:flutter_test/flutter_test.dart';
import 'package:testly/features/patient/trends/data/health_profile_models.dart';

const _point = {
  'testDate': '2026-01-15T00:00:00.000Z',
  'value': 5.2,
  'comparable': true,
  'comparabilityNote': null,
  'bookingId': 'b-1',
  'labName': 'MedLab',
  'labTestName': 'Glucose Tolerance',
  'refLow': 3.9,
  'refHigh': 6.1,
  'abnormal': false,
};

const _abnormalPoint = {
  'testDate': '2026-02-10T00:00:00.000Z',
  'value': 7.8,
  'comparable': true,
  'comparabilityNote': null,
  'bookingId': 'b-2',
  'labName': 'MedLab',
  'labTestName': 'Glucose Tolerance',
  'refLow': 3.9,
  'refHigh': 6.1,
  'abnormal': true,
};

const _trend = {
  'direction': 'increasing',
  'narrative': 'The latest value is higher than earlier in this period.',
  'qualitativeNote':
      'The most recent point is outside the reference limits.',
};

final _series = {
  'canonicalCode': 'GLU',
  'displayName': 'Glucose',
  'chartUnit': 'mmol/L',
  'category': 'Metabolic',
  'labTestName': null,
  'trend': _trend,
  'points': [_point, _abnormalPoint],
};

final _profileJson = {
  'range': '12m',
  'groupBy': 'analyte',
  'series': [_series],
  'labTestGroups': <Map<String, dynamic>>[],
  'pdfOnlyBookings': <Map<String, dynamic>>[],
  'hasStructuredData': true,
  'disclaimer': 'Not medical advice.',
};

final _labTestGroupJson = {
  'range': '6m',
  'groupBy': 'lab_test',
  'series': <Map<String, dynamic>>[],
  'labTestGroups': [
    {
      'labTestName': 'Glucose Tolerance',
      'series': [_series],
    }
  ],
  'pdfOnlyBookings': [
    {
      'bookingId': 'b-3',
      'scheduledAt': '2025-12-01T00:00:00.000Z',
      'labName': 'Clinic A',
      'testName': 'CBC',
    }
  ],
  'hasStructuredData': true,
  'disclaimer': 'Not medical advice.',
};

void main() {
  group('HealthPoint.fromJson', () {
    test('parses all fields correctly', () {
      final pt = HealthPoint.fromJson(_point as Map<String, dynamic>);

      expect(pt.testDate, '2026-01-15T00:00:00.000Z');
      expect(pt.value, 5.2);
      expect(pt.comparable, true);
      expect(pt.comparabilityNote, isNull);
      expect(pt.bookingId, 'b-1');
      expect(pt.labName, 'MedLab');
      expect(pt.labTestName, 'Glucose Tolerance');
      expect(pt.refLow, 3.9);
      expect(pt.refHigh, 6.1);
      expect(pt.abnormal, false);
    });

    test('parses abnormal flag as true', () {
      final pt = HealthPoint.fromJson(_abnormalPoint as Map<String, dynamic>);

      expect(pt.abnormal, true);
      expect(pt.value, 7.8);
    });

    test('handles null refLow and refHigh', () {
      final json = {
        ..._point as Map<String, dynamic>,
        'refLow': null,
        'refHigh': null,
      };
      final pt = HealthPoint.fromJson(json);

      expect(pt.refLow, isNull);
      expect(pt.refHigh, isNull);
    });
  });

  group('HealthTrend.fromJson', () {
    test('parses direction and narrative', () {
      final trend = HealthTrend.fromJson(_trend as Map<String, dynamic>);

      expect(trend.direction, 'increasing');
      expect(trend.narrative, isNotEmpty);
      expect(trend.qualitativeNote, isNotNull);
    });

    test('handles null qualitativeNote', () {
      final json = {
        'direction': 'stable',
        'narrative': 'Values are similar.',
        'qualitativeNote': null,
      };
      final trend = HealthTrend.fromJson(json);

      expect(trend.direction, 'stable');
      expect(trend.qualitativeNote, isNull);
    });

    test('handles insufficient_data direction', () {
      final json = {
        'direction': 'insufficient_data',
        'narrative': 'Not enough measurements.',
        'qualitativeNote': null,
      };
      final trend = HealthTrend.fromJson(json);

      expect(trend.direction, 'insufficient_data');
    });
  });

  group('HealthSeries.fromJson', () {
    test('parses series with points and trend', () {
      final series = HealthSeries.fromJson(_series as Map<String, dynamic>);

      expect(series.canonicalCode, 'GLU');
      expect(series.displayName, 'Glucose');
      expect(series.chartUnit, 'mmol/L');
      expect(series.category, 'Metabolic');
      expect(series.labTestName, isNull);
      expect(series.trend.direction, 'increasing');
      expect(series.points, hasLength(2));
    });

    test('parses series without category', () {
      final json = {
        ..._series as Map<String, dynamic>,
        'category': null,
      };
      final series = HealthSeries.fromJson(json);

      expect(series.category, isNull);
    });

    test('handles empty points list', () {
      final json = {
        ..._series as Map<String, dynamic>,
        'points': <Map<String, dynamic>>[],
      };
      final series = HealthSeries.fromJson(json);

      expect(series.points, isEmpty);
    });
  });

  group('HealthProfileResponse.fromJson', () {
    test('parses analyte-grouped response', () {
      final profile = HealthProfileResponse.fromJson(_profileJson);

      expect(profile.range, '12m');
      expect(profile.groupBy, 'analyte');
      expect(profile.series, hasLength(1));
      expect(profile.labTestGroups, isEmpty);
      expect(profile.pdfOnlyBookings, isEmpty);
      expect(profile.hasStructuredData, true);
      expect(profile.disclaimer, 'Not medical advice.');
    });

    test('first series has correct analyte data', () {
      final profile = HealthProfileResponse.fromJson(_profileJson);
      final series = profile.series.first;

      expect(series.displayName, 'Glucose');
      expect(series.chartUnit, 'mmol/L');
      expect(series.points, hasLength(2));
    });

    test('second point in series is abnormal', () {
      final profile = HealthProfileResponse.fromJson(_profileJson);
      final secondPoint = profile.series.first.points[1];

      expect(secondPoint.abnormal, true);
      expect(secondPoint.value, 7.8);
    });

    test('parses lab_test grouped response with labTestGroups', () {
      final profile = HealthProfileResponse.fromJson(_labTestGroupJson);

      expect(profile.groupBy, 'lab_test');
      expect(profile.series, isEmpty);
      expect(profile.labTestGroups, hasLength(1));
      expect(profile.labTestGroups.first.labTestName, 'Glucose Tolerance');
      expect(profile.labTestGroups.first.series, hasLength(1));
    });

    test('parses pdfOnlyBookings', () {
      final profile = HealthProfileResponse.fromJson(_labTestGroupJson);

      expect(profile.pdfOnlyBookings, hasLength(1));
      expect(profile.pdfOnlyBookings.first.bookingId, 'b-3');
      expect(profile.pdfOnlyBookings.first.testName, 'CBC');
    });

    test('hasStructuredData is false when no structured data', () {
      final json = {
        ..._profileJson,
        'series': <Map<String, dynamic>>[],
        'hasStructuredData': false,
      };
      final profile = HealthProfileResponse.fromJson(json);

      expect(profile.hasStructuredData, false);
      expect(profile.series, isEmpty);
    });
  });

  group('PdfOnlyBooking.fromJson', () {
    test('parses all fields', () {
      final booking = PdfOnlyBooking.fromJson({
        'bookingId': 'b-pdf',
        'scheduledAt': '2025-11-20T08:00:00.000Z',
        'labName': 'HealthPoint Lab',
        'testName': 'Lipid Panel',
      });

      expect(booking.bookingId, 'b-pdf');
      expect(booking.labName, 'HealthPoint Lab');
      expect(booking.testName, 'Lipid Panel');
    });
  });
}
