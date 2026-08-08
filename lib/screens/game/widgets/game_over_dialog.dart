import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/borderd_container.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/core/game_logic/game.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/screens/game/widgets/dashed_avatar_widget.dart';

class GameOverDialog extends StatelessWidget {
  final Game game;
  final Player winner;
  final int? entryFee;
  final bool isMultiplayer;
  const GameOverDialog({
    super.key,
    required this.winner,
    this.entryFee,
    required this.isMultiplayer,
    required this.game,
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
            // Multiplayer is written from the local player's point of view:
            // their own avatar and name sit above their own result, so a loser
            // is never shown the winner's face over their "You lost:" line. The
            // local modes have no such result line, so they keep announcing the
            // winner.
            DashedAvatarWidget(
              image: isMultiplayer
                  ? game.self.playerProfile
                  : winner.playerProfile,
            ),
            Text(isMultiplayer ? game.self.name : winner.name),
            if (isMultiplayer)
              FittedBox(
                fit: BoxFit.none,
                child: BorderContainer(
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(winner.isYou
                        ? context.tr('winningPrice')
                        : context.tr('youLost')),
                    Text(winner.isYou
                        ? (entryFee! * 2).toString()
                        : entryFee.toString()),
                  ],
                )),
              ),
          ],
        ));
  }
}
