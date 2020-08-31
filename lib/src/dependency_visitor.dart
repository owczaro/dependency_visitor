import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_lock/pubspec_lock.dart' hide DependencyType;
import 'package:universal_io/io.dart';
import 'models/dependency_file.dart';
import 'models/enums/dependency_type.dart';
import 'services/file_utils.dart';
import 'services/pub_cache_service.dart';

/// Visits root package, transitive and immediate dependencies
/// in order to search given files.
///
///
/// Typical usage is as follows:
///
/// ```dart
///  DependencyVisitor(filePaths: ['path to file or file name'])
///    .run().listen((dependencyFile) {
///      // Do smth with dependencyFile.packageName and dependencyFile.content
///    }).onDone(() {
///      // Do smth on the end if you need to
///  });
/// ```
class DependencyVisitor {
  /// Path to file and its name.
  final List<String> filePaths;

  /// Which dependencies should be consider:
  /// * root package
  /// * direct
  /// * direct dev
  /// * transitive
  /// * all of above
  ///
  /// This field also defines search order.
  final List<DependencyType> dependencyTypes;

  final _pubCacheService = PubCacheService();

  final _pubspecLock =
      File('pubspec.lock').readAsStringSync().loadPubspecLockFromYaml();

  /// Creates an instance of [DependencyVisitor]
  DependencyVisitor({
    @required this.filePaths,
    this.dependencyTypes = const [
      DependencyType.development,
      DependencyType.transitive,
      DependencyType.direct,
      DependencyType.root,
    ],
  })  : assert(filePaths != null || filePaths.isNotEmpty),
        assert(dependencyTypes != null || dependencyTypes.isNotEmpty);

  /// Search file and read its content.
  Stream<DependencyFile> run() async* {
    for (final dependencyType in dependencyTypes) {
      if (dependencyType == DependencyType.root) {
        yield* _searchAndReadInRoot();
      } else {
        for (final package in _packagesForDependencyType(dependencyType)) {
          yield* _searchAndReadDependencies(package);
        }
      }
    }
  }

  Iterable<PackageDependency> _packagesForDependencyType(
      DependencyType dependencyType) {
    return _pubspecLock.packages
        .where((p) => dependencyType.toString() == p.type().toString());
  }

  Stream<DependencyFile> _searchAndReadInRoot() async* {
    for (var filePath in filePaths) {
      var content = await readFileAsString(filePath);
      if (_isNotEmpty(content)) {
        yield DependencyFile(
          packageName: await _rootPackageName,
          content: content,
          absolutePath:
              p.normalize('${Directory.current.absolute.path}/$filePath'),
        );
      }
    }
  }

  Stream<DependencyFile> _searchAndReadDependencies(
      PackageDependency package) async* {
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

    for (var filePath in filePaths) {
      final _content =
          await readFileAsString(p.normalize('$absolutePath/$filePath'));

      if (_isNotEmpty(_content)) {
        yield DependencyFile(
          packageName: package.package(),
          content: _content,
          absolutePath: p.normalize('$absolutePath/$filePath'),
        );
      }
    }
  }

  bool _isNotEmpty(String content) => content != null && content.isNotEmpty;

  Future<String> get _rootPackageName async => readYamlFileFromRoot()['name'];
}
