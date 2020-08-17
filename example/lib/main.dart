import 'package:dependency_visitor/dependency_visitor.dart';

void main() {
  print('Show which packages has LICENSE file:');
  DependencyVisitor(filePaths: ['LICENSE']).run().listen((dependencyFile) {
    print('Package: ${dependencyFile.packageName}:');
    print(dependencyFile.content);
    print('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');
  }).onDone(() {
    print('Done!');
  });
}
