import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tic_tac_toe/core/services/login/login.dart';

class GuestLogin extends Login {
  @override
  FutureOr<void> init() async {}

  @override
  Future<UserCredential?> login() async {
    return await FirebaseAuth.instance.signInAnonymously();
  }
}
