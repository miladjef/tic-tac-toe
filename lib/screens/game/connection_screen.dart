import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';

import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/avatar_card.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/marquee.dart';
import 'package:tic_tac_toe/core/game_logic/multiplayer_game.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/data/bloc/game/game_connection_bloc.dart';
import 'package:tic_tac_toe/data/models/game/game_model.dart';
import 'package:tic_tac_toe/data/models/game/game_round_model.dart';
import 'package:tic_tac_toe/data/models/game/game_setting_model.dart';
import 'package:tic_tac_toe/data/models/game/matrix_size_model.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/data/models/user/user_model.dart';
import 'package:tic_tac_toe/constants/settings.dart';

class ConnectionScreen extends StatefulWidget {
  final MatrixSize size;
  final int fee;
  final GameRound round;
  const ConnectionScreen(
      {super.key, required this.size, required this.fee, required this.round});
  static Route route(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    return GradientRouter(
        builder: (context) => BlocProvider(
              create: (context) => GameConnectionBloc(),
              child: ConnectionScreen(
                size: args['size'] as MatrixSize,
                fee: args['fee'] as int,
                round: args['round'] as GameRound,
              ),
            ));
  }

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  Timer? timer;

  /// Key of the game we created and are hosting. Stays null when we joined an
  /// existing game (in which case there is nothing for us to close on timeout).
  String? hostedGameKey;

  ValueNotifier<int> time =
      ValueNotifier(AppSettings.multiplayerConnectionSearchTime);

  /// True once the search has timed out without finding an opponent; the
  /// waiting screen then swaps its status text for a retry button instead of
  /// popping, so the player can search again without re-navigating.
  bool connectionFailed = false;

  @override
  void initState() {
    startConnection();
    super.initState();
  }

