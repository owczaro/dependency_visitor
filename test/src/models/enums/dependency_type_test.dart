import 'package:dependency_visitor/src/models/enums/dependency_type.dart';
import 'package:test/test.dart';

/// Tests [DependencyType]

Future main() async {
  group('[Models/Enums] DependencyType', () {
    test('Values count', () async {
      expect(DependencyType.values.length, equals(4));
    });

    test('DependencyType.root', () async {
      expect(DependencyType.root.toString(), equals('DependencyType.root'));
    });

    test('DependencyType.direct', () async {
      expect(DependencyType.direct.toString(), equals('DependencyType.direct'));
    });

    test('DependencyType.development', () async {
      expect(DependencyType.development.toString(),
          equals('DependencyType.development'));
    });

    test('DependencyType.transitive', () async {
      expect(DependencyType.transitive.toString(),
          equals('DependencyType.transitive'));
    });
  });
}
