import 'package:tic_tac_toe/data/models/game/game_position_model.dart';
import 'package:tic_tac_toe/data/models/game/player_model.dart';

extension GameBoardExtension on List<List<GamePosition>> {
  bool move({required int x, required int y, required Player player}) {
    if (!this[x][y].isBlank) {
      return false;
    }
    this[x][y] = GamePosition(
      // row: x,
      // column: y,
      // indexValue: this[x][y].indexValue,
      playerId: player.playerId,
      skin: player.activeSkinType == 'X' ? player.skinX : player.skinO,
    );
    return true;
  }

////This will give cross element of the board. like 1 will return row 1 and column 1
  GamePosition diagonal(int index) {
    return this[index][index];
  }

  GamePosition diagonalFromEnd(int index) {
    return this[(length - 1) - index][index];
  }
}
