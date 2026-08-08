enum AppTheme { light, dark }

enum ButtonType {
  shadow,
  primary,
  gradient,
}

enum AuthenticationType {
  apple,
  google,
  email,
  guest,
}

enum EmailLoginType { signin, signup }

enum GameConnection { created, joined }

/// How sharp Dora plays in offline games. Chosen by the player before an
/// offline match (see `DifficultySelectionDialog`) and consumed by
/// [TicTacToeAI.getBestMove] to decide how many heuristics she applies.
enum Difficulty { easy, medium, hard }
