# 🎴 Flashcard App (MVP)

A standalone, offline-first professional flashcard application built with Flutter. Designed for multilingual subject mastery with native support for Japanese Furigana (Ruby text) and mathematical fractions.

---

## 🌟 Key Features
- **Dynamic Database Architecture**: No hardcoded subjects. The app automatically builds its navigation hierarchy from the SQLite database.
- **Dual Study Modes**:
  - **Classic Mode**: Mental recall with Anki-style self-evaluation.
  - **MCQ Mode**: Active recall via Multiple Choice Questions.
- **Rich Content Rendering**: Support for Furigana `_{漢字}_(_かんじ_)` and Fractions `|1/2|` globally.
- **Bi-Flavor Strategy**:
  - `free`: Integrated with AdMob banner ads.
  - `paid`: Clean, ad-free experience.
- **Data Portability**: Full CSV Import/Export system for easy content management.
- **Localized UI**: Complete English and Japanese bilingual support.

---

## 🛠 Tech Stack
- **Framework**: [Flutter](https://flutter.dev) (v3.10+)
- **State Management**: [Riverpod](https://riverpod.dev) (Hooks & FutureProviders)
- **Database**: `sqflite` (Local SQLite)
- **Navigation**: `go_router`
- **UI Architecture**: Model-Provider-View (MVVM inspired)
- **Styling**: Custom Material 3 dynamic theme with dark/light support.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode for mobile builds

### Local Development
Clone the repo and install dependencies:
```bash
flutter pub get
```

### Running the App
The project uses a flavor-based entry system. You **must** specify the flavor and target for it to run correctly.

**Run Free Version:**
```bash
flutter run --flavor free -t lib/main_free.dart
```

**Run Paid Version:**
```bash
flutter run --flavor paid -t lib/main_paid.dart
```

---

## 📂 Project Structure
```text
lib/
├── core/               # Utilities, theme, and common components
├── data/               # Models, SQLite helpers, and Riverpod providers
├── l10n/               # ARB translation files (EN/JA)
├── presentation/       # UI Screens and custom widgets
│   ├── screens/        # Full-page screen widgets
│   └── widgets/        # Reusable UI components
├── main_free.dart      # Entry point for Free flavor
└── main_paid.dart      # Entry point for Paid flavor
```

---

## 🏗 Build & Release

### Android APK
```bash
flutter build apk --flavor free -t lib/main_free.dart
```

### Web Export
```bash
flutter build web --no-wasm-dry-run
```

### App Store / Play Store
Generate a signed App Bundle (AAB):
```bash
flutter build appbundle --flavor free -t lib/main_free.dart
```
*Note: Ensure `android/key.properties` and your release keystore are configured.*

---

## 📊 Database Schema
The app uses a single main table `flashcards`:
- `category`: Subject (e.g., "Kanji")
- `ageGroup`: Middle filter (e.g., 5, 6)
- `unit`: Specific unit/lesson (e.g., "first_half")
- `frontHtml`: The card question (HTML/Tags supported)
- `backHtml`: The card answer

---

## 📄 Maintenance
- **Updating Localization**: Add new strings to `lib/l10n/app_en.arb` and `app_ja.arb`.
- **Content Management**: Users should follow the **Export -> Edit -> Clear -> Import** cycle for bulk data changes.

---
© 2026 Flashcard App Development Team.
