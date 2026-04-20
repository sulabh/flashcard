import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../core/utils/custom_syntax_parser.dart';
import 'custom_html_extensions.dart';

class AppFlashcardHtml extends StatelessWidget {
  final String data;
  final Map<String, Style>? style;
  final TextAlign? textAlign;

  const AppFlashcardHtml({
    super.key,
    required this.data,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Process custom syntax (Furigana, Fractions, Newlines)
    final parsedData = CustomSyntaxParser.parse(data);

    // 2. Render with custom extensions
    return Html(
      data: parsedData,
      extensions: CustomHtmlExtensions.extensions,
      style: style ?? {
        "body": Style(
          textAlign: textAlign ?? TextAlign.center,
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          lineHeight: LineHeight.number(1.6),
        ),
        ".supplement": Style(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontSize: FontSize(14.0),
        ),
      },
    );
  }
}
