import 'package:tic_tac_toe/data/models/game/game_model.dart';

class GameSettings {
  final int boardSize;
  int? fee;

  GameSettings({required this.boardSize, this.fee});
}

class MultiplayerGameSetting extends GameSettings {
  final GameModel gameModel;
  MultiplayerGameSetting(this.gameModel, {required super.boardSize}) {
    super.fee = gameModel.entryFee;
  }
}
