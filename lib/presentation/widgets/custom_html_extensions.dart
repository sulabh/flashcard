import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ruby_text/ruby_text.dart';
import 'fraction_widget.dart';

class CustomHtmlExtensions {
  /// Returns a list of extensions for flutter_html to handle Ruby (Furigana) and Fractions.
  static List<Extension> get extensions => [
        const RubyTagExtension(),
        const FractionTagExtension(),
      ];
}

class RubyTagExtension extends TagExtension {
  const RubyTagExtension();

  @override
  bool matches(ExtensionContext context) => context.tagName == 'ruby';

  @override
  Widget build(ExtensionContext context) {
    // 1. Extract base text (everything except <rt> content)
    final baseNodes = context.element?.nodes.where((node) {
          if (node.nodeType == NodeType.ELEMENT) {
            return (node as dynamic).localName != 'rt';
          }
          return true;
        }) ??
        [];
    final baseText = baseNodes.map((n) => n.text).join().trim();

    // 2. Extract ruby text (<rt> content)
    final rtElement = context.element?.getElementsByTagName('rt').firstOrNull;
    final rubyText = rtElement?.text ?? '';

    // 3. Render using ruby_text package
    // We try to inherit the text style from the context if possible
    final style = context.styledElement?.style;
    final color = style?.color ?? Colors.black;
    final fontSize = style?.fontSize?.value ?? 20.0;

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
  }
}

class FractionTagExtension extends TagExtension {
  const FractionTagExtension();

  @override
  bool matches(ExtensionContext context) => context.tagName == 'fraction';

  @override
  Widget build(ExtensionContext context) {
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
  }
}
