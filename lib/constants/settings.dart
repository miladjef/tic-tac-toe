import 'package:tic_tac_toe/data/models/game/game_round_model.dart';
import 'package:tic_tac_toe/data/models/game/matrix_size_model.dart';
import 'package:tic_tac_toe/data/models/more_game_model.dart';
import 'package:tic_tac_toe/data/models/skin/skin_model.dart';

class AppSettings {
  static const String appName = 'TicTacToe';

  static const String defaultLanguageCode = 'en';

  /// Shown on the Contact Us screen (see [LegalContent.contactUs]).
  static const String supportPhone = '9876543210';
  static const String supportEmail = 'abc@gmail.com';

  /// WebView games surfaced under the "Play More Games" menu item.
  /// Add an entry here to register a new game — no other changes needed.
  static const List<MoreGame> moreGames = [
    MoreGame(
      name: 'Hextris',
      url: 'https://hextris.io/',
      image:
          'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fhextris.webp?alt=media&token=302e901c-6c88-478f-bb0b-2736ed6e34ab',
    ),
    MoreGame(
      name: 'Clumsy Bird',
      url: 'https://ellisonleao.github.io/clumsy-bird/',
      image:
          'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fclumsy-bird-open-source-game.webp?alt=media&token=344ad51f-4ca5-40ae-b71e-0a863f51e9d4',
    ),
    MoreGame(
      name: 'Pacman',
      url: 'https://pacman.platzh1rsch.ch/',
      image:
          'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fpacman-html5-canvat.webp?alt=media&token=94941943-d863-4dbf-9467-a7fb53819c3f',
    ),
  ];

  static const List<int> multiplayerFees = [10, 25, 50, 100];
  static final List<MatrixSize> matrixSizes = <MatrixSize>[
    MatrixSize(size: 3, title: 'Classic Mode (3x3)'),
    MatrixSize(size: 4, title: 'Advanced Mode (4x4)'),
    MatrixSize(size: 5, title: 'Expert Mode (5x5)'),
  ];

  static List<GameRound> rounds = [
    GameRound(digit: 1, name: 'One'),
    GameRound(digit: 3, name: 'Three'),
    GameRound(digit: 5, name: 'Five'),
    GameRound(digit: 7, name: 'Seven'),
  ];

  static final Skin defaultSkin = skins.first;

  static const int multiplayerConnectionSearchTime = 60; // in seconds

  /// Leaderboard score awarded per finished match. Applied once per game at
  /// settlement (see [DatabaseService.setGameResult]); `matchplayed` always
  /// increments and `matchwon` increments for the winner. Tune freely.
  static const int scoreForWin = 10;
  static const int scoreForDraw = 5;
  static const int scoreForLoss = 0;

  /// Per-turn countdown (seconds). Larger boards have many more cells to read
  /// and plan over, so each step up in board size adds [_turnTimeStep] seconds
  /// on top of the [_baseTurnTime] used for the 3x3 classic board.
  /// 3x3 -> 20s, 4x4 -> 30s, 5x5 -> 40s.
  static const int _baseTurnTime = 20; // for the smallest (3x3) board
  static const int _turnTimeStep = 10; // extra seconds per size beyond classic

  static int turnDurationFor(int boardSize) {
    final int classicSize = matrixSizes.first.size; // 3
    final int steps = (boardSize - classicSize).clamp(0, 1 << 30);
    return _baseTurnTime + steps * _turnTimeStep;
  }

  /// Coin price charged for every purchasable (non-free) skin.
  static const int skinPrice = 500;

  static List<Skin> skins = [
    Skin(
      id: 'cross',
      name: 'Dora Cross',
      skinX: 'default_cross',
      skinO: 'default_circle',
      selectedStatus: 'active',
      price: 0,
    ),
    Skin(
      id: 'enhance',
      name: 'Dora Enhance',
      skinX: 'enhance_plus',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'box',
      name: 'Dora Box',
      skinX: 'box',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'pentagon',
      name: 'Dora Pentagon',
      skinX: 'pentagon',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'hex',
      name: 'Dora Hex',
      skinX: 'hex',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'shield',
      name: 'Dora Shield',
      skinX: 'shield',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'pyramid',
      name: 'Dora Pyramid',
      skinX: 'pyramid',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'crystal',
      name: 'Dora Crystal',
      skinX: 'crystal',
      skinO: 'default_circle',
      price: skinPrice,
    ),
    Skin(
      id: 'offer',
      name: 'Dora Offer',
      skinX: 'default_cross',
      skinO: 'default_circle',
      price: 0,
    ),
  ];
}
