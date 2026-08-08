import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/borderd_container.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/core/game_logic/game.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/screens/game/widgets/dashed_avatar_widget.dart';

/// Shown when a multiplayer (or local) match ends in a draw. A draw returns
/// each player their own stake, so there is no winner and no net coin change.
class DrawDialog extends StatelessWidget {
  final Game game;
  final Player player1;
  final Player player2;
  final int? entryFee;
  final bool isMultiplayer;
  const DrawDialog({
    super.key,
    required this.game,
    required this.player1,
    required this.player2,
    required this.isMultiplayer,
    this.entryFee,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
        title: context.tr('gameOver'),
        hideCloseButton: true,
        buttons: [
          DialogButton(
            title: isMultiplayer ? context.tr('ok') : context.tr('cancel'),
            onTap: () {
              if (isMultiplayer) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homeScreen,
                  (route) => false,
                );
              } else {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              }
            },
          ),
          if (!isMultiplayer)
            DialogButton(
              color: context.color.onSurface,
              title: context.tr('restart'),
              textColor: context.color.surface,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.mazeScreen,
                    arguments: game..reset());
              },
            ),
        ],
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DashedAvatarWidget(
                    image: player1.playerProfile,
                    size: 73,
                  ),
                  CustomImage(AppIcons.versus),
                  DashedAvatarWidget(
                    image: player2.playerProfile,
                    size: 73,
                  ),
                ],
              ),
            ),
            Text(
              context.tr('itsADraw'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: context.font.large,
              ),
            ),
            if (isMultiplayer && entryFee != null)
              FittedBox(
                fit: BoxFit.none,
                child: BorderContainer(
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.tr('stakeReturned',
                        params: {'amount': entryFee.toString()})),
                  ],
                )),
              ),
          ],
        ));
  }
}
