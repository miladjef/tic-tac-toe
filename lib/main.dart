import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tic_tac_toe/common/local_storage.dart';
import 'package:tic_tac_toe/constants/ad_config.dart';
import 'package:tic_tac_toe/core/app.dart';
import 'package:tic_tac_toe/core/services/sound_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.screenBackgroundGradient.last,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  await LocalStorage.init();
  SoundService.init();

  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    providerAndroid:
        kDebugMode ? AndroidDebugProvider() : AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? AppleDebugProvider() : AppleAppAttestProvider(),
  );

  if (AdConfig.bannerAdEnabled ||
      AdConfig.interstitialAdEnabled ||
      AdConfig.rewardedAdEnabled) {
    // Required before loading personalized/IDFA-based ads on iOS 14.5+; a
    // no-op on Android.
    await AppTrackingTransparency.requestTrackingAuthorization();
    await MobileAds.instance.initialize();
    await UnityAds.init(
      gameId: AdConfig.unityGameId,
      testMode: kDebugMode,
      onComplete: () => debugPrint('Unity Ads initialized'),
      onFailed: (error, message) =>
          debugPrint('Unity Ads init failed: $error $message'),
    );
  }

  runApp(App());
}
