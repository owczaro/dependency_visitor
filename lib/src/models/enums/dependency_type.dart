/// Dependency type specified by "dependency" keys in pubspec.lock files
enum DependencyType {
  /// Root package
  root,

  /// Specified as "direct main" dependencies in pubspec.lock files
  direct,

  /// Specified as "direct dev" in pubspec.lock files
  development,

  /// Specified as "transitive" in pubspec.lock files
  transitive,
}
