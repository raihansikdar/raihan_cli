import 'dart:io';

/// Configuration file path for storing CLI preferences
/// (e.g., selected architecture, path type, and custom parent path).
const configFilePath = 'tool/.cli_architecture_config';

/// Entry point for the custom CLI tool.
///
/// **Usage:**
/// ```bash
/// dart tool/raihan_cli.dart <feature_name> [architecture]
/// dart tool/raihan_cli.dart remove <feature_name>
/// ```
void runCli(List<String> args) async {
  // 🟥 Validate arguments
  if (args.isEmpty) {
    print(
      '❌ Please provide a feature name.\n'
      'Usage: dart tool/raihan_cli.dart <feature_name> [optional_parent_path]',
    );
    return;
  }

  // 🗑️ ---------- Handle remove command ----------
  if (args[0] == 'remove') {
    if (args.length < 2) {
      print(
        '❌ Please provide a feature name to remove.\n'
        'Usage: dart tool/raihan_cli.dart remove <feature_name>',
      );
      return;
    }

    final removeFeature = args[1];
    final pathConfig = _readConfig();
    final pathType = pathConfig['pathType'];
    final customParent = pathConfig['customPath'];

    String removePath;
    if (pathType == '1') {
      removePath = 'lib/src/features/$removeFeature';
    } else if (pathType == '2') {
      removePath =
          (customParent == '.' || (customParent?.isEmpty ?? true))
              ? 'lib/$removeFeature'
              : 'lib/$customParent/$removeFeature';
    } else {
      print('❌ Invalid path configuration. Cannot determine path for removal.');
      return;
    }

    final dir = Directory(removePath);
    if (dir.existsSync()) {
      stdout.write('⚠️ Are you sure you want to delete "$removePath"? (y/N): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      if (confirm == 'y') {
        try {
          dir.deleteSync(recursive: true);
          print('🗑️ Successfully removed folder "$removePath".');
        } catch (e) {
          print('❌ Failed to delete folder: $e');
        }
      } else {
        print('❌ Deletion cancelled.');
      }
    } else {
      print('⚠️ Folder "$removePath" does not exist.');
    }
    return;
  }

  // 🟢 ---------- Create feature command ----------
  final feature = args[0];
  final pascalFeature = toPascalCase(feature);

  // Step 1: Load or request the folder path configuration
  final pathConfig = _readConfig();
  String? pathType = pathConfig['pathType'];
  String? customParent = pathConfig['customPath'];

  if (pathType == null) {
    print('\n📁 Choose path type:');
    print('1. Feature-based path (lib/src/features/$feature)');
    print('2. Custom path (lib/<your_parent_path>/$feature)');
    stdout.write('Enter your choice (1 or 2): ');
    final input = stdin.readLineSync()?.trim();

    if (input == '1') {
      pathType = '1';
    } else if (input == '2') {
      pathType = '2';
      stdout.write(
        '📁 Enter custom parent path (e.g., "feature" for lib/feature/$feature, or "." for lib/$feature): ',
      );
      customParent = stdin.readLineSync()?.trim() ?? '';
    } else {
      print('❌ Invalid path choice. Aborting.');
      return;
    }

    try {
      _saveConfig({
        ...pathConfig,
        'pathType': pathType,
        'customPath': (customParent ?? '').toString(),
      });
    } catch (e) {
      print('❌ Failed to save path configuration: $e');
      return;
    }
  }

  // Determine base feature directory
  String basePath;
  if (pathType == '1') {
    basePath = 'lib/src/features/$feature';
  } else if (pathType == '2') {
    basePath =
        (customParent == '.' || (customParent?.isEmpty ?? true))
            ? 'lib/$feature'
            : 'lib/$customParent/$feature';
  } else {
    print('❌ Invalid path choice. Aborting.');
    return;
  }

  // Step 2: Load or request architecture (MVC or MVVM)
  String? architecture = pathConfig['architecture'];
  if (args.length > 1 && args[1] != '1' && args[1] != '2') {
    architecture = args[1].toLowerCase();
    try {
      _saveConfig({..._readConfig(), 'architecture': architecture});
    } catch (e) {
      print('❌ Failed to save architecture configuration: $e');
      return;
    }
  }

  if (architecture == null) {
    print('\n🧱 Choose architecture:');
    print('1. mvc');
    print('2. mvvm');
    stdout.write('Enter your choice (1 or 2): ');
    final input = stdin.readLineSync();

    if (input == '1') {
      architecture = 'mvc';
    } else if (input == '2') {
      architecture = 'mvvm';
    } else {
      print('❌ Invalid architecture choice. Aborting.');
      return;
    }

    try {
      _saveConfig({..._readConfig(), 'architecture': architecture});
    } catch (e) {
      print('❌ Failed to save architecture configuration: $e');
      return;
    }
  }

  // Step 3: Create the base feature directory
  final featureDir = Directory(basePath);
  bool createdAnything = false;

  try {
    if (!featureDir.existsSync()) {
      featureDir.createSync(recursive: true);
      print('\n♻️ Created folder "$basePath"');
      createdAnything = true;
    } else {
      print('♻️ Folder "$basePath" already exists');
    }
  } catch (e) {
    print('❌ Failed to create folder "$basePath": $e');
    return;
  }

  // Define subfolder structure
  List<String> folders = [
    '$basePath/model',
    '$basePath/views/screen',
    '$basePath/views/widget',
  ];

  if (architecture == 'mvc') {
    folders.add('$basePath/controllers');
  } else if (architecture == 'mvvm') {
    folders.addAll(['$basePath/view_model', '$basePath/repository']);
  }

  // Create subfolders
  for (final folder in folders) {
    final dir = Directory(folder);
    try {
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        print('📁 Created: $folder');
        createdAnything = true;
      } else {
        print('⚠️ Already exists: $folder');
      }
    } catch (e) {
      print('❌ Failed to create folder "$folder": $e');
      return;
    }
  }

  // Step 4: Create starter files
  if (architecture == 'mvc') {
    createdAnything =
        createFile(
          '$basePath/controllers/${feature}_controller.dart',
          '// Controller for $feature (MVC)\n',
        ) ||
        createdAnything;
  } else if (architecture == 'mvvm') {
    createdAnything =
        createFile(
          '$basePath/view_model/${feature}_view_model.dart',
          '// ViewModel for $feature (MVVM)\n',
        ) ||
        createdAnything;
    createdAnything =
        createFile('$basePath/repository/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') ||
        createdAnything;
    createdAnything =
        createFile('$basePath/repository/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') ||
        createdAnything;
  }

  // Common model and screen files
  createdAnything =
      createFile(
        '$basePath/model/${feature}_model.dart',
        '// Model for $feature\n',
      ) ||
      createdAnything;
  createdAnything =
      createFile('$basePath/views/screen/${feature}_screen.dart', '''
import 'package:flutter/material.dart';

class ${pascalFeature}Screen extends StatelessWidget {
  const ${pascalFeature}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$feature screen')),
      body: const Center(child: Text('Welcome to $feature!')),
    );
  }
}
''') ||
      createdAnything;

  // Final log
  if (createdAnything) {
    print('\n🚀 "$feature" ($architecture) structure created at "$basePath"!');
  } else {
    print(
      '\nℹ️ "$feature" ($architecture) structure already exists at "$basePath". No new files or folders created.',
    );
  }
}

