import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/repositories/models/trail.dart';

import 'trail_fixture.dart';

void main() {
  group('Trail.isPublic', () {
    test('with public trail: isPublic should return true', () {
      final trail = trailFixture(isPublic: true);
      expect(trail.isPublic, isTrue);
    });

    test('with private trail: isPublic should return false by default', () {
      final trail = trailFixture();
      expect(trail.isPublic, isFalse);
    });
  });

  group('Trail.fromJson', () {
    test('with isPublic field: parses is_public correctly', () {
      final trail = Trail.fromJson(trailJsonFixture(isPublic: true));
      expect(trail.isPublic, isTrue);
    });

    test('with missing isPublic field: defaults isPublic to false', () {
      final trail = Trail.fromJson(trailJsonFixture());
      expect(trail.isPublic, isFalse);
    });
  });
}
