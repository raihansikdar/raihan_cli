# 📦 Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

---

## [2.1.0] - 2025-11-15

## ✨ New Feature — Clean Architecture Support
- 🏛 **Clean Architecture Added**
    - CLI now supports full **Clean Architecture** scaffolding.
    - Generates layered structure:
        - `domain` → entities, repositories, use cases
        - `data` → models, repository implementations, data sources
        - `presentation` → UI, controllers/state management
    - Architecture adapts automatically based on selected **state management** (GetX, Provider, BLoC, Riverpod).

- 📁 **Clean Architecture + State Management Integration**
    - **BLoC** → auto-generates bloc, event, state under `presentation/`.
    - **Riverpod** → generates notifier + provider following domain-driven design.
    - **GetX** → controller generation with injected use cases.
    - **Provider** → ChangeNotifier generated using domain layer use cases.

- 🛠 **CLI Updates**
    - Added **Clean Architecture** as a new selectable architecture option.
    - Automatically creates layer-specific folders:
        - `domain/usecases/`
        - `domain/repositories/`
        - `data/datasources/`
        - `data/repositories/`
        - `presentation/screens/`
        - `presentation/controllers/`
    - Enhanced validation for feature names and duplicate layer checks.

## 🛠️ Code Quality
- Modularized architecture generation logic.
- Separated MVC, MVVM, and Clean Architecture generators.
- Reduced duplicate file creation by implementing shared utilities.


## [2.0.0] - 2025-10-24

## ✨ Enhancements
- 🛠 **State Management Support**
  - Added **GetX, Provider, BLoC, and Riverpod** options for feature scaffolding.
  - CLI now prompts for state management on the first run and remembers the choice.

- 📁 **Improved Folder Structure Handling**
  - Folder structures adapt automatically based on **architecture + state management** combination.
  - Automatic creation of **repository folders and files** for MVVM features.
  - **BLoC scaffolding** includes `<feature>_bloc.dart`, `<feature>_event.dart`, and `<feature>_state.dart`.
  - **Riverpod scaffolding** now splits provider logic into **notifier + provider files** for clean separation.

- 💡 **Better CLI UX**
  - Refined prompts for **path type, state management, and architecture**.
  - Clearer print statements for created folders and files.
  - Enhanced handling of **existing folders and files** with appropriate warnings.

- ⚡ **Configuration Improvements**
  - Saves **state management choice** in the config file.
  - Handles **custom paths** more robustly.
  - Reduced redundant config file reads.

## 🛠️ Code Quality
- Refactored feature creation logic to handle all combinations of **MVC/MVVM + GetX/Provider/BLoC/Riverpod**.
- Improved maintainability of **file/folder creation and prompts**.
- Consolidated exception handling and validation checks.
---

## [1.1.0] - 2025-09-25

### ✨ Enhancements
- 🧹 **Simplified user prompts**
  - Path type input now strictly accepts **`1` or `2`**, ensuring clearer validation and reducing accidental mis-entries.
  - Architecture selection refined to immediately validate input.

- ⚡ **Cleaner configuration handling**
  - Removed unnecessary re-reads of the config file after saving.
  - Streamlined `_saveConfig` and `_readConfig` for better readability.

- 💡 **Improved CLI UX**
  - More consistent print statements and comments.
  - Reduced redundant logic while preserving all existing features.

### 🛠️ Code Quality
- Refactored code blocks for improved maintainability and readability.
- Consolidated repetitive checks and exception handling.

---

## [1.0.0] - 2025-09-23

🎉 Initial release of `raihan_cli`!

### ✨ Features
- 🚀 Generate Flutter feature folders and files based on:
  - MVC architecture
  - MVVM architecture
- 📁 Supports two path types:
  - Feature-based path: `lib/src/features/<feature_name>`
  - Custom path: `lib/<custom_path>/<feature_name>`
- 🧠 Smart config saving for:
  - Preferred path type
  - Preferred architecture
- 🗑️ Remove existing feature folders with confirmation prompt
- 🧱 Auto-generate the following:
  - Controllers / ViewModels
  - Repository interfaces and implementations (for MVVM)
  - Models
  - Screens and widget directories

### 📂 Structure Examples
- `lib/src/features/<feature_name>/` (default)
- `lib/<custom_path>/<feature_name>/` (custom path)

---

