import 'dart:io';

import 'package:test/test.dart';
import 'package:raihan_cli/raihan_cli.dart';

void main() {
  group('PascalCase Conversion', () {
    test('Converts snake_case to PascalCase', () {
      expect(toPascalCase('my_feature'), equals('MyFeature'));
      expect(toPascalCase('feature'), equals('Feature'));
      expect(toPascalCase('multi_word_feature'), equals('MultiWordFeature'));
    });
  });

  group('File Creation', () {
    test('Creates file with given content', () {
      final testPath = 'test/tmp/test_file.txt';
      final content = 'Test content';

      // Cleanup before test
      final file = File(testPath);
      if (file.existsSync()) file.deleteSync(recursive: true);

      final created = createFile(testPath, content);
      expect(created, isTrue);
      expect(File(testPath).existsSync(), isTrue);
      expect(File(testPath).readAsStringSync(), equals(content));

      // Cleanup after test
      File(testPath).deleteSync();
    });
  });
}
