import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/extensions/color_extension.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/interstitial_ad_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/more_game_model.dart';
import 'package:tic_tac_toe/constants/settings.dart';

/// Lists the WebView games registered in [AppSettings.moreGames].
/// Tapping a game opens it inside [GameWebViewScreen].
class MoreGamesScreen extends StatefulWidget {
  const MoreGamesScreen({super.key});

  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const MoreGamesScreen(),
      );

  @override
  State<MoreGamesScreen> createState() => _MoreGamesScreenState();
}

class _MoreGamesScreenState extends State<MoreGamesScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([]);
    super.initState();
    InterstitialAdService.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    final games = AppSettings.moreGames;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: CustomText(
          context.tr('playMoreGames'),
          fontSize: context.font.large,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
      ),
      body: games.isEmpty
          ? Center(child: CustomText(context.tr('noGamesAvailableYet')))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    for (final game in games) _gameCard(context, game),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _gameCard(BuildContext context, MoreGame game) {
    return IntrinsicHeight(
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InnerShadowContainer(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  spacing: 12,
                  children: [
                    CustomImage(
                      game.image.isEmpty ? AppIcons.moreGame : game.image,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      radius: 10,
                    ),
                    Expanded(
                      child: CustomText(
                        game.name,
                        fontSize: context.font.medium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.gameWebViewScreen,
              arguments: game,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.color.primary.brighten(0.55),
                    context.color.primary.brighten(0.15),
                    context.color.primary.darken(0.15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: CustomText(
                context.tr('playNow'),
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
