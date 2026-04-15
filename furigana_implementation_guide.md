# 🇯🇵 Custom Syntax & Furigana Implementation Guide

This document explains the **Custom Syntax** requirements provided by the client for Japanese Furigana and Mathematical Fractions. It outlines the technical requirements and the planned implementation strategy for the RubyStudy app.

---

## 1. What is Furigana?

**Furigana** (also called **Ruby Text**) is a Japanese reading aid. It consists of small characters placed above Kanji characters to indicate their pronunciation.

### Client's Visual Goal
The app must support vertical stacking where reading annotations appear above the base text, and mathematical fractions are rendered correctly.

---

## 2. The Custom Syntax (Non-HTML)

The client has defined a specific set of delimiters to be used in the flashcard data instead of standard HTML tags.

| Feature | Start Delimiter | End Delimiter | Context |
| :--- | :--- | :--- | :--- |
| **Ruby Base (Kanji)** | `_{` | `}_` | The main text being annotated |
| **Ruby Text (Reading)** | `_(` | `)_` | The small text above the base |
| **Fractions (Numerator)** | `|<` | `/` | The top part of the fraction |
| **Fractions (Denominator)**| `/` | `>|` | The bottom part of the fraction |
| **Line Break** | `\n` | - | Forces a new line |

### Examples in Data
- **Furigana:** `_{漢字}_(_かんじ)_`
- **Fraction:** `|<1/2>|`
- **Mixed:** `_{半分}_(_はんぶん)_ is |<1/2>| \n Done!`

---

## 3. Technical Challenge

Since this is not standard HTML, the `flutter_html` package will not recognize these symbols. We must implement a custom parser to handle this "Client Markdown" before rendering.

**Problems to solve:**
- **Parsing:** Accurately identifying the start and end of these custom tags without breaking other characters.
- **Conversion:** Converting these tags into a format Flutter can render (either standard HTML `<ruby>` tags or custom widgets).
- **Line Breaks:** Ensuring `\n` works correctly inside the study UI.

---

## 4. Implementation Plan

Our strategy involves a **Preprocessing Layer** followed by **Custom Rendering**.

### Step 1: The Preprocessor (Regex Parser)
We will create a helper utility that uses Regular Expressions to transform the client's custom syntax into standard HTML or a structured model.

**Sample Logic:**
- Search for `_{ (.*?) }_ (_ (.*?) )_` and convert it to `<ruby>$1<rt>$2</rt></ruby>`.
- Search for `|< (.*?) / (.*?) >|` and convert it to a custom `<fraction>` tag.

### Step 2: Custom HTML Extensions
We will extend `flutter_html` with two main extensions:
1.  **Ruby Extension:** Handles the standard `<ruby>` layout (using the `ruby_text` package).
2.  **Fraction Extension:** A custom widget that renders a numerator and denominator with a horizontal line between them.

### Step 3: Update Main Logic
We will wrap the `card.frontHtml` and `card.backHtml` calls with our preprocessor before passing the result to the UI.

---

## 5. Implementation Preview (Sample Preprocessor)

```dart
String preprocessCustomSyntax(String input) {
  var result = input;
  
  // Convert Furigana: _{base}_(_ruby)_ -> <ruby>base<rt>ruby</rt></ruby>
  result = result.replaceAllMapped(
    RegExp(r'_{ (.*?) }_ \(_ (.*?) \)_', dotAll: true), 
    (m) => '<ruby>${m[1]}<rt>${m[2]}</rt></ruby>'
  );

  // Convert Fractions: |<num/den>| -> <div class="fraction">...</div>
  result = result.replaceAllMapped(
    RegExp(r'|< (.*?) / (.*?) >|', dotAll: true), 
    (m) => '<fraction numerator="${m[1]}" denominator="${m[2]}"></fraction>'
  );

  // Convert Newlines
  result = result.replaceAll('\\n', '<br>');
  
  return result;
}
```

---

## 6. How to Test
A developer can test this by adding the following string to a card:
`"Solve: _{半分}_(_はんぶん)_ of |<1/2>|"`

**Expected Result:**
1. **半分** has **はんぶん** above it.
2. **1/2** is rendered as a math fraction.
