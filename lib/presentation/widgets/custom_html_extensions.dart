import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ruby_text/ruby_text.dart';
import 'fraction_widget.dart';
import 'package:html/dom.dart' as dom;

class CustomHtmlExtensions {
  /// Returns a list of extensions for flutter_html to handle Ruby (Furigana) and Fractions.
  static List<HtmlExtension> get extensions => [
        TagExtension(
          tagsToExtend: {"ruby"},
          builder: (context) {
            // 1. Extract base text (everything except <rt> content)
            final baseNodes = context.element?.nodes.where((node) {
                  if (node is dom.Element) {
                    return node.localName != 'rt';
                  }
                  return true;
                }) ??
                [];
            final baseText = baseNodes.map((n) => n.text).join().trim();

            // 2. Extract ruby text (<rt> content)
            final rtElement = context.element?.getElementsByTagName('rt').firstOrNull;
            final rubyText = rtElement?.text ?? '';

            // 3. Render using ruby_text package
            final style = context.styledElement?.style;
            final color = style?.color ?? Colors.black;
            final fontSize = style?.fontSize?.value ?? 20.0;

            // In TagExtension builder for flutter_html 3.0.0, return a Widget directly.
            // FlutterHtml will handle the necessary wrapping.
            return RubyText(
              [
                RubyTextData(
                  baseText,
                  ruby: rubyText,
                ),
              ],
              style: TextStyle(
                color: color,
                fontSize: fontSize,
              ),
              rubyStyle: TextStyle(
                color: color.withAlpha(200),
                fontSize: fontSize * 0.5,
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: {"fraction"},
          builder: (context) {
            final num = context.attributes['num'] ?? '';
            final den = context.attributes['den'] ?? '';

            final style = context.styledElement?.style;
            final color = style?.color;
            final fontSize = style?.fontSize?.value;

            return FractionWidget(
              numerator: num,
              denominator: den,
              fontSize: fontSize,
              color: color,
            );
          },
        ),
      ];
}
