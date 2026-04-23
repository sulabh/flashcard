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
- **Data Portability & Sync**: Full CSV Import/Export system. Supports **ID Overwrite** logic: edit existing cards in Excel/Google Sheets and sync them back seamlessly.
- **Flexible Filters**: Study entire subjects or grades at once with the new **"All" selection** option for Categories and Units.
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
- `id`: Unique integer key (enables overwrite/sync).
- `subject`: Top-level subject (e.g., "Kanji").
- `category`: Middle filter (e.g., "Grade 1").
- `unit`: Specific unit/lesson (e.g., "Unit 1").
- `title`: Card title or hint.
- `problem`: The card question (HTML/Tags supported).
- `answer`: The card answer.

---

## 🌐 Adding a New Language

The app uses Flutter's built-in `flutter_localizations` system with `.arb` files. Currently supported: **English (`en`)** and **Japanese (`ja`)**.

On first launch, the app automatically detects the device's system language. If supported, it uses that language; otherwise it falls back to English. Users can also switch languages manually from the Home screen.

### Step-by-step: Adding a new language (e.g. Korean `ko`)

#### 1. Create the ARB translation file

Copy the English template and translate all values:

```bash
cp lib/l10n/app_en.arb lib/l10n/app_ko.arb
```

Edit `lib/l10n/app_ko.arb` — change the locale tag and translate every string value:

```json
{
  "@@locale": "ko",
  "appTitle": "플래시카드 앱",
  "startPractice": "연습 시작",
  ...
}
```

> **Important**: Keep all keys identical to `app_en.arb`. Only translate the *values*. Do not rename or remove any keys. Placeholders like `{count}` and `{mastered}` must remain unchanged.

#### 2. Register the locale in the auto-detection list

Open `lib/data/providers/settings_provider.dart` and add the new locale code to `_supportedLocales`:

```diff
- static const _supportedLocales = ['en', 'ja'];
+ static const _supportedLocales = ['en', 'ja', 'ko'];
```

This ensures the app will auto-detect Korean if the device is set to Korean.

#### 3. Regenerate the localization code

Run the Flutter localization generator:

```bash
flutter gen-l10n
```

This reads all `app_*.arb` files in `lib/l10n/` and generates the Dart classes in `lib/l10n/app_localizations.dart`. The new locale is automatically picked up — no manual registration in `main.dart` is needed.

#### 4. (Optional) Add the language to the in-app language switcher

If you want users to be able to manually select the new language, update the language switcher in `lib/presentation/screens/home_screen.dart`:

```dart
// In the PopupMenuButton itemBuilder, add:
PopupMenuItem(
  value: 'ko',
  child: Row(
    children: [
      Icon(
        currentLocale == 'ko' ? Icons.check_circle : Icons.circle_outlined,
        size: 18,
        color: currentLocale == 'ko' ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      const SizedBox(width: 10),
      const Text('한국어'),
    ],
  ),
),
```

#### 5. Test

```bash
flutter run --flavor paid -t lib/main_paid.dart
```

Switch the language to the new one from the Home screen switcher. Verify all screens render correctly with the new translations.

### Architecture Summary

| File | Purpose |
|---|---|
| `lib/l10n/app_en.arb` | English translations (template) |
| `lib/l10n/app_ja.arb` | Japanese translations |
| `lib/l10n/app_*.arb` | Any additional language — just add and run `gen-l10n` |
| `l10n.yaml` | Config: tells Flutter where to find ARB files |
| `lib/data/providers/settings_provider.dart` | `_supportedLocales` list for auto-detection |
| `lib/presentation/screens/home_screen.dart` | Manual language switcher UI |

### Locale Resolution Order

1. **Saved preference** → If the user previously chose a language, use that.
2. **Device system language** → If no saved preference, detect the phone's language. If it's in `_supportedLocales`, use it.
3. **Fallback** → English (`en`).

---

## 📄 Maintenance
- **Content Management**: Users should follow the **Export → Edit → Clear → Import** cycle for bulk data changes.
- **Syncing Changes**: When importing a CSV, if a row contains an existing ID, the app will update the local record. This allows you to fix typos or update card logic without losing study stats.
- **Card Maintenance**: Use the dedicated Card Maintenance screen from the Home menu to import/export CSV files. On Android, files are saved directly to the system `Downloads` folder.

---
© 2026 Flashcard App Development Team.