  void startConnection() {
    hostedGameKey = null;
    connectionFailed = false;
    time.value = AppSettings.multiplayerConnectionSearchTime;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (time.value == 0) {
        timer.cancel();

        ///Timer expired without an opponent: ask the bloc to close the game we
        ///are hosting. The retry button is shown once it confirms via
        ///[GameConnectionClosed].
        if (mounted && hostedGameKey != null) {
          context.read<GameConnectionBloc>().add(CloseGame(hostedGameKey!));
        }

        return;
      }
      time.value--;
    });
    context.read<GameConnectionBloc>().add(ConnectGame(
        player1: Player(
          playerId: context.read<AuthenticationBloc>().user!.userId,
          skinX: DatabaseService.instance.activeSkin.skinX,
          skinO: DatabaseService.instance.activeSkin.skinO,
          name: context.read<AuthenticationBloc>().user!.username,
          playerProfile: context.read<AuthenticationBloc>().user!.profilePic,
        ),
        size: widget.size,
        fee: widget.fee,
        round: widget.round));
  }

  void retryConnection() {
    timer?.cancel();
    setState(startConnection);
  }

  @override
  void dispose() {
    timer?.cancel();
    // Leaving the waiting screen (manual back, etc.): close the game we are
    // hosting so it can't be joined as a "ghost" after we're gone. closeGame is
    // a no-op when an opponent already joined or it was already closed (e.g. by
    // the connection timer), so this is safe to fire on every exit path.
    if (hostedGameKey != null) {
      DatabaseService.instance.closeGame(hostedGameKey!);
    }
    time.dispose();
    super.dispose();
  }

  String formatTime(int time) {
    final minutes = (time ~/ 60).toString().padLeft(2, '0');
    final seconds = (time % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<GameConnectionBloc, GameConnectionState>(
        listener: (context, state) async {
          if (state is GameConnectionWaiting) {
            ///Remember the game we are hosting so the timer can close it.
            hostedGameKey = state.gameKey;
          }
          if (state is GameConnectionSuccess) {
            GameModel gameModel =
                await DatabaseService.instance.getGame(state.gameKey);
            if (!context.mounted) return;

            Navigator.popAndPushNamed(context, AppRoutes.mazeScreen,
                arguments: MultiplayerGame(
                    settings: MultiplayerGameSetting(gameModel,
                        boardSize: gameModel.matrixSize)));
          }
          if (state is GameConnectionClosed) {
            setState(() {
              connectionFailed = true;
            });
          }
          if (state is GameConnectionInsufficientCoins) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(context.tr('notEnoughCoinsToPlay',
                      params: {'amount': '${state.required}'}))),
            );
            Navigator.pop(context);
          }
        },
        child: SizedBox(
          width: context.screenWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16)
                .copyWith(top: Platform.isIOS ? 30 : 0),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    CustomText(
                      context.tr('playWithRandom').toUpperCase(),
                      fontSize: context.font.xL,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomText(
                      context.tr('onlineMultiplayer'),
                      fontSize: context.font.medium,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    CustomImage(
                      AppIcons.dora4,
                      width: 150,
                      height: 200,
                      fit: BoxFit.none,
                    ),
                  ],
                ),
                buildEntryInfoContainer(context),
                buildPlayersContainer(context),
                SizedBox(
                  height: 15,
                ),
                buildTimerContainer(context),
                SizedBox(
                  height: 15,
                ),
                if (connectionFailed) ...[
                  CustomText(context.tr('failedToConnectTryAgain')),
                  SizedBox(
                    height: 15,
                  ),
                  CustomButton(
                    title: context.tr('reload'),
                    type: ButtonType.primary,
                    onTap: retryConnection,
                  ),
                ] else
                  CustomText(context.tr('connectingWithOpponents')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEntryInfoContainer(BuildContext context) {
    return Container(
      height: 105,
      width: context.screenWidth,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(
            color: context.color.onSurface.withAlpha(150),
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                CustomText(
                  context.tr('earnCoins'),
                  color: context.color.onSurface.withAlpha(100),
                ),
                Divider(
                  color: context.color.outline,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImage(
                      AppIcons.coin,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 6),
                    CustomText(
                      widget.fee.toString(),
                      fontSize: context.font.large,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            width: 1,
            color: context.color.outline,
          ),
          Expanded(
              flex: 3,
              child: Column(
                children: [
                  CustomText(
                    context.tr('gameMode'),
                    color: context.color.onSurface.withAlpha(100),
                  ),
                  Divider(
                    color: context.color.outline,
                    thickness: 1,
                  ),
                  Flexible(
                    child: MarqueeWidget(
                      child: CustomText(
                        widget.size.title.toString(),
                        fontSize: context.font.large,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildPlayersContainer(BuildContext context) {
    UserModel? user = context.read<AuthenticationBloc>().user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: FittedBox(
                fit: BoxFit.none,
                child: Column(
                  spacing: 5,
                  children: [
                    AvatarCard(
                      image: user?.profilePic ?? AppIcons.guest,
                      height: 90,
                      width: 90,
                    ),
                    SizedBox(
                      width: 90,
                      child: MarqueeWidget(
                        child: CustomText(
                          user!.username,
                          maxLines: 1,
                          ellipsis: true,
                        ),
                      ),
                    )
                  ],
                ))),
        CustomImage(
          AppIcons.versus,
        ),
        Expanded(
            child: FittedBox(
                fit: BoxFit.none,
                child: Column(
                  spacing: 5,
                  children: [
                    AvatarCard(
                      image: '',
                      height: 90,
                      width: 90,
                    ),
                    SizedBox(
                      width: 90,
                      child: CustomText(
                        context.tr('joiningSoon'),
                        maxLines: 1,
                        ellipsis: true,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ))),
      ],
    );
  }

  Widget buildTimerContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.color.onSurface.withAlpha(150),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            AppIcons.clock,
            width: 20,
            height: 20,
          ),
          SizedBox(
            width: 10,
          ),
          ValueListenableBuilder(
              valueListenable: time,
              builder: (context, value, child) {
                return CustomText(
                  formatTime(value),
                  fontSize: context.font.large,
                  fontWeight: FontWeight.w600,
                );
              }),
        ],
      ),
    );
  }
}
