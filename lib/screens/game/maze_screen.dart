import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/convert_number.dart';
import 'package:tic_tac_toe/common/countdown.dart';
import 'package:tic_tac_toe/constants/settings.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/banner_ad_widget.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/game_logic/board_offsets.dart';
import 'package:tic_tac_toe/core/game_logic/game.dart';
import 'package:tic_tac_toe/core/game_logic/multiplayer_game.dart';
import 'package:tic_tac_toe/core/services/sound_service.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/data/bloc/game/game_bloc.dart';
import 'package:tic_tac_toe/data/models/game/game_position_model.dart';
import 'package:tic_tac_toe/data/models/game/game_setting_model.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';
import 'package:tic_tac_toe/screens/game/widgets/draw_dialog.dart';
import 'package:tic_tac_toe/screens/game/widgets/game_over_dialog.dart';
import 'package:tic_tac_toe/screens/game/widgets/line_animation.dart';
import 'package:tic_tac_toe/screens/game/widgets/next_round_dialog.dart';
import 'package:tic_tac_toe/screens/game/widgets/players_profile_widget.dart';
import 'package:tic_tac_toe/screens/game/widgets/tile_box_widget.dart';

class MazeScreen extends StatefulWidget {
  final Game game;

  const MazeScreen({
    super.key,
    required this.game,
  });
  static Route route(RouteSettings settings) {
    final Game game = settings.arguments as Game;
    return GradientRouter(
        builder: (context) => BlocProvider(
              create: (context) => GameBloc(GameState(game)),
              child: MazeScreen(
                game: game,
              ),
            ));
  }

