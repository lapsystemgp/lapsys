import 'package:flutter_test/flutter_test.dart';
import 'package:testly/features/patient/labs/data/lab_models.dart';
import 'package:testly/shared/models/pagination.dart';

const _labCardJson = {
  'id': 'lab-1',
  'name': 'Alborg Laboratories',
  'address': '12 Tahrir Square, Cairo',
  'city': 'Cairo',
  'phone': '+20123456789',
  'contactEmail': 'info@alborg.com',
  'accreditation': 'CAP',
  'turnaroundTime': '24h',
  'homeCollection': true,
  'homeTestKit': false,
  'rating': 4.7,
  'reviews': 213,
  'distanceKm': 2.3,
  'testsAvailable': 85,
  'startingFromEgp': 120,
  'priceForQueryEgp': 350,
  'imageEmoji': '🔬',
};

void main() {
  group('PublicLabCard', () {
    test('fromJson parses all fields', () {
      final card = PublicLabCard.fromJson(_labCardJson);

      expect(card.id, 'lab-1');
      expect(card.name, 'Alborg Laboratories');
      expect(card.homeCollection, true);
      expect(card.homeTestKit, false);
      expect(card.rating, 4.7);
      expect(card.reviews, 213);
      expect(card.distanceKm, 2.3);
      expect(card.startingFromEgp, 120);
      expect(card.priceForQueryEgp, 350);
      expect(card.imageEmoji, '🔬');
      expect(card.accreditation, 'CAP');
    });

    test('fromJson handles all-null optional fields', () {
      final card = PublicLabCard.fromJson({
        'id': 'lab-2',
        'name': 'Mini Lab',
        'address': 'Alex',
        'city': null,
        'phone': null,
        'contactEmail': null,
        'accreditation': null,
        'turnaroundTime': null,
        'homeCollection': false,
        'homeTestKit': false,
        'rating': null,
        'reviews': 0,
        'distanceKm': null,
        'testsAvailable': 3,
        'startingFromEgp': null,
        'priceForQueryEgp': null,
        'imageEmoji': null,
      });

      expect(card.rating, isNull);
      expect(card.distanceKm, isNull);
      expect(card.imageEmoji, isNull);
    });
  });

  group('PublicLabListResponse', () {
    test('fromJson parses items and pagination', () {
      final response = PublicLabListResponse.fromJson({
        'items': [_labCardJson],
        'pagination': {'page': 1, 'pageSize': 10, 'totalCount': 1},
      });

      expect(response.items, hasLength(1));
      expect(response.items.first.name, 'Alborg Laboratories');
      expect(response.pagination, equals(const Pagination(page: 1, pageSize: 10, totalCount: 1)));
    });
  });

  group('PublicLabTest', () {
    test('fromJson parses all fields including optionals', () {
      final test_ = PublicLabTest.fromJson({
        'id': 'lt-1',
        'name': 'CBC',
        'category': 'Haematology',
        'priceEgp': 300,
        'description': 'Complete Blood Count',
        'preparation': 'Fast for 8h',
        'turnaroundTime': '24h',
        'parametersCount': 18,
      });

      expect(test_.name, 'CBC');
      expect(test_.priceEgp, 300);
      expect(test_.preparation, 'Fast for 8h');
      expect(test_.parametersCount, 18);
    });
  });

  group('PublicLabDetailResponse', () {
    test('fromJson parses lab, tests, pagination, and reviews', () {
      final detail = PublicLabDetailResponse.fromJson({
        'lab': _labCardJson,
        'tests': [
          {
            'id': 'lt-1',
            'name': 'CBC',
            'category': 'Haematology',
            'priceEgp': 300,
            'description': null,
            'preparation': null,
            'turnaroundTime': null,
            'parametersCount': null,
          }
        ],
        'pagination': {'page': 1, 'pageSize': 20, 'totalCount': 1},
        'reviewItems': [
          {
            'id': 'r-1',
            'rating': 5,
            'comment': 'Excellent service',
            'createdAt': '2026-05-10T10:00:00Z',
            'patientName': 'Mazen Amir',
          }
        ],
      });

      expect(detail.lab.name, 'Alborg Laboratories');
      expect(detail.tests, hasLength(1));
      expect(detail.tests.first.name, 'CBC');
      expect(detail.reviewItems.first.rating, 5);
      expect(detail.reviewItems.first.patientName, 'Mazen Amir');
    });
  });

  group('LabsFilter', () {
    test('default instances are equal (used as FutureProvider.family key)', () {
      const a = LabsFilter();
      const b = LabsFilter();
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = LabsFilter(q: 'blood');
      const b = LabsFilter(q: 'urine');
      expect(a, isNot(equals(b)));
    });

    test('homeCollectionOnly defaults to false, page defaults to 1', () {
      const f = LabsFilter();
      expect(f.homeCollectionOnly, false);
      expect(f.page, 1);
    });
  });
}
