import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Keeps info about founded file.
class DependencyFile extends Equatable {
  /// Name of package, where this file has been found.
  final String packageName;

  /// Content of this file.
  final String content;

  /// Absolute path of this file.
  final String absolutePath;

  /// Creates an instance of [DependencyFile]
  const DependencyFile({
    @required this.packageName,
    @required this.content,
    @required this.absolutePath,
  });

  @override
  List<Object> get props => [packageName, content, absolutePath];
}
