import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final ttsServiceProvider = Provider((ref) => TtsService());

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    // For iOS/Android, we might need some specific init
    if (!kIsWeb) {
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
      }
      await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambientSolo,
          [IosTextToSpeechAudioCategoryOptions.allowBluetooth, IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP]);
    }
  }

  Future<void> speak(String text, String languageCode) async {
    // Detect if text contains any Japanese characters (Hiragana, Katakana, Kanji)
    // If it does, we MUST force the TTS to Japanese; otherwise English TTS completely skips them.
    final hasJapaneseChars = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
    final effectiveLanguageCode = hasJapaneseChars ? 'ja' : languageCode;

    final sanitizedText = _sanitizeForTts(text, effectiveLanguageCode);
    if (sanitizedText.isEmpty) return;

    String bcp47Code = effectiveLanguageCode;
    if (effectiveLanguageCode.startsWith('ja')) bcp47Code = 'ja-JP';
    if (effectiveLanguageCode.startsWith('en')) bcp47Code = 'en-US';

    await _flutterTts.setLanguage(bcp47Code);
    
    // Normalize speech rate (0.5 is normal on iOS/Web to avoid chipmunk, 1.0 on some Androids)
    if (kIsWeb || Platform.isIOS || Platform.isMacOS) {
      await _flutterTts.setSpeechRate(0.5);
    } else {
      await _flutterTts.setSpeechRate(0.5); // Default to a slower, formal cadence
    }

    await _flutterTts.setPitch(1.0);
    
    // Attempt to pick a formal, high-quality voice if available
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        for (var voice in voices) {
          final voiceName = voice['name']?.toString().toLowerCase() ?? '';
          final voiceLocale = voice['locale']?.toString() ?? '';
          
          if (voiceLocale == bcp47Code || voiceLocale == effectiveLanguageCode) {
            // Prefer Google's network voices, Siri's premium voices, or localized names
            if (voiceName.contains('premium') || 
                voiceName.contains('kyoko') || // iOS JA formal female
                voiceName.contains('sam') ||   // iOS EN formal
                voiceName.contains('google')) {
              await _flutterTts.setVoice({"name": voice['name'], "locale": voiceLocale});
              break;
            }
          }
        }
      }
    } catch (e) {
      // Fallback to default if voice picking fails
    }

    await _flutterTts.speak(sanitizedText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  String _sanitizeForTts(String html, String languageCode) {
    // 1. Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');

    // 2. Handle Furigana: _{base}_(_ruby_)
    final rubyRegex = RegExp(r'_\{[ \t\n]*(.*?)[ \t\n]*\}_[ \t\n]*\(_[ \t\n]*(.*?)[ \t\n]*_?\)', dotAll: true);
    
    text = text.replaceAllMapped(rubyRegex, (match) {
      final base = match.group(1) ?? '';
      final ruby = match.group(2) ?? '';
      // If language is JA, preferred reading is the ruby
      return languageCode.startsWith('ja') ? ruby : base;
    });

    // 3. Handle Fractions: |num/den|
    final fractionRegex = RegExp(r'\|[ \t\n]*(.+?)[ \t\n]*/[ \t\n]*(.+?)[ \t\n]*\|', dotAll: true);
    text = text.replaceAllMapped(fractionRegex, (match) {
      final num = match.group(1) ?? '';
      final den = match.group(2) ?? '';
      if (languageCode.startsWith('ja')) {
        return '${den}分の${num}'; // e.g. ni bun no ichi
      } else {
        return '$num over $den'; // e.g. 1 over 2
      }
    });

    // 4. Handle Math minus signs
    // Hyphens '-' or mathematical minus '−' are often read as dashes or 'to'.
    String minusWord = languageCode.startsWith('ja') ? 'マイナス' : 'minus';
    // Between numbers: "5 - 3" -> "5 minus 3"
    text = text.replaceAllMapped(RegExp(r'(\d)\s*[-−]\s*(\d)'), (m) => '${m.group(1)} $minusWord ${m.group(2)}');
    // Leading minus: "-5" -> "minus 5"
    text = text.replaceAllMapped(RegExp(r'^[-−]\s*(\d)'), (m) => '$minusWord ${m.group(1)}');
    // Loose minus signs padded with spaces
    text = text.replaceAll(' - ', ' $minusWord ');
    text = text.replaceAll(' − ', ' $minusWord ');

    // Cleanup whitespace
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
