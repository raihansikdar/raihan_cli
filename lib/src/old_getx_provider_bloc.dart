import 'dart:io';

const configFilePath = 'tool/.cli_architecture_config';

void runCli(List<String> args) async {
  if (args.isEmpty) {
    print(
      '❌ Please provide a feature name.\nUsage: raihan_cli.dart <feature_name>\n',
    );
    return;
  }

  // ----------Handle remove command---------
  if (args[0] == 'remove') {
    if (args.length < 2) {
      print(
        '❌ Please provide a feature name to remove.\nUsage: raihan_cli.dart remove <feature_name>',
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
      stdout.write('⚠ Are you sure you want to delete "$removePath"? (y/N): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      if (confirm == 'y') {
        try {
          dir.deleteSync(recursive: true);
          print('🗑 Successfully removed folder "$removePath".');
        } catch (e) {
          print('❌ Failed to delete folder: $e');
        }
      } else {
        print('❌ Deletion cancelled.');
      }
    } else {
      print('⚠ Folder "$removePath" does not exist.');
    }
    return;
  }

  final feature = args[0];
  final pascalFeature = toPascalCase(feature);

  // Step 1: Load or ask path config
  final pathConfig = _readConfig();
  String? pathType = pathConfig['pathType'];
  String? customParent = pathConfig['customPath'];

  if (pathType == null) {
    while (true) {
      print('\n📁 Choose path type:');
      print('1. Feature-based path (lib/src/features/$feature)');
      print('2. Custom path (lib/<your_parent_path>/$feature)');
      stdout.write('Enter your choice (1 or 2): ');
      pathType = stdin.readLineSync()?.trim();

      if (pathType == '1' || pathType == '2') {
        if (pathType == '2') {
          stdout.write(
            '📁 Enter custom parent path (e.g., "feature" for lib/feature/$feature, or "." for lib/$feature): ',
          );
          customParent = stdin.readLineSync()?.trim() ?? '';
        }
        break;
      } else {
        print('❌ Invalid path choice. Please try again.');
      }
    }

    try {
      _saveConfig({
        ...pathConfig,
        'pathType': pathType ?? '',
        'customPath': (customParent ?? '').toString(),
      });
      final updatedConfig = _readConfig();
      pathType = updatedConfig['pathType'];
      customParent = updatedConfig['customPath'];
    } catch (e) {
      print('❌ Failed to save path configuration: $e');
      return;
    }
  }

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

  // Step 2: Choose state management
  String? stateManagement = pathConfig['stateManagement'];
  if (stateManagement == null) {
    while (true) {
      print('\n🛠 Choose state management:');
      print('1. getx');
      print('2. provider');
      print('3. bloc');
      stdout.write('Enter your choice (1/2/3): ');
      final input = stdin.readLineSync()?.trim();

      if (input == '1') {
        stateManagement = 'getx';
        break;
      } else if (input == '2') {
        stateManagement = 'provider';
        break;
      } else if (input == '3') {
        stateManagement = 'bloc';
        break;
      } else {
        print('❌ Invalid state management choice. Please try again.');
      }
    }

    try {
      _saveConfig({..._readConfig(), 'stateManagement': stateManagement});
    } catch (e) {
      print('❌ Failed to save state management configuration: $e');
      return;
    }
  }

  // Step 3: Load or ask architecture
  String? architecture = pathConfig['architecture'];

  if (architecture == null) {
    while (true) {
      print('\n🧱 Choose architecture:');
      print('1. mvc');
      print('2. mvvm');
      stdout.write('Enter your choice (1 or 2): ');
      final input = stdin.readLineSync()?.trim();

      if (input == '1') {
        architecture = 'mvc';
        break;
      } else if (input == '2') {
        architecture = 'mvvm';
        break;
      } else {
        print('❌ Invalid architecture choice. Please try again.');
      }
    }

    try {
      _saveConfig({..._readConfig(), 'architecture': architecture});
    } catch (e) {
      print('❌ Failed to save architecture configuration: $e');
      return;
    }
  }

  // Step 4: Create base folder
  final featureDir = Directory(basePath);
  bool createdAnything = false;

  try {
    if (!featureDir.existsSync()) {
      featureDir.createSync(recursive: true);
      print('\n♻ Created folder "$basePath"');
      createdAnything = true;
    } else {
      print('♻ Folder "$basePath" already exists');
    }
  } catch (e) {
    print('❌ Failed to create folder "$basePath": $e');
    return;
  }

  // Step 5: Create folder structure based on architecture & state management
  List<String> folders = [
    '$basePath/model',
    '$basePath/views/screen',
    '$basePath/views/widget',
  ];

  if (stateManagement == 'bloc') {
    if (architecture == 'mvc') {
      folders = ['$basePath/bloc', ...folders];
    } else if (architecture == 'mvvm') {
      folders = ['$basePath/bloc', '$basePath/repository', ...folders];
    }
  } else if (architecture == 'mvc') {
    if (stateManagement == 'provider') {
      folders.add('$basePath/provider');
    } else {
      folders.add('$basePath/controllers');
    }
  } else if (architecture == 'mvvm') {
    if (stateManagement == 'provider') {
      folders.addAll(['$basePath/view_model_provider', '$basePath/repository']);
    } else {
      folders.addAll(['$basePath/view_model', '$basePath/repository']);
    }
  }

  for (final folder in folders) {
    final dir = Directory(folder);
    try {
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        print('📁 Created: $folder');
        createdAnything = true;
      } else {
        print('⚠ Already exists: $folder');
      }
    } catch (e) {
      print('❌ Failed to create folder "$folder": $e');
      return;
    }
  }

  // Step 6: Create files
  if (stateManagement == 'bloc') {
    final blocFolder = '$basePath/bloc';
    createdAnything =
        createFile(
          '$blocFolder/${feature}_bloc.dart',
          '// BLoC for $feature\n',
        ) ||
        createdAnything;
    createdAnything =
        createFile(
          '$blocFolder/${feature}_event.dart',
          '// Event for $feature\n',
        ) ||
        createdAnything;
    createdAnything =
        createFile(
          '$blocFolder/${feature}_state.dart',
          '// State for $feature\n',
        ) ||
        createdAnything;

    if (architecture == 'mvvm') {
      final repoFolder = '$basePath/repository';
      createdAnything =
          createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') ||
          createdAnything;

      createdAnything =
          createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') ||
          createdAnything;
    }
  } else if (architecture == 'mvc') {
    if (stateManagement == 'provider') {
      createdAnything =
          createFile(
            '$basePath/provider/${feature}_provider.dart',
            '// Provider for $feature (MVC with Provider)\n',
          ) ||
          createdAnything;
    } else {
      createdAnything =
          createFile(
            '$basePath/controllers/${feature}_controller.dart',
            '// Controller for $feature (MVC)\n',
          ) ||
          createdAnything;
    }
  } else if (architecture == 'mvvm') {
    if (stateManagement == 'provider') {
      createdAnything =
          createFile(
            '$basePath/view_model_provider/${feature}_view_model_provider.dart',
            '// ViewModel (Provider) for $feature\n',
          ) ||
          createdAnything;
    } else {
      createdAnything =
          createFile(
            '$basePath/view_model/${feature}_view_model.dart',
            '// ViewModel for $feature (MVVM)\n',
          ) ||
          createdAnything;
    }

    final repoFolder = '$basePath/repository';
    createdAnything =
        createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') ||
        createdAnything;

    createdAnything =
        createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') ||
        createdAnything;
  }

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

  if (createdAnything) {
    print(
      '\n🚀 "$feature" ($architecture, $stateManagement) structure created at "$basePath"!',
    );
  } else {
    print(
      '\nℹ "$feature" ($architecture, $stateManagement) structure already exists at "$basePath". No new files or folders created.',
    );
  }
}

// ---------------- Helper Functions ----------------

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
      print('⚠ File already exists: $path');
      return false;
    }
  } catch (e) {
    print('❌ Failed to create file "$path": $e');
    return false;
  }
}

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

Map<String, String> _readConfig() {
  final configFile = File(configFilePath);
  if (!configFile.existsSync()) {
    return {};
  }
  try {
    final lines = configFile.readAsLinesSync();
    return {
      for (var line in lines)
        if (line.contains('='))
          line.split('=').first.trim(): line.split('=').last.trim(),
    };
  } catch (e) {
    print('❌ Failed to read config file $configFilePath: $e');
    return {};
  }
}

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
    throw Exception('Failed to save config to $configFilePath:$e');
  }
}
