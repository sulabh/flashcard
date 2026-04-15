import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'data/providers/flashcard_provider.dart';
import 'flavor_config.dart';


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
    final locale = ref.watch(localeProvider);

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
    );
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
