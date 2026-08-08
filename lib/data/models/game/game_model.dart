import 'dart:math';

import 'package:tic_tac_toe/data/models/game/player_model.dart';

// Enum for game status
enum GameStatus { waiting, inProgress, completed, closed }

enum PlayerTurn { player1, player2 }

enum GameResult { player1, player2, draw, notDeclared }

class GameModel {
  String? gameKey;
  final GameStatus status;
  final Player player1;
  final Player? player2;
  final List<List<String>> board;
  final PlayerTurn currentTurn;
  final GameResult result;
  final int matrixSize;
  final int rounds;
  int currentRound;
  final List<String> roundResult;
  final int entryFee;

  int? timeCreated = DateTime.now().millisecondsSinceEpoch;

  ///We will add the document key of the firebase to the current game to this game key element
  void setGameKey(String key) {
    gameKey = key;
  }

  factory GameModel.createNew({
    required Player player1,
    required int matrixSize,
    required int entryFee,
    required int rounds,
  }) {
    int currentTurn = Random().nextInt(2);
    int skinType = Random().nextInt(2);
    player1.setActiveSkinType(['X', 'O'][skinType]);
    return GameModel(
        status: GameStatus.waiting,
        player1: player1,
        player2: null,
        board: List.generate(
            matrixSize, (index) => List.generate(matrixSize, (index) => "")),
        currentTurn: [PlayerTurn.player1, PlayerTurn.player2][currentTurn],
        result: GameResult.notDeclared,
        entryFee: entryFee,
        matrixSize: matrixSize,
        rounds: rounds,
        currentRound: 0,
        roundResult: <String>[]);
  }

  GameModel(
      {required this.status,
      required this.player1,
      required this.player2,
      required this.board,
      required this.currentTurn,
      required this.result,
      required this.entryFee,
      required this.matrixSize,
      required this.rounds,
      required this.currentRound,
      required this.roundResult});

  factory GameModel.fromJson(Map<dynamic, dynamic> json) {
    return GameModel(
        status: GameStatus.values.byName(json['status']),
        player1: Player.fromJson(json['player1']),
        player2:
            json['player2'] != null ? Player.fromJson(json['player2']) : null,
        board: (json['board'] as List<dynamic>)
            .map((row) => List<String>.from(row))
            .toList(),
        currentTurn: PlayerTurn.values.byName(json['current_turn']),
        result: GameResult.values.byName(json['result']),
        entryFee: json['entry_fee'],
        matrixSize: json['matrix_size'],
        roundResult: json['round_result'] ?? <String>[],
        rounds: json['rounds'],
        currentRound: json['current_round'])
      ..setGameKey(json['game_key']);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'player1': player1.toJson(),
      'player2': null,
      'board': board.map((row) => row).toList(),
      'current_turn': currentTurn.name,
      'matrix_size': matrixSize,
      'rounds': rounds,
      'entry_fee': entryFee,
      'result': result.name,
      'time_created': timeCreated,
      'game_key': gameKey,
      'round_result': roundResult,
      'current_round': currentRound
    };
  }

  @override
  String toString() {
    return 'Game(status: $status, player1: $player1, player2: $player2, board: $board, currentTurn: $currentTurn, result: $result)';
  }
}
