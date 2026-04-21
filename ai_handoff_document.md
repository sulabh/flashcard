# AI Agent Handoff Context Document

**To the AI Agent / Developer assuming this workspace:**
You are inheriting the **RubyStudy Flashcard Application** (Internal codename: `iplus`). This is a production-grade, offline-first Flutter application designed for robust studying of subjects via flashcards and multiple-choice questions (MCQs).

This document serves as your "memory transplant." Read it carefully to understand the exact paradigms, constraints, and custom engineering decisions used to build this architecture so that you do not break the application while adding new features.

---

## 1. Initial Requirements (Phase 1 MVP)

This app was built to satisfy the following MVP constraints:
- **Local DB**: Standalone offline database (SQLite).
- **Learning Mechanics**: Flashcards, MCQs, Shuffling, Timers (5m, 10m, 30m), and persistent tracking of Correct/Incorrect answers (Mastery %).
- **Data Management**: Bulk Import/Clear via a standalone CSV engine pointing to `assets/initial_data.csv`.
- **UI/UX**: Custom HTML parsing for Japanese Ruby Text (Furigana) and dynamic grid categorization based on database contents.
- **Audio (TTS)**: OS-Standard Text-to-Speech implementation that reads Japanese and English correctly.
- **Monetization**: A Free build (capped access + AdMob) and a Paid build (unrestricted).

---

## 2. Core Architectural Decisions

### Data & State
- **Riverpod** is the state management solution. Use `FutureProvider` for DB reads and `StateProvider` for UI selections (e.g., `selectedSubjectProvider`).
- **SQLite (`sqflite`)**: The entire source of truth. We use `database_helper.dart` as a singleton. 
- **CRITICAL RULE**: The application generates its internal taxonomy (Categories -> Age Groups -> Units) **dynamically** via `SELECT DISTINCT` queries. ***Do not hardcode subjects into the UI.***

### CSV Initialization Pipeline
- On the very first boot, if `flashcards.db` does not exist in the device storage, the app parses `assets/initial_data.csv` and auto-populates the SQLite database.
- **Data Cleanup Cycle**: If a user wants to edit/delete cards, the system workflow is: Export local DB to CSV -> Edit on PC -> Clear Database via Settings -> Re-import CSV via Settings.

---

## 3. Custom Syntax Engines (Do Not Break These)

Because standard Flutter Text widgets do not natively support Furigana (interlineal ruby text) or Mathematical fractions, we implemented a custom Regex parsing engine using `flutter_html` (`lib/core/utils/custom_syntax_parser.dart`).

**Syntax 1: Furigana (Ruby)**
- Format: `_{kanji}_(_hiragana_)`
- Example: `_{漢}_(_かん_)_{字}_(_じ_)`
- *How it works*: The Regex strictly scans for the underscores and parentheses and dynamically injects HTML `<ruby>` tags before rendering.

**Syntax 2: Mathematical Fractions**
- Format: `|numerator/denominator|`
- Example: `|15/34|`
- *How it works*: Transforms the match into a beautiful stack using `<sup>` and `<sub>` HTML.

---

5. **Smart Script Detection**: `TtsService` uses regex `r'[\u3040-\u30FF\u4E00-\u9FAF]'` to detect Japanese inline. If found, it **forces** the TTS engine to `ja-JP` regardless of the app's structural English locale.
6. **Lifecycle Safety**: `TtsService` is cached in `initState` of `StudyScreen` to allow safe `stop()` calls during `dispose()` without triggering "ref already disposed" errors.
7. **OS Support**: For Samsung devices, users may need to manually download Japanese voice data in System Settings (General Management > TTS).

---

## 5. Monetization & Flavor Bi-furcation

We use Dart's native environmental flavoring (`--flavor free` vs `--flavor paid`). Setups are in `main_free.dart` and `main.dart`.

**The Locking Mechanic (Slot-Based Cap):**
Because subjects are dynamic, we could not hardcode "Premium" subjects. Therefore, the `free` flavor limits access using the **Array Index**. 
- Free users have 100% access to subjects at `index 0` and `index 1` of the dynamic category list.
- If `FlavorConfig.instance.flavor == AppFlavor.free` and `index >= 2`, the UI lowers the card opacity, renders a padlock, intercepts the `onTap` gesture to show a Premium Dialog, AND triggers a global GoRouter `redirect` to bounce deep-link hacks.

**Banners**: The `AdBannerWidget` handles AdMob gracefully and returns a `SizedBox.shrink()` when evaluated in the `paid` flavor environment.

---

## 6. UI/UX Rules
1. **No Rubber-Banding Scroll**: Stakeholders requested a rigid, non-bouncing UI. `ClampingScrollPhysics` is mandated across all `SingleChildScrollView` and `GridView` widgets. 
2. **Scrollbars**: Permanent `thumbVisibility: true` `Scrollbar` widgets wrap the main content columns. **WARNING**: Do not nest `Scrollbar` widgets inside inner views where `ScrollPosition` cannot attach (this caused crashes previously).
3. **Bilingual Requirement**: All text strings are hard-bound to `app_en.arb` and `app_ja.arb`. Never use inline strings for user-facing text.

## 7. Known Gotchas & Recent Fixes
- **Database Race Condition**: On cold starts, multiple providers trigger DB init. We use a `Future? _initFuture` cache in `DatabaseHelper` to ensure only ONE setup process runs. Do not remove this cache.
- **CSV Header Skipping**: The `CsvHelper.importFromCsv` always skips the first line. This allows users to use headers in any language (Japanese/English) without them being imported as "ghost" subjects.
- **Defunct Element Fix**: Never call `ref.read` directly inside `dispose()` in `StudyScreen`. Always cache the required service in `initState`.

## Recommended Next Steps (Phase 2 Prep)
If instructed to proceed to Phase 2:
- You will need to upgrade `TtsService` to reach out to an external AI voice API (like OpenAI TTS or ElevenLabs) while maintaining the local `flutter_tts` as an offline fallback.
- You may need to explore compiling native iOS hooks and provisioning profiles to fulfill the ultimate deployment pipeline.

*Signed, Antigravity | The Previous LLM Session*
