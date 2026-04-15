# Monetization & Upgrades Guide

This guide is for future developers maintaining the `Flashcard App` (RubyStudy). It outlines how to transition from sandbox/test ads to production ads, and how to restructure the app if you wish to offer a single "Freemium" app with In-App Purchases (IAP) instead of two separate flavor apps (`free` and `paid`).

---

## 1. Enabling Actual Ads in the Free Version

Currently, the `AdBannerWidget` uses **Google Mobile Ads Test IDs**. This is crucial during development to prevent your actual AdMob account from being flagged or banned for fraudulent clicks. 

Before publishing the `free` flavor to the App Store or Google Play, you must swap these test IDs out for your production Ad Unit IDs.

### Steps to enable Production Ads:

1. **Create an AdMob Account:** Go to [Google AdMob](https://admob.google.com/), create an account, and register your app (one for Android, one for iOS).
2. **Create Ad Units:** Within the AdMob dashboard, create Banner Ad Units for both Android and iOS. Note down the **App IDs** and the **Ad Unit IDs**.
3. **Update Platform Metadata (App IDs):**
   * **Android:** Open `android/app/src/main/AndroidManifest.xml` and replace the `com.google.android.gms.ads.APPLICATION_ID` meta-data value (`ca-app-pub-3940256099942544~3347511713`) with your production Android App ID.
   * **iOS:** Open `ios/Runner/Info.plist` and replace the `GADApplicationIdentifier` string (`ca-app-pub-3940256099942544~1458002511`) with your production iOS App ID.
4. **Update the Flutter Widget (Ad Unit IDs):**
   * Open `lib/presentation/widgets/ad_banner_widget.dart`.
   * Find the `_adUnitId` initialization.
   * Replace the test strings with your production Ad Unit IDs.

```dart
// Example in ad_banner_widget.dart:
final String _adUnitId = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? 'ca-app-pub-YOUR_ANDROID_AD_UNIT_ID' // <-- Replace here
    : 'ca-app-pub-YOUR_IOS_AD_UNIT_ID';    // <-- Replace here
```

> **Warning:** NEVER click on your own live ads. Add your physical test devices in the AdMob dashboard as "Test Devices" if you wish to run the production IDs locally.

---

## 2. Transitioning to a Single Freemium App (In-App Purchases)

Currently, the app uses **Flavors** (`main_free.dart` and `main_paid.dart`) to generate two completely separate binaries (e.g., `com.flashcard.app.free` and `com.flashcard.app.paid`).

If your business requirement changes to offering a **single app** that users download for free, and then pay inside the app to unlock premium features and remove ads, follow these steps to migrate away from Flavors to an IAP model.

### Step 1: Remove the Flavor Split Target
You will no longer use `--flavor free` or `--flavor paid`. 
You can consolidate `main_free.dart` and `main_paid.dart` back into a single `lib/main.dart` entry point. The initial state of the app will always default to the `free` experience.

### Step 2: Integrate `in_app_purchase`
Add the official Flutter IAP package to your `pubspec.yaml`:
```bash
flutter pub add in_app_purchase
```

### Step 3: Implement an IAP State Provider
Use Riverpod to manage the user's Premium state. Instead of relying on a hardcoded `FlavorConfig`, the app will query this provider to decide whether to hide ads or unlock features.

```dart
// lib/data/providers/premium_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PremiumNotifier(prefs);
});

class PremiumNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  
  // Load persistent state on boot
  PremiumNotifier(this._prefs) : super(_prefs.getBool('is_premium') ?? false);

  void unlockPremium() {
    state = true;
    _prefs.setBool('is_premium', true);
  }
}
```

### Step 4: Configure `in_app_purchase` Handlers
Create a service that listens to the `InAppPurchase.instance.purchaseStream`.
1. When the user taps "Upgrade to Pro", trigger `InAppPurchase.instance.buyNonConsumable(purchaseParam: param)`.
2. When the purchase completes successfully, call `ref.read(premiumProvider.notifier).unlockPremium()`.

### Step 5: Conditionally Render Ads and Features
Instead of checking `FlavorConfig.instance.showAds`, you will now watch the `premiumProvider`.

```dart
// Example in AdBannerWidget
@override
Widget build(BuildContext context) {
  // Watch the premium state from Riverpod
  final isPremium = ref.watch(premiumProvider);

  // If the user upgraded, hide the ad box completely.
  if (isPremium) {
    return const SizedBox.shrink();
  }

  // Otherwise, load and return the AdWidget...
}
```

### Step 6: App Store Configuration
You will need to create a **"Non-Consumable"** In-App Purchase in both App Store Connect (Apple) and Google Play Console (Android), giving them identical Product IDs (e.g., `flashcard_app_pro_upgrade`). You will query this Product ID in step 4 to present the Native Paywall UI.
