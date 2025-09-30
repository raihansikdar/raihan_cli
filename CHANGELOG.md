# 📦 Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

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

## 🔮 Next Planned Features
- [ ] Clean architecture support
- [ ] Bloc/Cubit file generation
- [ ] Optional test file scaffolding
- [ ] Custom templates for files
