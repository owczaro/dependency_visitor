import 'package:dependency_visitor/dependency_visitor.dart';
import 'package:test/test.dart';

/// Tests [DependencyFile]

void main() {
  final dependencyFile = DependencyFile(
    packageName: 'package-name',
    content: 'Some content',
    absolutePath: 'Absolute path',
  );

  group('[Models] DependencyFile', () {
    test('Test type', () {
      expect(dependencyFile, isA<DependencyFile>());
    });

    test('Test package name field', () {
      expect(dependencyFile.packageName, equals('package-name'));
    });

    test('Test content field', () {
      expect(dependencyFile.content, equals('Some content'));
    });
  });
}
