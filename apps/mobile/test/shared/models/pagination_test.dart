import 'package:flutter_test/flutter_test.dart';
import 'package:testly/shared/models/pagination.dart';

void main() {
  group('Pagination', () {
    test('fromJson parses all fields', () {
      final p = Pagination.fromJson({
        'page': 2,
        'pageSize': 10,
        'totalCount': 47,
      });

      expect(p.page, 2);
      expect(p.pageSize, 10);
      expect(p.totalCount, 47);
    });

    test('equality holds for identical values', () {
      const a = Pagination(page: 1, pageSize: 10, totalCount: 5);
      const b = Pagination(page: 1, pageSize: 10, totalCount: 5);

      expect(a, equals(b));
      expect(a == b, true);
    });
  });
}
