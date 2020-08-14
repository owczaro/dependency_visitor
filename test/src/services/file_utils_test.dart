import 'package:dependency_visitor/src/services/file_utils.dart';
import 'package:test/test.dart';

/// Tests [readYamlFileFromRoot()] and [readFileAsString()]

void main() {
  group('[Services] readYamlFileFromRoot()', () {
    test('Test length', () {
      expect(readYamlFileFromRoot(), hasLength(greaterThan(0)));
    });
    test('Test exception', () {
      expect(readYamlFileFromRoot(fileName: 'random-name'), isNull);
    });
  });

  group('[Services] readFileAsString()', () {
    test('Test length', () async {
      expect(await readFileAsString('LICENSE'), hasLength(greaterThan(0)));
    });
    test('Test exception', () async {
      expect(await readFileAsString('random-name'), isNull);
    });
  });
}
