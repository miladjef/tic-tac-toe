import 'package:firebase_auth/firebase_auth.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';

class Player {
  final String name;
  final String playerId;
  final String skinX;
  final String skinO;
  String? activeSkinType;
  final String playerProfile;

  Player({
    required this.playerId,
    required this.skinX,
    required this.name,
    required this.skinO,
    this.activeSkinType,
    required this.playerProfile,
  });

  void setActiveSkinType(String skinType) {
    activeSkinType = skinType;
  }

  bool get isYou {
    return playerId == FirebaseAuth.instance.currentUser?.uid;
  }

  String getSkin() {
    return UiUtils.getSkin(activeSkinType == 'O' ? skinO : skinX);
  }

  factory Player.fromJson(Map<dynamic, dynamic> json) {
    return Player(
      playerId: json['playerId'] as String,
      skinX: json['skinX'] as String,
      name: json['name'] as String,
      skinO: json['skinO'] as String,
      activeSkinType: json['active_skin_type'] as String,
      playerProfile: json['player_profile'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'skinX': skinX,
      'skinO': skinO,
      'name': name,
      'active_skin_type': activeSkinType,
      'player_profile': playerProfile,
    };
  }
}
