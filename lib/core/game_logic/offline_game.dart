import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/core/game_logic/dora_ai.dart';
import 'package:tic_tac_toe/core/game_logic/game.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/data/bloc/game/game_bloc.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';

class OfflineGame extends Game {
  @override
  String get selfPlayerId => player1!.playerId;

  OfflineGame({required super.settings, this.difficulty = Difficulty.hard});

  /// Chosen by the player before the match; controls how sharply Dora plays.
  final Difficulty difficulty;
  final TicTacToeAI ai = TicTacToeAI();
  final int kDoraThinkMaxTime = 9;
  @override
  void onGameStart() async {
    super.onGameStart();
    player1 = Player(
        playerId: '0',
        skinX: DatabaseService.instance.activeSkin.skinX,
        name: 'You',
        skinO: DatabaseService.instance.activeSkin.skinO,
        activeSkinType: 'O',
        playerProfile:
            getContext()?.read<AuthenticationBloc>().user?.profilePic ?? '');
    player2 = Player(
        playerId: '1',
        skinX: DatabaseService.instance.activeSkin.skinX,
        name: 'Dora',
        skinO: DatabaseService.instance.activeSkin.skinO,
        activeSkinType: 'X',
        playerProfile: AppIcons.dora1);
    currentPlayer = [player1, player2][Random().nextInt(2)];

    // If Dora wins the coin toss she has to open the game. There's no human
    // move to trigger her through [onUpdate], and `restrictedMoves` locks the
    // board for the human while it's her turn, so kick off her move directly.
    if (currentPlayer == player2) {
      _playDoraMove();
    }
  }

  @override
  void onUpdate(int row, int column, Player player) async {
    // This fires for every applied move, including Dora's own. Only respond to
    // the human's move, otherwise Dora would loop on her own placement.
    if (player == player2) return;
    if (isBoardFull()) return;
    await _playDoraMove();
  }

  /// Computes Dora's best move for the current board and plays it after a short
  /// "thinking" pause. Driven both from the opening (see [onGameStart]) and as
  /// the reply to the human's move (see [onUpdate]).
  Future<void> _playDoraMove() async {
    final Map list = {
      player1?.playerId: player1!.activeSkinType,
      player2?.playerId: player2!.activeSkinType
    };

    final int position = ai.getBestMove(
        board
            .map((e) => e
                .map((e) => e.isBlank ? "" : list[e.playerId!] as String)
                .toList())
            .toList(),
        settings.boardSize,
        difficulty: difficulty);

    await Future.delayed(
        Duration(seconds: Random().nextInt(kDoraThinkMaxTime)));

    final int row = position ~/ settings.boardSize;
    final int column = position % settings.boardSize;
    addEvent(Move(row: row, column: column));
  }

  @override
  bool restrictedMoves = true;
}