/// Creates a file with [content].
bool createFile(String path, String content) {
  final file = File(path);
  final directory = file.parent;

  try {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      print('✅  Created file: $path');
      return true;
    } else {
      print('⚠️ File already exists: $path');
      return false;
    }
  } catch (e) {
    print('❌ Failed to create file "$path": $e');
    return false;
  }
}

/// Converts snake_case → PascalCase.
String toPascalCase(String text) {
  return text
      .split('_')
      .map(
        (word) =>
            word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '',
      )
      .join();
}

/// Reads config file.
Map<String, String> _readConfig() {
  final configFile = File(configFilePath);
  if (!configFile.existsSync()) {
    return {};
  }
  try {
    final lines = configFile.readAsLinesSync();
    return {
      for (var line in lines)
        if (line.contains('=')) line.split('=').first.trim(): line.split('=').last.trim(),
    };
  } catch (e) {
    print('❌ Failed to read config file $configFilePath: $e');
    return {};
  }
}

/// Saves config to file.
void _saveConfig(Map<String, String> config) {
  final configFile = File(configFilePath);
  final toolDir = Directory('tool');

  try {
    if (!toolDir.existsSync()) {
      toolDir.createSync(recursive: true);
      print('📁 Created tool directory for configuration');
    }

    final buffer = StringBuffer();
    config.forEach((key, value) {
      buffer.writeln('$key=$value');
    });
    configFile.writeAsStringSync(buffer.toString());
  } catch (e) {
    throw Exception('Failed to save config to $configFilePath: $e');
  }
}
