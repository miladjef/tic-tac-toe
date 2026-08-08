import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/constants/ad_config.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/shop_item_model.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const ShopScreen(),
      );

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  StreamSubscription<List<ShopItem>>? _catalogSub;
  StreamSubscription<Purchase?>? _purchaseUpdatedSub;
  StreamSubscription<PurchaseError>? _purchaseErrorSub;

  List<ShopItem>? _catalog;
  final Map<String, Product> _products = {};
  String? _purchasingId;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _catalogSub = DatabaseService.instance.streamShopItems().listen((items) {
      if (mounted) setState(() => _catalog = items);
    });
    _initIap();
    _preloadRewardedAdIfAllowed();
  }

  @override
  void dispose() {
    _catalogSub?.cancel();
    _purchaseUpdatedSub?.cancel();
    _purchaseErrorSub?.cancel();
    _rewardedAd?.dispose();
    FlutterInappPurchase.instance.endConnection();
    super.dispose();
  }

  Future<void> _initIap() async {
    try {
      await FlutterInappPurchase.instance.initConnection();
      _purchaseUpdatedSub = FlutterInappPurchase.instance.purchaseUpdated
          .listen(_onPurchaseUpdated);
      _purchaseErrorSub =
          FlutterInappPurchase.instance.purchaseErrorListener.listen((error) {
        setState(() => _purchasingId = null);
        if (!mounted) return;
        _showSnack(context, error.message);
      });

      final products = await FlutterInappPurchase.instance
          .fetchProducts<Product>(skus: AdConfig.coinProductIds);
      if (!mounted) return;
      setState(() {
        for (final product in products) {
          _products[product.id] = product;
        }
      });
    } catch (e) {
      debugPrint('[Shop] IAP init failed: $e');
    }
  }

  int? _coinsForProductId(String productId) {
    for (final item in _catalog ?? const <ShopItem>[]) {
      if (item.id == productId) return item.coins;
    }
    return null;
  }

  Future<void> _onPurchaseUpdated(Purchase? purchase) async {
    if (purchase == null) return;
    final int? coins = _coinsForProductId(purchase.productId);
    if (coins != null) {
      final String uid = DatabaseService.instance.userId!;
      final bool claimed =
          await DatabaseService.instance.claimPurchase(uid, purchase.id);
      if (claimed) {
        await DatabaseService.instance.creditCoins(uid, coins);
      }
    }
    await FlutterInappPurchase.instance
        .finishTransaction(purchase: purchase, isConsumable: true);

    if (!mounted) return;
    setState(() => _purchasingId = null);
    if (coins != null) _showPurchaseSuccessDialog(context, coins);
  }

  void _preloadRewardedAdIfAllowed() async {
    if (!AdConfig.rewardedAdEnabled || AdConfig.adProvider != AdProviderType.google) return;
    final allowed = await DatabaseService.instance
        .canWatchRewardedAdToday(AdConfig.adLimit);
    if (allowed) _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _rewardedAd = ad);
        },
        onAdFailedToLoad: (error) =>
            debugPrint('[Shop] Rewarded ad failed to load: $error'),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPurchaseSuccessDialog(BuildContext context, int coins) {
    return UiUtils.showDialog(
      context,
      child: CustomDialogBox(
        title: context.tr('congratulations'),
        hideCloseButton: true,
        buttons: [
          DialogButton(
            title: context.tr('ok'),
            color: context.color.tertiary,
            textColor: Colors.white,
            onTap: () => Navigator.pop(context),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImage(AppIcons.coin, width: 20, height: 20),
              const SizedBox(width: 6),
              Flexible(
                child: CustomText(
                  context.tr('youGotCoins', params: {'coins': '$coins'}),
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onBuy(BuildContext context, ShopItem item) async {
    if (_purchasingId != null) return;
    setState(() => _purchasingId = item.id);
    try {
      await FlutterInappPurchase.instance.requestPurchaseWithBuilder(
        build: (builder) {
          builder.ios.sku = item.id;
          builder.android.skus = [item.id];
          builder.type = ProductQueryType.InApp;
        },
      );
    } catch (e) {
      if (mounted) setState(() => _purchasingId = null);
      if (context.mounted) {
        _showSnack(context, context.tr('purchaseFailed'));
      }
    }
  }

  Future<void> _watchAd(BuildContext context) async {
    final allowed = await DatabaseService.instance
        .canWatchRewardedAdToday(AdConfig.adLimit);
    if (!context.mounted) return;
    if (!allowed) {
      _showSnack(context, context.tr('youReachedAtTodaysAdLimit'));
      return;
    }

    if (AdConfig.adProvider == AdProviderType.google) {
      final ad = _rewardedAd;
      if (ad == null) {
        _showSnack(context, context.tr('adNotLoaded'));
        _loadRewardedAd();
        return;
      }
      _rewardedAd = null;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _preloadRewardedAdIfAllowed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _preloadRewardedAdIfAllowed();
        },
      );
      ad.show(
        onUserEarnedReward: (ad, reward) => _grantAdReward(context),
      );
    } else {
      UnityAds.load(
        placementId: AdConfig.unityRewardedPlacementId,
        onComplete: (placementId) {
          UnityAds.showVideoAd(
            placementId: placementId,
            onComplete: (placementId) => _grantAdReward(context),
            onFailed: (placementId, error, message) {
              if (context.mounted) {
                _showSnack(context, context.tr('adNotLoaded'));
              }
            },
          );
        },
        onFailed: (placementId, error, message) {
          if (context.mounted) _showSnack(context, context.tr('adNotLoaded'));
        },
      );
    }
  }

  Future<void> _grantAdReward(BuildContext context) async {
    await DatabaseService.instance
        .creditCoins(DatabaseService.instance.userId!, AdConfig.adRewardAmount);
    await DatabaseService.instance.recordRewardedAdWatch();
    if (!context.mounted) return;
    _showSnack(context, context.tr('rewardAmountAddedSuccessfully'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: CustomText(context.tr('shop'),
            fontSize: context.font.large,
            fontWeight: FontWeight.w700,
            color: AppColors.white),
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
      ),
      body: Builder(builder: (context) {
        final catalog = _catalog;
        if (catalog == null) {
          return Center(
              child: CircularProgressIndicator(color: context.color.secondary));
        }
        final items = AdConfig.rewardedAdEnabled
            ? catalog
            : catalog.where((item) => !item.isAd).toList();

        return GridView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 220,
          ),
          itemBuilder: (context, index) =>
              _buildShopCard(context, items[index]),
        );
      }),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopItem item) {
    return InnerShadowContainer(
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            PositionedDirectional(
                top: 60, start: 10, child: CustomImage(AppIcons.starGroup)),
            PositionedDirectional(
                bottom: 50, end: -14, child: CustomImage(AppIcons.starGroup)),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  color: context.color.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomText(
                    item.title,
                    textAlign: TextAlign.center,
                    fontSize: context.font.medium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildArtwork(context, item),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: item.isAd
                      ? _buildWatchAdButton(context, item)
                      : _buildPriceButton(context, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, ShopItem item) {
    if (item.isAd) {
      return CustomImage(AppIcons.ads, fit: BoxFit.contain);
    }
    final image = item.image;
    if (image != null && image.isNotEmpty) {
      return CustomImage(image, fit: BoxFit.contain);
    }
    return CustomImage(item.coinArtwork, fit: BoxFit.contain);
  }

  Offset? _watchAdPointerDownPosition;

  Widget _buildWatchAdButton(BuildContext context, ShopItem item) {
    // Plain GestureDetector.onTap loses the gesture arena to the ancestor
    // GridView's scroll recognizer on some OEM devices (observed
    // consistently on ColorOS hardware, even with a zero-movement tap), so
    // this button reacts to raw pointer events instead of arena-mediated
    // tap recognition, treating any small-movement down→up as a tap.
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _watchAdPointerDownPosition = event.position,
      onPointerUp: (event) {
        final down = _watchAdPointerDownPosition;
        if (down != null && (event.position - down).distance <= 24) {
          _watchAd(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: CustomText(
          context.tr('earnCoinsByViewingAds'),
          textAlign: TextAlign.center,
          fontSize: context.font.normal,
          fontWeight: FontWeight.w700,
          color: context.color.secondary,
        ),
      ),
    );
  }

  Widget _buildPriceButton(BuildContext context, ShopItem item) {
    final product = _products[item.id];
    final String label = product?.displayPrice ?? item.priceLabel;
    final bool isPurchasing = _purchasingId == item.id;

    return GestureDetector(
      onTap: isPurchasing ? null : () => _onBuy(context, item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: isPurchasing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              )
            : CustomText(
                label,
                fontSize: context.font.normal,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
      ),
    );
  }
}
