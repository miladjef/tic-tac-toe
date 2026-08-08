import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/banner_ad_widget.dart';
import 'package:tic_tac_toe/constants/settings.dart';
import 'package:tic_tac_toe/core/game_logic/offline_game.dart';
import 'package:tic_tac_toe/core/game_logic/pass_n_play.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/data/models/game/game_setting_model.dart';
import 'package:tic_tac_toe/data/models/game/matrix_size_model.dart';
import 'package:tic_tac_toe/screens/home/widgets/home_card.dart';
import 'package:tic_tac_toe/screens/home/widgets/home_top_bar.dart';
import 'package:tic_tac_toe/screens/home/widgets/difficulty_selection_dialog.dart';
import 'package:tic_tac_toe/screens/home/widgets/entryfee_selection_dialog.dart';
import 'package:tic_tac_toe/screens/home/widgets/matrixsize_selection_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static Route route(RouteSettings settings) {
    return GradientRouter(
        builder: (BuildContext context) => const HomeScreen());
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const BannerAdWidget(),
      appBar: const HomeTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 12,
            children: [
              HomeCard(
                reverse: false,
                image: AppIcons.dora1,
                title: context.tr('offlinePlay'),
                subTitle: context.tr('playWithTheCleverFoxDora'),
                onTap: () async {
                  Difficulty? difficulty = await UiUtils.showDialog(context,
                      child: DifficultySelectionDialog());
                  if (difficulty == null) return;
                  if (!context.mounted) return;
                  MatrixSize? size = await UiUtils.showDialog(context,
                      child: MatrixSizeSelectionDialog());
                  if (size == null) return;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushNamed(context, AppRoutes.mazeScreen,
                        arguments: OfflineGame(
                            settings: GameSettings(boardSize: size.size),
                            difficulty: difficulty));
                  });
                },
              ),
              HomeCard(
                reverse: true,
                image: AppIcons.dora2,
                title: context.tr('randomPlay'),
                subTitle: context.tr('findYourMatchAroundTheWorld'),
                onTap: () async {
                  int? entryFee = await UiUtils.showDialog(context,
                      child: EntryFeeSelectionDialog());
                  if (entryFee == null) return;
                  if (!context.mounted) return;
                  MatrixSize? size = await UiUtils.showDialog(context,
                      child: MatrixSizeSelectionDialog());
                  if (size == null) return;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushNamed(context, AppRoutes.connectionScreen,
                        arguments: {
                          'size': size,
                          'fee': entryFee,
                          'round': AppSettings.rounds.first,
                        });
                  });
                },
              ),
              HomeCard(
                reverse: false,
                image: AppIcons.dora3,
                subTitle: context.tr('passNPlayWithYourFriend'),
                title: context.tr('passNPlay'),
                onTap: () async {
                  MatrixSize? size = await UiUtils.showDialog(context,
                      child: MatrixSizeSelectionDialog());
                  if (size == null) return;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushNamed(context, AppRoutes.mazeScreen,
                        arguments: PassNPlayGame(
                            settings: GameSettings(boardSize: size.size)));
                  });
                },
              ),
              // ClipPathWithBorder()
            ],
          ),
        ),
      ),
    );
  }
}
