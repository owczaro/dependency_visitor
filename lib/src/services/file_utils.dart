import 'package:universal_io/io.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Load content of yaml file from root dir
YamlMap readYamlFileFromRoot({
  String fileName = 'pubspec.yaml',
}) {
  try {
    final fileContent = File(fileName)?.readAsStringSync();
    return loadYaml(fileContent);
  } on FileSystemException catch (_) {
    return null;
  }
}

///Reads file asynchronously.
Future<String> readFileAsString(String path) async {
  try {
    path = p.normalize(path);
    final file = File(path).absolute;

    if (await file.exists()) {
      return await file.readAsString();
    }
  } on FileSystemException catch (_) {
    return null;
  }
  return null;
}
