import 'package:dependency_visitor/dependency_visitor.dart';
import 'package:test/test.dart';

/// Tests [DependencyVisitor]

void main() {
  group('PubCacheService', () {
    test('Test responses', () async {
      var stream = DependencyVisitor(filePath: 'LICENSE').run();
      stream.forEach((element) {
        expect(element.packageName, hasLength(greaterThan(0)));
        expect(element.content, hasLength(greaterThan(0)));
      });
    });
  });
}
