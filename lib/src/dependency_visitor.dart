import 'package:path/path.dart' as p;
import 'package:pubspec_lock_reader/pubspec_lock_reader.dart';
import 'package:universal_io/io.dart';
import 'models/dependency_file.dart';
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

  final _pubspecLock = getPubspecLock();

  /// Creates an instance of [DependencyVisitor]
  DependencyVisitor({
    required this.filePaths,
    this.dependencyTypes = const [
      DependencyType.development,
      DependencyType.transitive,
      DependencyType.direct,
      DependencyType.root,
    ],
  })  : assert(filePaths.isNotEmpty),
        assert(dependencyTypes.isNotEmpty);

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
          DependencyType dependencyType) =>
      _pubspecLock.packages.where((element) => element.type == dependencyType);

  Stream<DependencyFile> _searchAndReadInRoot() async* {
    for (var filePath in filePaths) {
      var content = await readFileAsString(filePath);
      if (content != null && content.isNotEmpty) {
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
    switch (package.runtimeType) {
      case HostedPackageDependency:
        absolutePath =
            '${_pubCacheService.defaultPath}/hosted/pub.dartlang.org/'
            '${package.package}-${package.version}';
        break;
      case GitPackageDependency:
        absolutePath = '${_pubCacheService.defaultPath}/git/'
            '${package.package}-'
            '${(package as GitPackageDependency).resolvedRef}';
        if (!Directory(absolutePath).absolute.existsSync()) {
          absolutePath = '${_pubCacheService.defaultPath}/git/cache/'
              '${package.package}-${package.resolvedRef}';
        }
        break;
      case PathPackageDependency:
        absolutePath = '${Directory.current.absolute.path}'
            '/${(package as PathPackageDependency).path}';
        break;
    }

    for (var filePath in filePaths) {
      final _content =
          await readFileAsString(p.normalize('$absolutePath/$filePath'));

      if (_content != null && _content.isNotEmpty) {
        yield DependencyFile(
          packageName: package.package,
          content: _content,
          absolutePath: p.normalize('$absolutePath/$filePath'),
        );
      }
    }
  }

  Future<String> get _rootPackageName async => readYamlFileFromRoot()!['name'];
}
