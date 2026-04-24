# 🚀 Project Status Report: RubyStudy Flashcards

This report details the technical implementation and feature completion status of the RubyStudy Flashcard Application.

---

## ✅ Completed Features

### 1. Robust Study & Progression Engine
* **Self-Evaluation System**: Implemented a binary "Correct/Incorrect" self-evaluation model for classic flashcards, streamlining the MVP experience.
* **MCQ Support**: 
    * Cards automatically adapt into Multiple Choice options.
    * **Rich Rendering**: MCQ options now support Furigana and Fractions using `AppFlashcardHtml`.
* **Manual Navigation**: Manual "Next Card" button on MCQ cards allows for review before proceeding.
* **Auto-Advance**: Classic cards automatically proceed to the next card after self-evaluation.
* **Session Shuffling & Sequencing**: 
    * **Dynamic Shuffle**: Integrated with global settings. If enabled, the session pool is randomized.
    * **Sequential Study**: If shuffle is disabled, the app prioritizes cards that have **not yet been attempted**, showing them in order (`id ASC`).
    * **Auto-Fallback**: If all cards in a section are attempted, it automatically shows the full sequential list again.
* **Custom Session Sizes**: Users can define batch sizes (10 to 40 cards) in persistent settings.
* **Session Timers**: Configurable timer (5, 10, or 30 mins) with auto-evaluation on expiry.
* **Subject-First Navigation**: The study setup flow now prioritizes Subject Selection followed by Age and Unit filters.
* **Global Scroll Physics Refined**: 
    * Completely disabled platform-specific "stretchy/bouncy" overscroll effects globally.
    * Enforced `ClampingScrollPhysics` and visible `Scrollbar` widgets across all scrollable screens (Study, Session, etc.) for a rigid, professional UI.
    * Fixed mobile browser viewport bouncing via `overscroll-behavior: none` in `web/index.html`.
* **Mobile Responsiveness**: Refactored Settings and Selection screens to use vertical/wrapping layouts, ensuring text is never garbled on narrow mobile devices.
* **Metadata Clarity**: Moved Subject/Grade/Unit metadata labels outside the flashcard component in `StudyScreen` to improve readability and prevent text overlap during animations.
* **Flexible Filtering**: Added the **"All" option** to Category and Unit selection lists. Users can now choose to study an entire Subject or Category at once, significantly increasing study flexibility.

### 2. Rich Content & Formatting
* **Furigana (Ruby Text)**: Custom syntax `_{base}_(_ruby_)` is fully supported across all cards and MCQ options.
* **Fraction Rendering**: Mathematical fractions `|num/den|` are rendered beautifully using custom HTML extensions.
* **Initial Database**: The app is pre-populated with **240 realistic questions** across 5 subjects (Kanji, Arithmetic, English, Vocabulary, General Knowledge).
* **CSV-Based Initialization**: The app builds its internal database from an `assets/initial_data.csv` on the first run, making content updates trivial.

### 3. Data Management & Logistics
* **Dual-Platform File Saving**: Custom `FileSaver` utility supports both Web downloads and Native shares.
* **Sample CSV Downloads**: Users can download the full 240-card master template directly from the Settings menu.
* **Dynamic Database Categorization**: 
    * Fully removed all hardcoded subjects/age groups/units from the codebase.
    * App taxonomy is now generated 100% dynamically from the local SQLite database.
    * Implemented stable, colorful grid repetition logic for unlimited dynamic categories.
* **CSV-Based Management & Deletion**: 
    * Fulfilled "deletion" requirement via unified CSV workflow (Export -> Edit in Excel -> Clear DB -> Re-import). 
    * **ID Overwrite Logic**: Implemented record synchronization (upsert) in CSV imports. If a row contains an existing ID, the app updates the record; otherwise, it inserts a new one.
    * **Strict Quoting**: Forced double-quoting on all exported fields to ensure 100% compatibility with legacy Excel, Google Sheets, and other spreadsheet software.
    * Database and UI now instantly reload upon import or clear operations, ensuring zero-latency data management.

### 4. Comprehensive Statistics & Analytics
* **Summary Screen**: Visual Confetti and detailed session read-outs (Accuracy, Cards Studied).
* **Global Stats Dashboard**: Real-time tracking of mastery progress per category.

### 5. Internationalization (i18n) & UI
* **Full Bilingual Support**: English (EN) and Japanese (JA) translations via `flutter_localizations`. All hardcoded strings removed.
* **Persistent Preference**: Language and theme selections are persisted via `SharedPreferences`.

### 6. Monetization & Flavors
* **AdMob Integration**: `BannerAd` placeholders are fully integrated and functional in the `free` flavor. Logic is centrally managed via `AdBannerWidget`.
* **Flavor Architecture**: Multi-flavor setup (`free`, `paid`) is complete with distinct entry points and configurations.

### 7. Phase 1.6: Reliability & Sync (Zero-Permission Storage)
* **Integer ID Migration**: Migrated flashcard IDs from UUID strings to `INTEGER PRIMARY KEY`. This resolves sorting issues and aligns with standard SQL optimization. (DB Version 6).
* **Zero-Permission Storage Strategy**: 
    * Completely removed `permission_handler` and intrusive Android storage permissions.
    * Implemented **Scoped Storage** and **System Save Dialogs** using `file_picker` 11.x.
    * Users now pick their own save location via a native system dialog, which grants the app explicit permission only for that specific file.
* **iOS File Sharing**: Enabled `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` in `Info.plist`, allowing app-internal files to be visible in the iOS 'Files' app.
* **Selection UI Polish**: Enabled vertical scrolling on the Category/Unit selection screen to support datasets with a large number of units, ensuring the 'Start Practice' button remains accessible at the bottom.
* **Synchronization Support**: The app now supports "editing in CSV" by using the ID as a unique key for overwriting existing records during import.
* **Localization Polish**: Corrected Japanese translation errors and added the `all` keyword for localized filtering.

---

## 🔲 Remaining Features & Requirement Gaps
Based on the original Phase 1 requirements, the following items are still pending or require alignment:

### 1. Audio Function (OS Standard TTS)
* **Status**: ✅ Completed
* **Implementation Details**: 
    * Integrated `flutter_tts` with a custom `TtsService`.
    * Implemented intelligent tag sanitization: Math symbols ('-') read natively, and complex Furigana/Fractions are parsed gracefully.
    * Added **Smart Localization**: TTS automatically switches to `ja-JP` when Japanese characters are detected, allowing bilingual cards to be read perfectly regardless of the app's UI language.
    * Feature accessible via a manual "Volume" button on cards and an "Auto-Play" toggle in Settings.

### 2. Flavor-Specific Logic (Content Locking)
* **Status**: ✅ Completed
* **Implementation Details**: 
    * Implemented a **Slot-Based Cap** for the `free` flavor. Free users are restricted to the first 2 subjects loaded dynamically from the database.
    * Added padlock overlays and lowered opacity for locked subjects.
    * Enforced a robust `GoRouter` redirect guard and UI interceptors protecting paid content.
    * Premium prompts are fully localized.

### 3. Documentation & Delivery Preparation
* **Status**: ✅ Completed
* **Deliverables**: 
    * **User Guide**: Multilingual HTML guide for non-technical team members and testers.
    * **Technical Manual**: Comprehensive developer handover guide (EN/JA) covering environment setup, build commands, and architecture.
    * **Exhaustive README**: Professional root documentation for immediate developer onboarding.
