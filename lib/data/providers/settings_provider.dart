import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// Session Size Provider - Default 20, min 10, max 40
class SessionSizeNotifier extends StateNotifier<int> {
  final SharedPreferences prefs;
  
  SessionSizeNotifier(this.prefs) : super(prefs.getInt('session_size') ?? 20);

  void setSessionSize(int size) {
    state = size;
    prefs.setInt('session_size', size);
  }
}

final sessionSizeProvider = StateNotifierProvider<SessionSizeNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionSizeNotifier(prefs);
});

// Session Timer Provider - 0 (No Timer), 5, 10, 30 minutes
class SessionTimerNotifier extends StateNotifier<int> {
  final SharedPreferences prefs;

  SessionTimerNotifier(this.prefs) : super(prefs.getInt('session_timer') ?? 0);

  void setSessionTimer(int minutes) {
    state = minutes;
    prefs.setInt('session_timer', minutes);
  }
}

final sessionTimerProvider = StateNotifierProvider<SessionTimerNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionTimerNotifier(prefs);
});

// Locale Provider - persisted language selection
// On first launch, uses the device's system language if supported, otherwise English.
class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences prefs;

  static const _supportedLocales = ['en', 'ja'];

  LocaleNotifier(this.prefs) : super(_resolveInitialLocale(prefs));

  static String _resolveInitialLocale(SharedPreferences prefs) {
    final saved = prefs.getString('locale');
    if (saved != null) return saved;

    // No saved preference — detect system language
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (_supportedLocales.contains(systemLocale)) {
      return systemLocale;
    }
    return 'en'; // Fallback
  }

  void setLocale(String languageCode) {
    state = languageCode;
    prefs.setString('locale', languageCode);
  }
}

final persistedLocaleProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

// Auto-play Audio Provider
class AutoPlayAudioNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;

  AutoPlayAudioNotifier(this.prefs) : super(prefs.getBool('auto_play_audio') ?? false);

  void setAutoPlay(bool value) {
    state = value;
    prefs.setBool('auto_play_audio', value);
  }
}

final autoPlayAudioProvider = StateNotifierProvider<AutoPlayAudioNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoPlayAudioNotifier(prefs);
});
