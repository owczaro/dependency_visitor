import 'package:dependency_visitor/src/services/pub_cache_service.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

/// Tests [PubCacheService]

void main() {
  final path = PubCacheService().defaultPath;
  group('[Services] PubCacheService', () {
    test('Test type', () {
      expect(path, isA<String>());
    });

    test('Test length', () {
      expect(path, hasLength(greaterThan(0)));
    });

    test('Test is absolute path', () {
      expect(p.isAbsolute(path), equals(true));
    });
  });
}
