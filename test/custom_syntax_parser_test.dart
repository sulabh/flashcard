import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_app/core/utils/custom_syntax_parser.dart';

void main() {
  group('CustomSyntaxParser Tests', () {
    test('should parse ruby syntax correctly', () {
      const input = '_{ 漢字 }_ (_ かんじ )_';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('<ruby>漢字<rt>かんじ</rt></ruby>'));
    });

    test('should parse ruby syntax without spaces correctly', () {
      const input = '_{漢字}_(_かんじ)_';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('<ruby>漢字<rt>かんじ</rt></ruby>'));
    });

    test('should parse fraction syntax correctly', () {
      const input = '|< 1 / 2 >|';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('<fraction num="1" den="2"></fraction>'));
    });

    test('should parse fraction syntax without spaces correctly', () {
      const input = '|<1/2>|';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('<fraction num="1" den="2"></fraction>'));
    });

    test('should parse newlines correctly', () {
      const input = 'Line 1\\nLine 2';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('Line 1<br>Line 2'));
    });

    test('should handle mixed content correctly', () {
      const input = '_{半分}_(_はんぶん)_ is |<1/2>|.\\nDone!';
      final output = CustomSyntaxParser.parse(input);
      expect(output, contains('<ruby>半分<rt>はんぶん</rt></ruby> is <fraction num="1" den="2"></fraction>.<br>Done!'));
    });
  });
}
