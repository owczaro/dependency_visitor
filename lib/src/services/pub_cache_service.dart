import 'package:universal_io/io.dart';
import 'package:path/path.dart' as p;

/// Finds .pub-cache directory in system
class PubCacheService {
  /// Returns default system directory
  String get defaultPath => _defaultPath ??= _defaultSystemPath();
  String? _defaultPath;

  String _defaultSystemPath() {
    if (Platform.environment.containsKey('PUB_CACHE')) {
      return Platform.environment['PUB_CACHE'] as String;
    } else if (Platform.isWindows) {
      var appData = Platform.environment['APPDATA'] as String;
      var appDataCacheDir = p.join(appData, 'Pub', 'Cache');
      if (Directory(appDataCacheDir).existsSync()) {
        return appDataCacheDir;
      }
      var localAppData = Platform.environment['LOCALAPPDATA'] as String;
      return p.join(localAppData, 'Pub', 'Cache');
    } else {
      return '${Platform.environment['HOME']}/.pub-cache';
    }
  }
}
