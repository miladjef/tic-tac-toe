import 'dart:math';

import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/core/game_logic/game.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';

class PassNPlayGame extends Game {
  PassNPlayGame({required super.settings});

  @override
  void onGameStart() async {
    super.onGameStart();

    player1 = Player(
        playerId: '0',
        skinX: DatabaseService.instance.activeSkin.skinX,
        name: 'User1',
        skinO: DatabaseService.instance.activeSkin.skinO,
        activeSkinType: 'O',
        playerProfile: AppIcons.dora1);

    player2 = Player(
        playerId: '1',
        skinX: DatabaseService.instance.activeSkin.skinX,
        name: 'User2',
        skinO: DatabaseService.instance.activeSkin.skinO,
        activeSkinType: 'X',
        playerProfile: AppIcons.dora1);
    currentPlayer = [player1, player2][Random().nextInt(2)];
  }

  @override
  void onUpdate(int row, int column, Player player) async {}

  @override
  bool restrictedMoves = false;
}
