import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:dependency_visitor/dependency_visitor.dart';
import 'package:test/test.dart';

/// Tests [DependencyVisitor]

void main() {
  group('DependencyVisitor', () {
    test('Basic settings', () async {
      await DependencyVisitor(filePaths: ['LICENSE'])
          .run()
          .forEach((dependencyFile) {
        expect(dependencyFile.packageName, hasLength(greaterThan(0)));
        expect(dependencyFile.content, hasLength(greaterThan(0)));
        expect(dependencyFile.absolutePath, hasLength(greaterThan(0)));
      });
    });

    test('Does not include root - deprecated', () async {
      final thisPackageLicenseAbsolutePath =
          p.normalize('${Directory.current.absolute.path}/LICENSE');

      await DependencyVisitor(filePaths: ['LICENSE'], includeRoot: false)
          .run()
          .forEach((dependencyFile) {
        expect(dependencyFile.packageName, hasLength(greaterThan(0)));
        expect(dependencyFile.content, hasLength(greaterThan(0)));
        expect(dependencyFile.absolutePath, hasLength(greaterThan(0)));
        expect(
            dependencyFile.absolutePath, isNot(thisPackageLicenseAbsolutePath));
      });
    });

    test('Does not include root', () async {
      final thisPackageLicenseAbsolutePath =
          p.normalize('${Directory.current.absolute.path}/LICENSE');

      await DependencyVisitor(filePaths: [
        'LICENSE'
      ], dependencyTypes: [
        DependencyType.development,
        DependencyType.transitive,
        DependencyType.direct,
      ]).run().forEach((dependencyFile) {
        expect(dependencyFile.packageName, hasLength(greaterThan(0)));
        expect(dependencyFile.content, hasLength(greaterThan(0)));
        expect(dependencyFile.absolutePath, hasLength(greaterThan(0)));
        expect(
            dependencyFile.absolutePath, isNot(thisPackageLicenseAbsolutePath));
      });
    });

    test('File that does not exist', () async {
      await DependencyVisitor(filePaths: ['asdksdv-does-not-exts.oq.test'])
          .run()
          .forEach((dependencyFile) {
        expect(false, isTrue);
      });
    });
  });
  group('DependencyVisitor - Dependency Type', () {
    var root = 0;
    var direct = 0;
    var development = 0;
    var transitive = 0;

    setUpAll(() async {
      await DependencyVisitor(
        filePaths: ['LICENSE'],
        dependencyTypes: [DependencyType.root],
      ).run().forEach((dependencyFile) => root++);

      await DependencyVisitor(
        filePaths: ['LICENSE'],
        dependencyTypes: [DependencyType.development],
      ).run().forEach((dependencyFile) => development++);

      await DependencyVisitor(
        filePaths: ['LICENSE'],
        dependencyTypes: [DependencyType.direct],
      ).run().forEach((dependencyFile) => direct++);

      await DependencyVisitor(
        filePaths: ['LICENSE'],
        dependencyTypes: [DependencyType.transitive],
      ).run().forEach((dependencyFile) => transitive++);
    });

    test('root = 1', () async {
      expect(root, equals(1));
    });

    test('development > 0', () async {
      expect(development, greaterThan(0));
    });

    test('development less than direct', () async {
      expect(development, lessThan(direct));
    });

    test('direct less than transitive', () async {
      expect(direct, lessThan(transitive));
    });
  });
}
