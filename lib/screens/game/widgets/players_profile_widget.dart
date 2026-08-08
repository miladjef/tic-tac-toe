import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/avatar_card.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/marquee.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/screens/game/widgets/neon_border_widget.dart';

class PlayersProfileWidget extends StatefulWidget {
  final Player? player1;
  final Player? player2;
  final Player? currentPlayer;
  const PlayersProfileWidget(
      {super.key,
      required this.player1,
      required this.player2,
      this.currentPlayer});

  @override
  State<PlayersProfileWidget> createState() => _PlayersProfileWidgetState();
}

class _PlayersProfileWidgetState extends State<PlayersProfileWidget> {
  Widget buildPlayerProfile(
    BuildContext context, {
    required String id,
    required String image,
    required String skin,
    required String name,
    required bool contentAlignLeft,
  }) {
    Widget content() {
      return Column(
        crossAxisAlignment: contentAlignLeft
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('sign')),
              Transform.translate(
                offset: const Offset(4, 0),
                child: CustomImage(
                  skin,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          MarqueeWidget(
            child: CustomText(
              name,
              maxLines: 1,
              ellipsis: true,
            ),
          )
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (contentAlignLeft) ...[
          Expanded(child: content()),
          SizedBox(
            width: 7,
          )
        ],
        Container(
            decoration: BoxDecoration(
              border: widget.currentPlayer?.playerId == id
                  ? NeonBorderContainer(Colors.pink)
                  : null,
            ),
            child: AvatarCard(
              width: 52,
              height: 52,
              image: image,
              disableShadow:
                  widget.currentPlayer?.playerId == id ? true : false,
            )),
        if (!contentAlignLeft) ...[
          SizedBox(
            width: 7,
          ),
          Expanded(child: content())
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: buildPlayerProfile(context,
              image: widget.player1?.playerProfile ?? AppIcons.guest,
              skin: widget.player1!.getSkin(),
              contentAlignLeft: false,
              name: (widget.player1!.isYou &&
                      context.read<AuthenticationBloc>().isGuest)
                  ? context.tr('you')
                  : widget.player1!.name,
              id: widget.player1!.playerId),
        ),
        CustomImage(
          AppIcons.versus,
          width: 30,
          height: 60,
        ),
        Expanded(
          child: buildPlayerProfile(context,
              id: widget.player2!.playerId,
              image: widget.player2?.playerProfile ?? AppIcons.guest,
              skin: widget.player2!.getSkin(),
              contentAlignLeft: true,
              name: (widget.player2!.isYou &&
                      context.read<AuthenticationBloc>().isGuest)
                  ? context.tr('you')
                  : widget.player2!.name),
        ),
      ],
    );
  }
}
