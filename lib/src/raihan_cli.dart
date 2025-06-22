import 'dart:io';
const configFilePath = 'tool/.cli_architecture_config';

void runCli(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Please provide a feature name.\nUsage: dart tool/raihan_cli.dart <feature_name> [optional_parent_path]');
    return;
  }

  final feature = args[0];
  final pascalFeature = toPascalCase(feature);

  // Step 1: Load or ask path config
  final pathConfig = _readConfig();
  String? pathType = pathConfig['pathType'];
  String? customParent = pathConfig['customPath'];

  if (pathType == null) {
    print('\n📁 Choose path type:');
    print('1. Feature-based path (lib/src/features/$feature)');
    print('2. Custom path (lib/<optional_parent_path>/$feature)');
    stdout.write('Enter your choice (1 or 2): ');
    pathType = stdin.readLineSync()?.trim();

    if (pathType == '2') {
      stdout.write('📁 Enter custom parent path (Write . for lib/$feature): ');
      customParent = stdin.readLineSync()?.trim() ?? '';
    }

    try {
      _saveConfig({
        ...pathConfig,
        'pathType': pathType ?? '', // just in case
        'customPath': (customParent ?? '').toString(),
      });
    } catch (e) {
      print('❌ Failed to save path configuration: $e');
      return;
    }
  }

  String basePath;
  if (pathType == '1') {
    basePath = 'lib/src/features/$feature';
  } else if (pathType == '2') {
    basePath = (customParent == '.' || (customParent?.isEmpty ?? true))
        ? 'lib/$feature'
        : 'lib/$customParent/$feature';
  } else {
    print('❌ Invalid path choice. Aborting.');
    return;
  }

  // Step 2: Load or ask architecture
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

  // ----- Step 3: Reset and create folders
  // final featureDir = Directory(basePath);
  // if (featureDir.existsSync()) {
  //   print('♻️ Resetting "$feature" folder...');
  //   featureDir.deleteSync(recursive: true);
  // }
  // featureDir.createSync(recursive: true);

  //---- Step 3: folders already exists

  final featureDir = Directory(basePath);
  bool createdAnything = false;

  try {
    if (!featureDir.existsSync()) {
      featureDir.createSync(recursive: true);
      print('♻️ Created folder "$basePath"');
      createdAnything = true;
    } else {
      print('♻️ Folder "$basePath" already exists');
    }
  } catch (e) {
    print('❌ Failed to create folder "$basePath": $e');
    return;
  }

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

  // Step 4: Create files
  if (architecture == 'mvc') {
    createdAnything = createFile('$basePath/controllers/${feature}_controller.dart', '// Controller for $feature (MVC)\n') || createdAnything;
  } else if (architecture == 'mvvm') {
    createdAnything = createFile('$basePath/view_model/${feature}_view_model.dart', '// ViewModel for $feature (MVVM)\n') || createdAnything;
    createdAnything = createFile('$basePath/repository/${feature}_repository.dart', '''
abstract class ${pascalFeature}Repository {
  // Define your abstract methods here
}
''') || createdAnything;
    createdAnything = createFile('$basePath/repository/${feature}_repository_impl.dart', '''
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

  if (createdAnything) {
    print('\n🚀 "$feature" ($architecture) structure created at "$basePath"!');
  } else {
    print('\nℹ️ "$feature" ($architecture) structure already exists at "$basePath". No new files or folders created.');
  }
}

// bool _createFile(String path, String content) {
//   final file = File(path);
//   if (!file.existsSync()) {
//     file.writeAsStringSync(content);
//     print('✅  Created file: $path');
//     return true;
//   } else {
//     print('⚠️ File already exists: $path');
//     return false;
//   }
// }

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

String toPascalCase(String text) {
  return text
      .split('_')
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join();
}

// Reads all config as key-value map
Map<String, String> _readConfig() {
  final configFile = File(configFilePath);
  if (!configFile.existsSync()) {
   // print('⚠️ Config file not found at $configFilePath. Using empty config.');
    return {};
  }
  try {
    final lines = configFile.readAsLinesSync();
    return {
      for (var line in lines)
        if (line.contains('='))
          line.split('=').first.trim(): line.split('=').last.trim()
    };
  } catch (e) {
    print('❌ Failed to read config file $configFilePath: $e');
    return {};
  }
}

// Overwrites existing config file with updated key-value map
void _saveConfig(Map<String, String> config) {
  final configFile = File(configFilePath);
  final toolDir = Directory('tool');

  try {
    // Create tool directory if it doesn't exist
    if (!toolDir.existsSync()) {
      toolDir.createSync(recursive: true);
      print('📁 Created tool directory for configuration');
    }

    final buffer = StringBuffer();
    config.forEach((key, value) {
      buffer.writeln('$key=$value');
    });
    configFile.writeAsStringSync(buffer.toString());
    //print('✅ Saved configuration to $configFilePath');
  } catch (e) {
    throw Exception('Failed to save config to $configFilePath: $e');
  }
}



// --------------------->> dart tool/raihan_cli.dart product
// --------------------->> del tool\.cli_architecture_config
// --------------------->> dart pub global activate raihan_cli
// --------------------->> raihan_cli <feature_name> [optional_parent_path]
// --------------------->> dart pub global deactivate raihan_cli
// --------------------->> which raihan_cli  # (macOS/Linux)
// --------------------->> where raihan_cli  # (Windows)
// --------------------->> dart pub global activate --source git https://github.com/raihansikdar/raihan_cli.git