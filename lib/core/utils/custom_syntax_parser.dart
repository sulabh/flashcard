class CustomSyntaxParser {
  /// Parses the client's custom syntax into standard HTML tags that flutter_html can handle.
  /// 
  /// 1. Furigana: _{ base }_(_ ruby )_ -> <ruby>base<rt>ruby</rt></ruby>
  /// 2. Fractions: |< num / den >| -> <fraction num="num" den="den"></fraction>
  /// 3. Newlines: \n -> <br>
  static String parse(String input) {
    if (input.isEmpty) return input;

    var result = input;

    // 1. Parse Furigana/Ruby syntax
    // Pattern: _{base}_(_ruby)_
    // Note: Allowing optional whitespace within the delimiters for robustness.
    result = result.replaceAllMapped(
      RegExp(r'_\{[ \t\n]*(.*?)[ \t\n]*\}_[ \t\n]*\(_[ \t\n]*(.*?)[ \t\n]*\)_', dotAll: true),
      (match) {
        final base = match[1];
        final ruby = match[2];
        return '<ruby>$base<rt>$ruby</rt></ruby>';
      },
    );

    // 2. Parse Fraction syntax
    // Pattern: |<num/den>|
    result = result.replaceAllMapped(
      RegExp(r'\|<[ \t\n]*(.*?)[ \t\n]*/[ \t\n]*(.*?)[ \t\n]*>\|', dotAll: true),
      (match) {
        final num = match[1];
        final den = match[2];
        return '<fraction num="$num" den="$den"></fraction>';
      },
    );

    // 3. Parse Newlines
    // Replaces literal \n with <br>
    result = result.replaceAll('\\n', '<br>');

    return result;
  }
}
