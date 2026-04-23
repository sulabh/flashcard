# Project To-Do List

## Completed ✅

- [x] **4. Summary Screen "Wow" Factor**
    - Add "Mastery Gained" visuals.
    - Add Confetti/Premium finishers.
- [x] **5. Global Stats Dashboard**
    - Create a comprehensive progress overview.
    - Total cards mastered vs. pending.
- [x] [HIGH PRIORITY] **6. Timer Functionality**
    - Add setting for Session Timer (5m, 10m, 30m, No Timer).
- [x] [HIGH PRIORITY] **7. Shuffle Unanswered Cards**
    - Add a Shuffle Button to skip a card without failing it, shuffling it back into the unanswered pool.
- [x] [HIGH PRIORITY] **8. Skip Card Logic**
    - Add Skip Button to delay answering. Skipped questions reappear at the end without the skip option.
- [x] [HIGH PRIORITY] **9. Custom Session Size**
    - Slider in settings: 10 (min) to 40 (max). Default: 20.
- [x] [HIGH PRIORITY] **10. End Quiz Button (Retry Phase)**
    - Allow user to end quiz during retry phase, marking remaining cards as wrong.
- [x] [HIGH PRIORITY] **11. Japanese Translation & Language Switcher**
    - Add language toggle (EN/JA) to top-right of Home Screen.
    - Translate all UI strings to Japanese across all screens (Home, Settings, Study, Summary, Selection, Subjects, Stats, Deck List).
    - Persist language preference via SharedPreferences.
- [x] **1. Flavor-Specific Logic (Free vs. Paid)**
    - Implement Ad-removal logic for `paid` flavor.
- [x] **2. AdMob Banner Implementation**
    - Place actual Banner unit placeholders in the `free` flavor UI.

- [x] [HIGH PRIORITY] **3. Furigana (Ruby Text) Support**
    - Implement custom HTML rendering for Kanji readings.
- [x] **12. CSV Data Management (Settings)**
    - Add button to download current questions as CSV.
    - Add button to clear database.
    - Add button to validate and import questions via CSV.
- [x] **13. Comprehensive Testing of Furigana & Custom Syntax**
    - Verify all edge cases for `_{base}_(_ruby)_` and `|<num/den>|`.
    - Resolved TTS multiple Kanji bugs.
- [x] **14. Audio (TTS) Support**
    - Smart speech synthesis for OS engines.
    - Furigana mapping to `ja-JP` dynamically based on Japanese characters.
    - Math minus signs support.
- [x] **15. Flavor Content Locking**
    - Free version limits access to the first 2 dynamically generated subjects.
    - Padlocks and route guards securely restrict premium content.
- [x] **16. Phase 1.6 Reliability & Sync**
    - [x] Migrate Flashcard IDs to Integers (DB v6).
    - [x] Implement "ID Overwrite" logic in CSV imports.
    - [x] Add "All" selection option for Categories and Units.
    - [x] Fix Android storage permissions and Downloads saving.
    - [x] Enforce double-quoting in CSV exports.
    - [x] Correct Japanese translation for "Incorrect".

## Remaining 🔲
*(All planned Phase 1 and 1.6 stability features are complete)*
