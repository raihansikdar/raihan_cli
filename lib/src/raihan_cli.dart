/// ---------------------------------------------
/// 🧩 raihan_cli.dart
/// ---------------------------------------------
/// A Dart CLI utility for generating **clean Flutter feature folders**
/// following **MVC**, **MVVM**, or **Clean Architecture** structures.
///
/// 🔹 Supports multiple state management systems:
///   - GetX
///   - Provider
///   - Riverpod
///   - BLoC
///
/// 🔹 Key Features:
///   • Interactive prompts for architecture, state management, and folder path
///   • Automatic folder and boilerplate file creation
///   • Supports feature removal (`remove <feature_name>`)
///   • Saves your configuration in `tool/.cli_architecture_config`
///
/// ---------------------------------------------


import 'dart:io';

/// The configuration file path used by raihan_cli.
const configFilePath = 'tool/.cli_architecture_config';

/// The main function that runs the CLI tool.
///
/// Handles user input for feature creation and removal, and manages
/// folder generation based on selected architecture and state management.
///
/// - [args] : List of command-line arguments provided by the user.
///   Example:
///   ```bash
///   dart run tool/raihan_cli.dart login
///   dart run tool/raihan_cli.dart remove login
///   ```
void runCli(List<String> args) async {
  if (args.isEmpty) {
    print(
      'Please provide a feature name.\nUsage: raihan_cli.dart <feature_name>\n',
    );
    return;
  }

  // ----------Handle remove command---------
  if (args[0] == 'remove') {
    if (args.length < 2) {
      print(
        'Please provide a feature name to remove.\nUsage: raihan_cli.dart remove <feature_name>',
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
      print('Invalid path configuration. Cannot determine path for removal.');
      return;
    }

    final dir = Directory(removePath);
    if (dir.existsSync()) {
      stdout.write('Are you sure you want to delete "$removePath"? (y/N): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      if (confirm == 'y') {
        try {
          dir.deleteSync(recursive: true);
          print('Successfully removed folder "$removePath".');
        } catch (e) {
          print('Failed to delete folder: $e');
        }
      } else {
        print('Deletion cancelled.');
      }
    } else {
      print('Folder "$removePath" does not exist.');
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
      print('\nChoose path type:');
      print('1. Feature-based path (lib/src/features/$feature)');
      print('2. Custom path (lib/<your_parent_path>/$feature)');
      stdout.write('Enter your choice (1 or 2): ');
      pathType = stdin.readLineSync()?.trim();

      if (pathType == '1' || pathType == '2') {
        if (pathType == '2') {
          stdout.write(
            'Enter custom parent path (e.g., "feature" for lib/feature/$feature, or "." for lib/$feature): ',
          );
          customParent = stdin.readLineSync()?.trim() ?? '';
        }
        break;
      } else {
        print('Invalid path choice. Please try again.');
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
      print('Failed to save path configuration: $e');
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
    print('Invalid path choice. Aborting.');
    return;
  }

  // Step 2: Choose state management
  String? stateManagement = pathConfig['stateManagement'];
  if (stateManagement == null) {
    while (true) {
      print('\nChoose state management:');
      print('1. getx');
      print('2. provider');
      print('3. riverpod');
      print('4. bloc');
      print('5. others');
      stdout.write('Enter your choice (1/2/3/4/5): ');

      final input = stdin.readLineSync()?.trim();

      if (input == '1') {
        stateManagement = 'getx';
        break;
      } else if (input == '2') {
        stateManagement = 'provider';
        break;
      } else if (input == '3') {
        stateManagement = 'riverpod';
        break;
      } else if (input == '4') {
        stateManagement = 'bloc';
        break;
      } else if (input == '5') {
        stateManagement = 'others';
        break;
      } else {
        print('Invalid state management choice. Please try again.');
      }
    }

    try {
      _saveConfig({..._readConfig(), 'stateManagement': stateManagement});
    } catch (e) {
      print('Failed to save state management configuration: $e');
      return;
    }
  }

  // Step 3: Choose architecture (now includes Clean)
  String? architecture = pathConfig['architecture'];

  if (architecture == null) {
    while (true) {
      print('\nChoose architecture:');
      print('1. mvc');
      print('2. mvvm');
      print('3. clean architecture');
      stdout.write('Enter your choice (1/2/3): ');
      final input = stdin.readLineSync()?.trim();

      if (input == '1') {
        architecture = 'mvc';
        break;
      } else if (input == '2') {
        architecture = 'mvvm';
        break;
      } else if (input == '3') {
        architecture = 'clean';
        break;
      } else {
        print('Invalid architecture choice. Please try again.');
      }
    }

    try {
      _saveConfig({..._readConfig(), 'architecture': architecture});
    } catch (e) {
      print('Failed to save architecture configuration: $e');
      return;
    }
  }

  // Step 4: Create base folder
  final featureDir = Directory(basePath);
  bool createdAnything = false;

  try {
    if (!featureDir.existsSync()) {
      featureDir.createSync(recursive: true);
      print('\nCreated folder "$basePath"');
      createdAnything = true;
    } else {
      print('Folder "$basePath" already exists');
    }
  } catch (e) {
    print('Failed to create folder "$basePath": $e');
    return;
  }

  // Step 5: Handle Clean Architecture
  if (architecture == 'clean') {
    final folders = [
      '$basePath/data/data_source',
      '$basePath/data/model',
      '$basePath/data/repository',
      '$basePath/domain/entities',
      '$basePath/domain/repository',
      '$basePath/domain/use_case',
      '$basePath/presentation/views/screen',
      '$basePath/presentation/views/widgets',
    ];

    // Add state-specific folder in presentation
    if (stateManagement == 'bloc') {
      folders.add('$basePath/presentation/bloc');
    } else if (stateManagement == 'provider') {
      folders.add('$basePath/presentation/provider');
    } else if (stateManagement == 'riverpod') {
      folders.add('$basePath/presentation/riverpod');
    } else {
      folders.add('$basePath/presentation/controller');
    }

    for (final folder in folders) {
      final dir = Directory(folder);
      try {
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
          print('Created: $folder');
          createdAnything = true;
        } else {
          print('Already exists: $folder');
        }
      } catch (e) {
        print('Failed to create folder "$folder": $e');
        return;
      }
    }

    // --- Create Clean Architecture Files ---
    final snakeFeature = feature.replaceAll('-', '_');

    // Data Layer
    createdAnything = createFile(
      '$basePath/data/data_source/${snakeFeature}_remote_data_source.dart',
      '''// TODO: Define remote data methods
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/data/data_source/${snakeFeature}_remote_data_source_impl.dart',
      '''// TODO: Implement remote data source
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/data/data_source/${snakeFeature}_local_data_source.dart',
      '''// TODO: Define local data methods
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/data/model/${snakeFeature}_model.dart',
      '''// TODO: Define model fields
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/data/repository/${snakeFeature}_repository_impl.dart',
      '''
import '../../domain/repository/${snakeFeature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement repository methods here
}
''',
    ) ||
        createdAnything;

    // Domain Layer
    createdAnything = createFile(
      '$basePath/domain/entities/${snakeFeature}_entities.dart',
      '''// TODO: Define entity fields
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/domain/repository/${snakeFeature}_repository.dart',
      '''abstract class ${pascalFeature}Repository {
    // TODO: Define your abstract methods here
}
''',
    ) ||
        createdAnything;

    createdAnything = createFile(
      '$basePath/domain/use_case/${snakeFeature}_use_case.dart',
      '''// TODO: Define UseCase
''',
    ) ||
        createdAnything;

    // Presentation Layer - State Management Specific
    if (stateManagement == 'bloc') {
      final blocPath = '$basePath/presentation/bloc';
      createdAnything = createFile('$blocPath/${snakeFeature}_bloc.dart', '''// TODO: implement event handler
''') || createdAnything;

      createdAnything = createFile('$blocPath/${snakeFeature}_event.dart', '''// TODO: implement event 
''') || createdAnything;

      createdAnything = createFile('$blocPath/${snakeFeature}_state.dart', '''// TODO: implement state 
''') || createdAnything;

    } else if (stateManagement == 'provider') {
      createdAnything = createFile(
        '$basePath/presentation/provider/${snakeFeature}_provider.dart',
        '''// TODO: Implement provider
''',
      ) ||
          createdAnything;

    } else if (stateManagement == 'riverpod') {
      createdAnything = createFile(
        '$basePath/presentation/riverpod/${snakeFeature}_notifier.dart',
        '''// TODO: Implement notifier
''',
      ) ||
          createdAnything;

      createdAnything = createFile(
        '$basePath/presentation/riverpod/${snakeFeature}_provider.dart',
        '''// TODO: Implement provider
''',
      ) ||
          createdAnything;

    } else {
      // getx or others
      createdAnything = createFile(
        '$basePath/presentation/controller/${snakeFeature}_controller.dart',
        ''' // TODO: Implement controller
''',
      ) ||
          createdAnything;
    }

    // Views
    createdAnything = createFile(
      '$basePath/presentation/views/screen/${snakeFeature}_screen.dart',
      '''
import 'package:flutter/material.dart';

class ${pascalFeature}Screen extends StatelessWidget {
  const ${pascalFeature}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascalFeature')),
      body: const Center(child: Text('Welcome to $feature!')),
    );
  }
}
''',
    ) ||
        createdAnything;

    // Injection Container
    createdAnything = createFile(
      '$basePath/${snakeFeature}_dependency_injection.dart',
      '''
// TODO: Setup dependency injection (get_it, etc.)
// Example: final sl = GetIt.instance;
''',
    ) ||
        createdAnything;

  } else {
    // Existing MVC / MVVM Logic (Unchanged)
    List<String> folders = [
      '$basePath/model',
      '$basePath/views/screen',
      '$basePath/views/widgets',
    ];

    if (stateManagement == 'bloc') {
      if (architecture == 'mvc') {
        folders = ['$basePath/bloc', ...folders];
      } else if (architecture == 'mvvm') {
        folders = ['$basePath/bloc', '$basePath/repository', ...folders];
      }
    } else if (stateManagement == 'provider') {
      if (architecture == 'mvc') {
        folders.add('$basePath/provider');
      } else if (architecture == 'mvvm') {
        folders.addAll(['$basePath/provider', '$basePath/repository']);
      }
    } else if (stateManagement == 'riverpod') {
      if (architecture == 'mvc') {
        folders.add('$basePath/riverpod');
      } else if (architecture == 'mvvm') {
        folders.addAll(['$basePath/riverpod', '$basePath/repository']);
      }
    } else if (architecture == 'mvc') {
      folders.add('$basePath/controllers');
    } else if (architecture == 'mvvm') {
      folders.addAll([
        '$basePath/view_model',
        '$basePath/repository',
      ]);
    }

    for (final folder in folders) {
      final dir = Directory(folder);
      try {
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
          print('Created: $folder');
          createdAnything = true;
        } else {
          print('Already exists: $folder');
        }
      } catch (e) {
        print('Failed to create folder "$folder": $e');
        return;
      }
    }

    // Existing file creation logic (unchanged)
    if (stateManagement == 'bloc') {
      final blocFolder = '$basePath/bloc';
      createdAnything = createFile('$blocFolder/${feature}_bloc.dart', '// BLoC for $feature\n') || createdAnything;
      createdAnything = createFile('$blocFolder/${feature}_event.dart', '// Event for $feature\n') || createdAnything;
      createdAnything = createFile('$blocFolder/${feature}_state.dart', '// State for $feature\n') || createdAnything;

      if (architecture == 'mvvm') {
        final repoFolder = '$basePath/repository';
        createdAnything = createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') || createdAnything;

        createdAnything = createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') || createdAnything;
      }
    } else if (stateManagement == 'provider') {
      if (architecture == 'mvc') {
        createdAnything = createFile('$basePath/provider/${feature}_provider.dart', '// Provider for $feature (MVC with Provider)\n') || createdAnything;
      } else {
        createdAnything = createFile('$basePath/provider/${feature}_provider.dart', '// ViewModel (Provider) for $feature\n') || createdAnything;

        final repoFolder = '$basePath/repository';
        createdAnything = createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') || createdAnything;

        createdAnything = createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') || createdAnything;
      }
    } else if (stateManagement == 'riverpod') {
      final riverpodFolder = (architecture == 'mvc') ? '$basePath/riverpod' : '$basePath/riverpod';
      createdAnything = createFile('$riverpodFolder/${feature}_notifier.dart', '// Riverpod Notifier for $feature\n') || createdAnything;
      createdAnything = createFile('$riverpodFolder/${feature}_provider.dart', '// Riverpod Provider for $feature\n') || createdAnything;

      if (architecture == 'mvvm') {
        final repoFolder = '$basePath/repository';
        createdAnything = createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') || createdAnything;

        createdAnything = createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') || createdAnything;
      }
    } else if (architecture == 'mvc') {
      createdAnything = createFile('$basePath/controllers/${feature}_controller.dart', '// Controller for $feature (MVC)\n') || createdAnything;
    } else if (architecture == 'mvvm') {
      createdAnything = createFile('$basePath/view_model/${feature}_view_model.dart', '// ViewModel for $feature (MVVM)\n') || createdAnything;

      final repoFolder = '$basePath/repository';
      createdAnything = createFile('$repoFolder/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') || createdAnything;

      createdAnything = createFile('$repoFolder/${feature}_repository_impl.dart', '''
import '${feature}_repository.dart';

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {
  // Implement methods here
}
''') || createdAnything;
    }

    createdAnything = createFile('$basePath/model/${feature}_model.dart', '// Model for $feature\n') || createdAnything;

    createdAnything = createFile('$basePath/views/screen/${feature}_screen.dart', '''
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
''') || createdAnything;
  }

  // Final Message
  if (createdAnything) {
    print('\n"$feature" ($architecture, $stateManagement) structure created at "$basePath"!');
  } else {
    print('\n"$feature" ($architecture, $stateManagement) structure already exists at "$basePath". No new files or folders created.');
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
      print('Created file: $path');
      return true;
    } else {
      print('File already exists: $path');
      return false;
    }
  } catch (e) {
    print('Failed to create file "$path": $e');
    return false;
  }
}

String toPascalCase(String text) {
  return text
      .split(RegExp(r'[-_ ]'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
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
    print('Failed to read config file $configFilePath: $e');
    return {};
  }
}

void _saveConfig(Map<String, String> config) {
  final configFile = File(configFilePath);
  final toolDir = Directory('tool');

  try {
    if (!toolDir.existsSync()) {
      toolDir.createSync(recursive: true);
      print('Created tool directory for configuration');
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