import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:meta/meta.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
// ignore: implementation_imports
import 'package:pubspec_lock/src/package_dependency/dependency_type/definition.dart';
import 'services/file_utils.dart';
import 'models/dependency_file.dart';
import 'services/pub_cache_service.dart';

/// Visits root package, transitive and immediate dependencies
/// in order to search given file.
///
///
/// Typical usage is as follows:
///
/// ```dart
///  DependencyVisitor(filePath: 'path to file or file name')
///    .run().listen((dependencyFile) {
///      // Do smth with dependencyFile.packageName and dependencyFile.content
///    }).onDone(() {
///      // Do smth on the end if you need to
///  });
/// ```
class DependencyVisitor {
  /// Path to file and its name.
  final String filePath;

  /// Whether search in root package or not.
  final bool includeRoot;

  /// Which dependencies should be consider:
  /// * direct
  /// * direct dev
  /// * transitive
  /// * all of above
  final List<DependencyType> dependencyTypes;

  final _pubCacheService = PubCacheService();

  final _pubspecLock =
      File('pubspec.lock').readAsStringSync().loadPubspecLockFromYaml();

  /// Creates an instance of [DependencyVisitor]
  DependencyVisitor({
    @required this.filePath,
    this.includeRoot = true,
    this.dependencyTypes = DependencyType.values,
  })  : assert(filePath != null || filePath.length > 0),
        assert(includeRoot != null),
        assert(dependencyTypes != null || dependencyTypes.length > 0);

  /// Search file and read its content.
  Stream<DependencyFile> run() async* {
    if (includeRoot) {
      yield* _searchAndReadInRoot();
    }

    yield* _searchAndReadDependencies();
  }

  Stream<DependencyFile> _searchAndReadInRoot() async* {
    var content = await readFileAsString(filePath);
    if (_isNotEmpty(content)) {
      yield DependencyFile(
        packageName: await _rootPackageName,
        content: content,
      );
    }
  }

  Stream<DependencyFile> _searchAndReadDependencies() async* {
    for (final package in _pubspecLock.packages) {
      if (!dependencyTypes.contains(package.type())) {
        continue;
      }

      var absolutePath;
      package.iswitch(
        sdk: (_) => null,
        hosted: (d) => absolutePath =
            '${_pubCacheService.defaultPath}/hosted/pub.dartlang.org/'
                '${d.package}-${d.version}',
        git: (d) {
          absolutePath = '${_pubCacheService.defaultPath}/git/'
              '${d.package}-${d.resolvedRef}';
          if (!Directory(absolutePath).absolute.existsSync()) {
            absolutePath = '${_pubCacheService.defaultPath}/git/cache/'
                '${d.package}-${d.resolvedRef}';
          }
        },
        path: (d) =>
            absolutePath = '${Directory.current.absolute.path}/${d.path}',
      );

      final _content =
          await readFileAsString(p.normalize('$absolutePath/$filePath'));

      if (_isNotEmpty(_content)) {
        yield DependencyFile(
          packageName: package.package(),
          content: _content,
        );
      }
    }
  }

  bool _isNotEmpty(String content) => content != null && content.length > 0;

  Future<String> get _rootPackageName async => readYamlFileFromRoot()['name'];
}
