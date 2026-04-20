import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

final ttsServiceProvider = Provider((ref) => TtsService(ref));

// Provider to track if the audio engine is still finding formal voices
final ttsLoadingProvider = StateProvider<bool>((ref) => true);

class TtsService {
  final Ref _ref;
  final FlutterTts _flutterTts = FlutterTts();
  List<dynamic>? _cachedVoices;
  bool _hasFetchedVoices = false;
  
  // Session cache: once we find a good formal voice for a language, we stick to it for consistency
  final Map<String, Map<String, String>> _sessionVoiceCache = {};

  // Flag to handle immediate termination of multi-segment speech
  bool _isStopped = false;

  TtsService(this._ref) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    
    if (!kIsWeb) {
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
      }
      await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambientSolo,
          [IosTextToSpeechAudioCategoryOptions.allowBluetooth, IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP]);
    }
  }

  Future<void> speak(String text, String languageCode) async {
    await stop();

    // Formal speech parameters
    // Hardcoded to 0.5 across all platforms as per previous successful resolution
    // Formal speech rate (0.5)
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    // 1. Sanitize the HTML and markup
    final sanitizedText = _sanitizeForTts(text, languageCode);
    if (sanitizedText.isEmpty) return;

    // 2. Split text into Japanese and Non-Japanese (English) segments
    // This allows us to use the Japanese voice ONLY for Japanese characters
    final RegExp jpRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+');
    final segments = _splitByLanguage(sanitizedText, jpRegex);
    
    _isStopped = false;

    for (final segment in segments) {
      if (_isStopped) break;
      final isJp = jpRegex.hasMatch(segment);
      final lang = isJp ? 'ja-JP' : 'en-US';
      
      // Select stable voice for this language
      Map<String, String>? selectedVoiceMap;
      if (_sessionVoiceCache.containsKey(lang)) {
        selectedVoiceMap = _sessionVoiceCache[lang]!;
      } else {
        await _pickFormalVoice(lang, isJp ? 'ja' : 'en');
        selectedVoiceMap = _sessionVoiceCache[lang];
      }

      debugPrint('TTS DEBUG: Segment: "$segment" | Lang: $lang | Voice: ${selectedVoiceMap?["name"] ?? "DEFAULT"}');

      try {
        await _flutterTts.setLanguage(lang);
        if (selectedVoiceMap != null) {
          await _flutterTts.setVoice(selectedVoiceMap);
        }
        await _flutterTts.speak(segment);
      } catch (e) {
        debugPrint('TTS ERROR: Failed to speak segment: $e');
      }
      
      if (kIsWeb && segments.length > 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  List<String> _splitByLanguage(String text, RegExp jpRegex) {
    List<String> segments = [];
    int start = 0;
    
    final matches = jpRegex.allMatches(text);
    for (final match in matches) {
      // Add preceding non-JP segment
      if (match.start > start) {
        segments.add(text.substring(start, match.start));
      }
      // Add JP segment
      segments.add(text.substring(match.start, match.end));
      start = match.end;
    }
    
    if (start < text.length) {
      segments.add(text.substring(start));
    }
    
    return segments.where((s) => s.trim().isNotEmpty).toList();
  }

  Future<void> warmUp() async {
    debugPrint('TTS LOG: Audio engine warm-up started...');
    _ref.read(ttsLoadingProvider.notifier).state = true;
    
    // Attempt to discover voices for both primary languages
    await _pickFormalVoice('en-US', 'en');
    await _pickFormalVoice('ja-JP', 'ja');
    
    _ref.read(ttsLoadingProvider.notifier).state = false;
    debugPrint('TTS LOG: Audio engine warm-up complete.');
  }

  Future<void> _pickFormalVoice(String bcp47Code, String effectiveLanguageCode) async {
    try {
      // Browsers often load voices asynchronously, so we try fetching multiple times if empty
      // Increased to 10 retries for more robust pre-warming on slower browsers
      if (!_hasFetchedVoices || (_cachedVoices?.isEmpty ?? true)) {
        for (int i = 0; i < 10; i++) {
          _cachedVoices = await _flutterTts.getVoices;
          if (_cachedVoices != null && _cachedVoices!.isNotEmpty) {
            _hasFetchedVoices = true;
            debugPrint('TTS LOG: Available Voices detected (${_cachedVoices!.length}):');
            break;
          }
          if (kIsWeb) await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      if (_cachedVoices != null && _cachedVoices!.isNotEmpty) {
        // High-priority keywords for Formal/Premium voices
        final List<String> priorityKeywords = effectiveLanguageCode.startsWith('ja')
            ? ['kyoko', 'premium', 'otoya', 'siri', 'enhanced', 'google']
            : ['google', 'samantha', 'premium', 'siri', 'enhanced', 'natural', 'daniel'];

        dynamic selectedVoice;
        
        // 1. Try to find a high-quality "Formal" voice
        for (var keyword in priorityKeywords) {
          for (var voice in _cachedVoices!) {
            final String name = voice['name']?.toString().toLowerCase() ?? '';
            final String locale = voice['locale']?.toString().toLowerCase().replaceAll('_', '-') ?? '';
            
            if (locale == bcp47Code.toLowerCase() || locale == effectiveLanguageCode.toLowerCase() || locale.startsWith(effectiveLanguageCode.toLowerCase())) {
              if (name.contains(keyword)) {
                selectedVoice = voice;
                break;
              }
            }
          }
          if (selectedVoice != null) break;
        }

        // 2. FALLBACK: If no formal voice found, pick the FIRST available voice for THIS locale
        // This is CRITICAL for consistency. Even if the voice is basic, sticking to one 
        // prevents the "different voices" issue.
        if (selectedVoice == null) {
          for (var voice in _cachedVoices!) {
            final String locale = voice['locale']?.toString().toLowerCase().replaceAll('_', '-') ?? '';
            if (locale == bcp47Code.toLowerCase() || locale == effectiveLanguageCode.toLowerCase() || locale.startsWith(effectiveLanguageCode.toLowerCase())) {
              selectedVoice = voice;
              break;
            }
          }
        }

        if (selectedVoice != null) {
          final voiceMap = {"name": selectedVoice['name'].toString(), "locale": selectedVoice['locale'].toString()};
          _sessionVoiceCache[bcp47Code] = voiceMap;
          debugPrint('TTS LOG: Locked onto voice for consistency: ${voiceMap["name"]} for $bcp47Code');
          await _flutterTts.setVoice(voiceMap);
        } else {
          debugPrint('TTS WARNING: No suitable voice found for $bcp47Code at all in the system list.');
        }
      }
    } catch (e) {
      debugPrint('TTS ERROR: Exception in _pickFormalVoice: $e');
    }
  }

  Future<void> stop() async {
    _isStopped = true;
    await _flutterTts.stop();
  }

  String _sanitizeForTts(String html, String languageCode) {
    // 0. Inject punctuation for pauses between Title and Problem if they are joined by <br/>
    String processedHtml = html.replaceAll(RegExp(r'<br\s*/?>'), '. ');

    // 1. Remove remaining HTML tags
    String text = processedHtml.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');

    // 2. Handle Furigana: _{base}_(_ruby_) or _{base}_(ruby)
    final rubyRegex = RegExp(r'_\{[ \t\n]*(.*?)[ \t\n]*\}_[ \t\n]*\([ \t\n]*_?[ \t\n]*(.*?)[ \t\n]*_?[ \t\n]*\)', dotAll: true);
    text = text.replaceAllMapped(rubyRegex, (match) {
      final base = (match.group(1) ?? '').replaceAll('{', '').replaceAll('}', '');
      final ruby = (match.group(2) ?? '').replaceAll('{', '').replaceAll('}', '');
      return languageCode.startsWith('ja') ? ruby : base;
    });

    // 3. Handle Fractions: |num/den| or |<num/den>|
    final fractionRegex = RegExp(r'\|[ \t\n]*(?:<[ \t\n]*)?(.+?)[ \t\n]*/[ \t\n]*(.+?)[ \t\n]*(?:>[ \t\n]*)?\|', dotAll: true);
    text = text.replaceAllMapped(fractionRegex, (match) {
      final num = match.group(1) ?? '';
      final den = match.group(2) ?? '';
      return languageCode.startsWith('ja') ? '${den}分の${num}' : '$num over $den';
    });

    // 4. Remove lingering '|' characters (e.g. |1| becomes 1)
    text = text.replaceAll('|', '');

    // 5. Handle Math minus signs
    String minusWord = languageCode.startsWith('ja') ? 'マイナス' : 'minus';
    text = text.replaceAllMapped(RegExp(r'(\d)\s*[-−]\s*(\d)'), (m) => '${m.group(1)} $minusWord ${m.group(2)}');
    text = text.replaceAllMapped(RegExp(r'^[-−]\s*(\d)'), (m) => '$minusWord ${m.group(1)}');
    text = text.replaceAll(' - ', ' $minusWord ');
    text = text.replaceAll(' − ', ' $minusWord ');

    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
