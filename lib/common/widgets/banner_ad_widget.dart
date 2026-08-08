import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tic_tac_toe/constants/ad_config.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  AdSize? _adSize;
  bool _isLoaded = false;

  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (AdConfig.bannerAdEnabled && AdConfig.adProvider == AdProviderType.google && !_loadRequested) {
      _loadRequested = true;
      _loadGoogleBanner();
    }
  }

  Future<void> _loadGoogleBanner() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null) {
      debugPrint('[Ads] Unable to get adaptive banner size');
      return;
    }
    if (!mounted) return;

    setState(() => _adSize = size);

    final banner = BannerAd(
      adUnitId: AdConfig.bannerAdID,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[Ads] Banner failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    );
    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.bannerAdEnabled) return const SizedBox.shrink();

    if (AdConfig.adProvider == AdProviderType.google) {
      final size = _adSize;

      if (size == null) return const SizedBox.shrink();
      final ad = _bannerAd;
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: size.height.toDouble(),
          alignment: Alignment.center,
          child: (_isLoaded && ad != null)
              ? AdWidget(ad: ad)
              : const SizedBox.shrink(),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: UnityBannerAd(
        placementId: AdConfig.unityBannerPlacementId,
        onFailed: (placementId, error, message) =>
            debugPrint('[Ads] Unity banner failed to load: $error $message'),
      ),
    );
  }
}
