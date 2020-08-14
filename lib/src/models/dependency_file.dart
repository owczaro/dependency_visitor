import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Keeps info about founded file.
class DependencyFile extends Equatable {
  /// Name of package, where file has been found.
  final String packageName;

  /// Content of that file.
  final String content;

  /// Creates an instance of [DependencyFile]
  const DependencyFile({
    @required this.packageName,
    @required this.content,
  });

  @override
  List<Object> get props => [packageName, content];
}
