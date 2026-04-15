import 'package:flutter/material.dart';

class FractionWidget extends StatelessWidget {
  final String numerator;
  final String denominator;
  final double? fontSize;
  final Color? color;

  const FractionWidget({
    super.key,
    required this.numerator,
    required this.denominator,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the font size for the fraction parts (smaller than base text)
    final baseFontSize = fontSize ?? 20.0;
    final partFontSize = baseFontSize * 0.75;
    final textColor = color ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Numerator
            Text(
              numerator,
              style: TextStyle(
                fontSize: partFontSize,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            // Divider
            Container(
              height: 1.5,
              color: textColor.withAlpha(150),
              margin: const EdgeInsets.symmetric(vertical: 1.0),
            ),
            // Denominator
            Text(
              denominator,
              style: TextStyle(
                fontSize: partFontSize,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
