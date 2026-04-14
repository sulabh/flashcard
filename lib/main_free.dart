import 'package:flutter/material.dart';
import 'flavor_config.dart';
import 'main.dart' as app;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.initialize(
    FlavorConfig(
      flavor: AppFlavor.free,
      appTitle: 'Flashcard Free',
      showAds: true,
    ),
  );
  app.main();
}
