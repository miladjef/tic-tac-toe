import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/marquee.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/screens/game/widgets/dashed_avatar_widget.dart';

class NextRoundDialog extends StatefulWidget {
  final Player player1;
  final Player player2;
  final int round;

  final Player? winner;
  const NextRoundDialog(
      {super.key,
      required this.player1,
      required this.player2,
      required this.winner,
      required this.round});

  @override
  State<NextRoundDialog> createState() => _NextRoundDialogState();
}

class _NextRoundDialogState extends State<NextRoundDialog> {
  Timer? timer;
  int time = 3;
  BuildContext? dContext;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time--;
      if (time == 0) {
        Navigator.pop(context);
        timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('nextRound'),
      hideCloseButton: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashedAvatarWidget(
                  image: widget.player1.playerProfile,
                  size: 73,
                ),
                CustomImage(AppIcons.versus),
                DashedAvatarWidget(
                  image: widget.player2.playerProfile,
                  size: 73,
                ),
              ],
            ),
          ),
          CustomText(
            context.tr('roundNumber', params: {'round': '${widget.round + 1}'}),
            fontSize: context.font.medium,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(
            width: context.screenWidth * 0.5,
            child: MarqueeWidget(
              child: CustomText(
                widget.winner == null
                    ? context.tr('itsADraw')
                    : context.tr('playerVictory',
                        params: {'player': widget.winner!.name}),
                textAlign: TextAlign.center,
                fontSize: context.font.medium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(4),
            child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: context.color.surface,
                  radius: Radius.circular(800000),
                  dashPattern: [3, 3],
                ),
                child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: CustomText(
                          '$time',
                          color: context.color.surface,
                          fontSize: context.font.large,
                        ),
                      ),
                    ))),
          )
        ],
      ),
    );
  }
}
