# 📦 Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

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
