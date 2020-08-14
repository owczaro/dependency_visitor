import 'package:dependency_visitor/dependency_visitor.dart';

Future<void> main() async {
  print('Show which packages has LICENSE file:');
  DependencyVisitor(filePath: 'LICENSE').run().listen((dependencyFile) {
    print('Package: ${dependencyFile.packageName}:');
    print(dependencyFile.content);
    print('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');
  }).onDone(() {
    print('Done!');
  });
}
