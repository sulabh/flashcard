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
    // We handle several variants found in client CSVs:
    
    // Variant A: _{BASE}__(RUBY)_
    result = result.replaceAllMapped(
      RegExp(r'_\{[ \t\n]*(.+?)[ \t\n]*\}__[ \t\n]*[\(（][ \t\n]*(.+?)[ \t\n]*[\)）]_', dotAll: true),
      (match) => '<ruby>${match[1]!.trim()}<rt>${match[2]!.trim()}</rt></ruby>',
    );

    // Variant B: _{BASE}_(_RUBY_) or _{BASE}_(RUBY)
    result = result.replaceAllMapped(
      RegExp(r'_\{[ \t\n]*(.+?)[ \t\n]*\}_[ \t\n]*[\(（][ \t\n]*_?[ \t\n]*(.+?)[ \t\n]*_?[ \t\n]*[\)）]', dotAll: true),
      (match) => '<ruby>${match[1]!.trim()}<rt>${match[2]!.trim()}</rt></ruby>',
    );

    // Variant C: BASE_(RUBY)_
    result = result.replaceAllMapped(
      RegExp(r'(\S)_[\(（][ \t\n]*(.+?)[ \t\n]*[\)）]_', dotAll: true),
      (match) => '<ruby>${match[1]!.trim()}<rt>${match[2]!.trim()}</rt></ruby>',
    );
 
    // 2. Parse Fraction syntax
    // Pattern: |num/den| or |<num/den>|
    result = result.replaceAllMapped(
      RegExp(r'\|[ \t\n]*(?:<[ \t\n]*)?(.+?)[ \t\n]*/[ \t\n]*(.+?)[ \t\n]*(?:>[ \t\n]*)?\|', dotAll: true),
      (match) {
        final num = match[1]!.trim();
        final den = match[2]!.trim();
        return '<fraction num="$num" den="$den"></fraction>';
      },
    );

    // 3. Parse Newlines
    // Replaces literal \n with <br>
    result = result.replaceAll('\\n', '<br>');

    return result;
  }
}
