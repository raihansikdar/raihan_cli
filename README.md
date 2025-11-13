# 🚀 raihan_cli – Flutter Feature Scaffolding CLI Tool

`raihan_cli` is a Dart-based command-line tool designed to **automate feature creation and deletion** in Flutter projects using the **MVC** or **MVVM** architectural patterns and **Clean Architecture**  with **GetX**, **Provider**, **Riverpod** and **BLoC** state management. It helps developers maintain a clean and consistent project structure while saving time on repetitive boilerplate setup.

## 📦 Installation

To install globally from the Pub.dev package:
```
dart pub global activate raihan_cli
```

Alternatively, to install from the Git repository:

```bash
dart pub global activate --source git https://github.com/raihansikdar/raihan_cli.git
```

## 📁 What It Does

1. ✅ Scaffolds folders and files for new features (MVC or MVVM)

2. 🛠️ Supports GetX, Provider, Riverpod and BLoC state management

3. 🗑️ Removes entire feature folders safely

4. 🔧 Saves architecture and path preferences to reduce prompts

5. 🛠️ Supports custom folder paths (e.g., lib/core/feature_name) or default feature-based structure (lib/src/features/feature_name)

## 🧪 Basic Usage
### ▶️ Create a New Feature
```
raihan_cli <feature_name>

```
> **Example:** raihan_cli product

You’ll be prompted to choose:

### 1️⃣ Folder Structure Type:

1: Default (lib/src/features/<feature_name>)

2: Custom (lib/<custom_path>/<feature_name>)


> **Note:** You must configure the path type on the first run. The package will remember your choice.

### 2️⃣ State Management:

1. getx

2. provider

3. riverpod

4. bloc

5. others

> **Note:** You must configure the state management on the first run. The package will remember your choice.

### 3️⃣ Architecture type:

1. mvc

2. mvvm


> **Note:** You must configure Architecture on the first run. The tool will remember your choice.


### Then your feature folder will create successfully.


### If folder is not showing then collapse your parent folder like this
![raihan_cli](https://github.com/raihansikdar/raihan_cli/blob/main/assets/raihan_cli_feature.gif?raw=true)

### 🗑️ Remove an Existing Feature
```
raihan_cli remove <feature_name>
```
> **Example:** raihan_cli remove product <br>
> **Note:** If folder is still showing then collapse your parent folder.

This confirms and deletes the feature directory based on your saved configuration..



## 🔄 Reset Configuration (if did mistake)

```
# Windows
del tool\.cli_architecture_config

# macOS/Linux
rm tool/.cli_architecture_config

```

## ✅ Deactivating the CLI Package:
```
dart pub global deactivate raihan_cli

```




## 💡 Architecture + State Management Examples


## 📁 MVC Folder Structure

### 📁 MVC + GetX

```
lib/src/features/<feature_name>/    # if custom path is "features"
├── controllers/
│   └── <feature_name>_controller.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```

### 📁 MVC + Provider

```
lib/src/features/<feature_name>/      # if custom path is "features"
├── provider/
│   └── <feature_name>_provider.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```


### 📁 MVC + Riverpod

```
lib/src/features/<feature_name>/      
├── provider/
│   ├── <feature_name>_notifier.dart      # StateNotifier / AsyncNotifier class
│   └── <feature_name>_provider.dart      # Riverpod provider exposing the notifier
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/
    
```

### 📁 MVC + BLoC

```
lib/src/features/<feature_name>/       # if custom path is "features"
├── bloc/
│   ├── <feature_name>_bloc.dart
│   ├── <feature_name>_event.dart
│   └── <feature_name>_state.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```

## 📁 MVVM Folder Structure

### 📁 MVVM + GetX
```
lib/features/<feature_name>/     # if custom path is "features"
├── model/
│   └── <feature_name>_model.dart
├── view_model/
│   └── <feature_name>_view_model.dart
├── repository/
│   ├── <feature_name>_repository.dart
│   └── <feature_name>_repository_impl.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```


### 📁 MVVM + Provider
```
lib/features/<feature_name>/       # if custom path is "features"
├── view_model_provider/ 
│   └── <feature_name>_view_model_provider.dart
├── repository/
│   ├── <feature_name>_repository.dart
│   └── <feature_name>_repository_impl.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```

### 📁 MVVM + Riverpod

```
lib/features/<feature_name>/           
├── view_model_provider/
│   ├── <feature_name>_notifier.dart      # StateNotifier / AsyncNotifier class
│   └── <feature_name>_provider.dart      # Riverpod provider exposing the notifier
├── repository/
│   ├── <feature_name>_repository.dart
│   └── <feature_name>_repository_impl.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```


### 📁 MVVM + BLoC
```
lib/features/<feature_name>/      # if custom path is "features"
├── bloc/
│   ├── <feature_name>_bloc.dart
│   ├── <feature_name>_event.dart
│   └── <feature_name>_state.dart
├── repository/
│   ├── <feature_name>_repository.dart
│   └── <feature_name>_repository_impl.dart
├── model/
│   └── <feature_name>_model.dart
└── views/
    ├── screen/
    │   └── <feature_name>_screen.dart
    └── widget/

```




##  👨‍💻 Author
**Raihan Sikdar**

Website: [raihansikdar.com](https://raihansikdar.com)  
Email: raihansikdar10@gmail.com  
GitHub: [raihansikdar](https://github.com/raihansikdar)  
LinkedIn: [raihansikdar](https://www.linkedin.com/in/raihansikdar/)


## 📜 License
This package is licensed under the [MIT License](https://github.com/raihansikdar/raihan_cli/blob/main/LICENSE).
