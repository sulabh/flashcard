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
* **Session Shuffling**: Users can shuffle unanswered cards.
* **Custom Session Sizes**: Users can define batch sizes (10 to 40 cards) in persistent settings.
* **Session Timers**: Configurable timer (5, 10, or 30 mins) with auto-evaluation on expiry.
* **Subject-First Navigation**: The study setup flow now prioritizes Subject Selection followed by Age and Unit filters.
* **Global Scroll Physics Refined**: 
    * Completely disabled platform-specific "stretchy/bouncy" overscroll effects globally.
    * Enforced `ClampingScrollPhysics` and visible `Scrollbar` widgets across all scrollable screens (Study, Session, etc.) for a rigid, professional UI.
    * Fixed mobile browser viewport bouncing via `overscroll-behavior: none` in `web/index.html`.
* **Mobile Responsiveness**: Refactored Settings and Selection screens to use vertical/wrapping layouts, ensuring text is never garbled on narrow mobile devices.

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

---

## 🔲 Remaining Features & Requirement Gaps
Based on the original Phase 1 requirements, the following items are still pending or require alignment:

### 1. Audio Function (OS Standard TTS)
* **Status**: ❌ Missing (Mismatch with Requirement)
* **Gap**: The requirement specifies "incorporating OS standard TTS (text-to-speech)" for Plan A. This has not yet been implemented in the Study Screen.
* **Action Required**: Integrate `flutter_tts` to read card content aloud.

### 2. Flavor-Specific Logic (Content Locking)
* **Status**: 🔲 In Progress
* **Gap**: While AdMob is integrated into the `free` flavor, specific functional limits (e.g., locking units or capping session counts) are not yet enforced.
* **Action Required**: Implement logic to restrict certain subjects or features to the `paid` flavor only.

### 3. Documentation & Delivery Preparation
* **Status**: 🔲 Pending
* **Requirement**: "Simple documentation for maintenance and environment setup (a guide to enable smooth maintenance and building at your company)".
