enum AppFlavor { free, paid }

class FlavorConfig {
  final AppFlavor flavor;
  final String appTitle;
  final bool showAds;

  FlavorConfig({
    required this.flavor,
    required this.appTitle,
    this.showAds = false,
  });

  static late FlavorConfig _instance;
  static FlavorConfig get instance => _instance;

  static void initialize(FlavorConfig config) {
    _instance = config;
  }
}
