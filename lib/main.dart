import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'data/providers/flashcard_provider.dart';
import 'flavor_config.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Default flavor if not initialized (fallback)
  if (!FlavorConfigExt.isInitialized) {
    FlavorConfig.initialize(
      FlavorConfig(
        flavor: AppFlavor.free,
        appTitle: 'Flashcard App',
      ),
    );
  }

  if (!kIsWeb && FlavorConfig.instance.showAds) {
    unawaited(MobileAds.instance.initialize());
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeCode = ref.watch(persistedLocaleProvider);
    final locale = Locale(localeCode);

    return MaterialApp.router(
      title: FlavorConfig.instance.appTitle,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,


      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // Router
      routerConfig: router,

      // Remove all bouncy/stretchy scroll effects globally
      scrollBehavior: const NoGlowScrollBehavior(),
    );
  }
}

/// Custom scroll behavior to disable overscroll glow/stretch and force clamping physics globally
class NoGlowScrollBehavior extends MaterialScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

extension FlavorConfigExt on FlavorConfig {
  static bool get isInitialized {
    try {
      FlavorConfig.instance;
      return true;
    } catch (_) {
      return false;
    }
  }
}
