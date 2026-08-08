class GamePosition {
  // final int row;
  // final int column;
  // final int indexValue;
  final String? playerId;
  final String? skin;

  bool get isBlank => playerId == null;

  GamePosition({
    // required this.row,
    // required this.column,
    // required this.indexValue,
    this.playerId,
    this.skin,
  });

  @override
  String toString() {
    return 'Player($playerId)';
  }
}
