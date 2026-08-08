import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class Login {
  FutureOr<void> init();
  LoginParameters? parameters;

  void setData(LoginParameters data) {
    parameters = data;
  }

  Future<UserCredential?> login();
}

abstract class LoginParameters {
  Map<String, dynamic> toMap();
}