  @override
  State<MazeScreen> createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen>
    with SingleTickerProviderStateMixin {
  late final int _boardSize = widget.game.settings.boardSize;
  List<Offset> offsets = [];
  late final LineAnimationController _controller = LineAnimationController();
  late BoardOffsets boardOffsets = BoardOffsets(boardSize: _boardSize);

  /// The Stack that holds both the board and the winning-line overlay. Tile
  /// centres are converted into this box's local space so the line aligns.
  final GlobalKey _boardAreaKey = GlobalKey();
  int? currentRound;

  /// The winner of the round that just ended, captured from GameOverState
  /// before the NextRoundState transition (which carries no winner data of
  /// its own) so NextRoundDialog can announce the right player. Null means
  /// the round was tied.
  Player? _lastRoundWinner;
  bool _lastRoundWasTie = false;
  bool _soundOn = SoundService.isEnabled;
  final Object _soundSession = Object();

  /// Turn timer scales with the board: bigger boards give players more time to
  /// read the grid and plan a move (see [AppSettings.turnDurationFor]).
  late final int _turnDuration = AppSettings.turnDurationFor(_boardSize);
  late final Countdown countdown = Countdown(_turnDuration);
  @override
  void initState() {
    widget.game.setContext(context);
    widget.game.countdown = countdown;

    SoundService.playBackgroundMusic(_soundSession);

    countdown.current.addListener(() {
      if (countdown.current.value == 0 && isYourTurn(widget.game)) {
        // Route through the same GameOverEvent -> GameOverState path as a
        // real board win so the timeout also gets the win animation +
        // GameOverDialog (with its replay button) instead of being silently
        // swallowed by Game.onGameOver's no-op default.
        widget.game.addEvent(GameOverEvent(
          winner: widget.game.opponent,
          gameOverRow: null,
          gameOverColumn: null,
        ));
      }
    });
    countdown.onTimerEnd(
      () {},
    );

    if (!widget.game.initialized) {
      widget.game.onGameStart();
    }

    setState(() {});

    assert(
        widget.game.player1 != null &&
            widget.game.player2 != null &&
            widget.game.currentPlayer != null,
        'Please set player 1 and player2 and current player');

    if (widget.game is MultiplayerGame) {
      currentRound = (widget.game.settings as MultiplayerGameSetting)
              .gameModel
              .currentRound +
          1;
      setState(() {});
    }

    countdown.start();

    super.initState();
  }

  bool isYourTurn(Game game) {
    if (!game.restrictedMoves) {
      return true;
    }

    return game.selfPlayerId != null &&
        game.selfPlayerId == game.currentPlayer?.playerId;
  }

  /// Matches the default skin colours: X is pink, O is blue.
  static const Color _xSignColor = Color(0xFFFF2D95);
  static const Color _oSignColor = Color(0xFF00A0FF);

  void _startGameOverAnimation(GameOverState state) {
    // Offsets are filled lazily once the grid has laid out; if they aren't ready
    // yet, skip rather than risk a range error indexing into them.
    if (boardOffsets.offsets.length < _boardSize * _boardSize) return;

    final Color lineColor =
        state.winner.activeSkinType == 'O' ? _oSignColor : _xSignColor;

    if (state.gameOverColumn != null) {
      _controller.setAnimation(
        boardOffsets.getColumnStartOffset(state.gameOverColumn!),
        boardOffsets.getColumnEndOffset(state.gameOverColumn!),
        color: lineColor,
      );
    } else if (state.gameOverRow != null) {
      _controller.setAnimation(
        boardOffsets.getRowStartOffset(state.gameOverRow!),
        boardOffsets.getRowEndOffset(state.gameOverRow!),
        color: lineColor,
      );
    } else if (state.diagonal == WinDiagonal.main) {
      _controller.setAnimation(
        boardOffsets.getMainDiagonalStart(),
        boardOffsets.getMainDiagonalEnd(),
        color: lineColor,
      );
    } else if (state.diagonal == WinDiagonal.anti) {
      _controller.setAnimation(
        boardOffsets.getAntiDiagonalStart(),
        boardOffsets.getAntiDiagonalEnd(),
        color: lineColor,
      );
    }
  }

  Size? gridSize;

  bool hasNextRound() {
    if (widget.game is MultiplayerGame) {
      MultiplayerGameSetting setting =
          (widget.game.settings as MultiplayerGameSetting);
      return (setting.gameModel.rounds - 1) > setting.gameModel.currentRound;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    countdown.dispose();
    widget.game.onDispose();
    SoundService.stopBackgroundMusic(_soundSession);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    widget.game.setContext(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _boardAreaKey,
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: const BannerAdWidget(),
          body: BlocConsumer<GameBloc, GameState>(
            listener: (context, state) async {
              if (state is NextRoundState) {
                // Drop the previous round's winning line before the fresh
                // board appears under the dialog.
                _controller.clear();
                UiUtils.showDialog(
                  context,
                  child: NextRoundDialog(
                    player1: widget.game.player1!,
                    player2: widget.game.player2!,
                    round: state.round,
                    winner: _lastRoundWasTie ? null : _lastRoundWinner,
                  ),
                );
                currentRound = state.round + 1;
                setState(() {});
              }
              if (state is GameOverState) {
                _lastRoundWinner = state.winner;
                _lastRoundWasTie = false;
                _startGameOverAnimation(state);
                SoundService.playWin();

                final bool isFinalRound = !hasNextRound();

                try {
                  await widget.game.onGameOver(
                      state.winner, state.gameOverRow, state.gameOverColumn,
                      diagonal: state.diagonal);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(context.tr('somethingWentWrongTryAgain'))));
                  }
                }

                await Future.delayed(
                  Duration(seconds: 3),
                );

                if (!context.mounted) return;
                if (isFinalRound) {
                  UiUtils.showDialog(context,
                      child: GameOverDialog(
                        game: widget.game,
                        isMultiplayer: widget.game is MultiplayerGame,
                        entryFee: widget.game.settings.fee,
                        winner: state.winner,
                      ),
                      dismissible: false);
                }
              }
              if (state is GameDrawState) {
                _lastRoundWasTie = true;
                // Capture the final-round decision BEFORE onGameDraw advances
                // the round (same race as the GameOverState branch above).
                final bool isFinalRound = !hasNextRound();

                try {
                  await widget.game.onGameDraw();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(context.tr('somethingWentWrongTryAgain'))));
                  }
                }

                await Future.delayed(
                  Duration(seconds: 3),
                );

                if (!context.mounted) return;
                if (isFinalRound) {
                  UiUtils.showDialog(context,
                      child: DrawDialog(
                        game: widget.game,
                        player1: widget.game.player1!,
                        player2: widget.game.player2!,
                        isMultiplayer: widget.game is MultiplayerGame,
                        entryFee: widget.game.settings.fee,
                      ),
                      dismissible: false);
                }
              }
              if (state is PlayerMoveState) {
                widget.game.onUpdate(state.row, state.column, state.player);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0)
                    .copyWith(top: Platform.isIOS ? 30 : 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 14,
                    ),
                    buildInformationHeader(
                        context,
                        state.game.currentPlayer?.playerId ==
                            state.game.selfPlayerId),
                    SizedBox(
                      height: 20,
                    ),
                    if (currentRound != null) ...{
                      CustomText(context.tr('currentRound',
                          params: {'round': '${currentRound!}'})),
                    },
                    Expanded(
                      child: Center(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _boardSize * _boardSize,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            crossAxisCount: _boardSize,
                          ),
                          itemBuilder: (context, index) {
                            final int row = index ~/ _boardSize;
                            final int column = index % _boardSize;

                            final GamePosition currentPosition =
                                state.game.board[row][column];

                            Future.delayed(Duration(milliseconds: 900), () {
                              if (!context.mounted) return;
                              final referenceBox = _boardAreaKey.currentContext
                                  ?.findRenderObject() as RenderBox?;
                              boardOffsets.fillOffsetIfEmpty(
                                  context, referenceBox);
                            });
                            return GestureDetector(
                              onTap: () {
                                if (!currentPosition.isBlank) {
                                  return;
                                }
                                if (!isYourTurn(state.game)) {
                                  return;
                                }

                                SoundService.playClick();
                                context
                                    .read<GameBloc>()
                                    .add(Move(row: row, column: column));
                              },
                              child: TileBoxWidget(
                                child: currentPosition.skin != null
                                    ? CustomImage(
                                        UiUtils.getSkin(currentPosition.skin!),
                                        width: 50,
                                        height: 50,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    PlayersProfileWidget(
                        player1: widget.game.player1,
                        currentPlayer: widget.game.currentPlayer,
                        player2: widget.game.player2),
                    if (widget.game.showNote) ...[
                      SizedBox(
                        height: 35,
                      ),
                      CustomText(
                        widget.game.note,
                        color: context.color.onSurface.withAlpha(100),
                        fontWeight: FontWeight.w400,
                      )
                    ]
                  ],
                ),
              );
            },
          ),
        ),
        // Winning-line overlay. IgnorePointer so it never eats board taps;
        // the tile offsets are corrected for the SafeArea inset so the line
        // lands on the tiles.
        IgnorePointer(child: AnimatedLine(controller: _controller)),
      ],
    );
  }

  Widget buildInformationHeader(BuildContext context, bool isYourMove) {
    return Column(
      children: [
        Row(
          children: [
            if (widget.game.restrictedMoves)
              Flexible(
                child: CustomText(
                  isYourMove
                      ? context.tr('yourMove')
                      : context.tr('opponentMove'),
                  maxLines: 1,
                  ellipsis: true,
                ),
              ),
            Spacer(),
            ValueListenableBuilder(
              valueListenable: countdown.current,
              builder: (context, value, _) {
                return CustomText(context.tr('timeLabel',
                    params: {'time': value.toString().padLeft(3, '0')}));
              },
            ),
          ],
        ),
        SizedBox(
          height: 4,
        ),
        ValueListenableBuilder(
            valueListenable: countdown.current,
            builder: (context, value, c) {
              return SizedBox(
                height: 4,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey.shade200,
                    ),
                    LayoutBuilder(builder: (context, c) {
                      double minifiedValue = ConvertNumber.inRange(
                          currentValue: value.toDouble(),
                          minValue: 0,
                          maxValue: _turnDuration.toDouble(),
                          newMaxValue: 0,
                          newMinValue: 1);

                      return AnimatedContainer(
                        curve: Curves.linear,
                        width: c.maxWidth * (1 - minifiedValue),
                        duration: minifiedValue == 0
                            ? Duration.zero
                            : Duration(seconds: 1),
                        decoration: BoxDecoration(
                            color: Color.lerp(context.color.secondary,
                                Colors.red, minifiedValue)),
                      );
                    })
                  ],
                ),
              );
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          spacing: 25,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: context.color.onSurface.withAlpha(150)),
                ),
                child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    int coin = 0;
                    if (state is AuthenticatedState) {
                      coin = state.user.coin ?? 0;
                    } else if (state is AuthenticatedAsGuestState) {
                      coin = state.user.coin ?? 0;
                    }
                    return CustomText(
                      context.tr('yourCoin', params: {'amount': '$coin'}),
                      fontWeight: FontWeight.bold,
                    );
                  },
                ),
              ),
            ),
            if (widget.game.settings.fee != null)
              Expanded(
                flex: 2,
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: context.color.onSurface,
                    ),
                    child: CustomText(
                        context.tr('entryCoin',
                            params: {'fee': '${widget.game.settings.fee}'}),
                        fontWeight: FontWeight.bold,
                        color: context.color.onInverseSurface)),
              ),
            FittedBox(
                fit: BoxFit.none,
                child: GestureDetector(
                  onTap: () {
                    final bool next = !_soundOn;
                    SoundService.setEnabled(next);
                    setState(() => _soundOn = next);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: context.color.onSurface,
                        border: Border.all(
                            color: context.color.onSurface.withAlpha(150)),
                      ),
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        _soundOn ? Icons.volume_up : Icons.volume_off,
                        color: context.color.onInverseSurface,
                        size: 28,
                      )),
                ))
          ],
        )
      ],
    );
  }
}
