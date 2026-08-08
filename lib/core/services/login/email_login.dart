import 'package:firebase_auth/firebase_auth.dart';
import 'package:tic_tac_toe/common/enums.dart';

import 'package:tic_tac_toe/core/services/login/login.dart';

class EmailLoginParameters extends LoginParameters {
  final String email;
  final String password;
  final String? username;
  final EmailLoginType type;

  EmailLoginParameters(
      {required this.email,
      required this.password,
      required this.type,
      this.username});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'type': type.name,
        'username': username,
      };
}

class EmailLogin extends Login {
  @override
  void init() {}

  @override
  Future<UserCredential?> login() async {
    UserCredential? userCredential;
    EmailLoginParameters payloadData = parameters as EmailLoginParameters;

    try {
      if (payloadData.type == EmailLoginType.signup) {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: payloadData.email,
          password: payloadData.password,
        );
        await userCredential.user?.updateDisplayName(payloadData.username);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: payloadData.email,
          password: payloadData.password,
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'emailAlreadyInUse';
        case 'invalid-email':
          throw 'enterValidEmail';
        case 'weak-password':
          throw 'passwordTooWeak';
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-credential':
          throw 'incorrectEmailOrPassword';
        case 'user-disabled':
          throw 'accountDisabled';
        case 'too-many-requests':
          throw 'tooManyAttemptsTryLater';
        case 'network-request-failed':
          throw 'networkErrorTryAgain';
        default:
          throw 'somethingWentWrongTryAgain';
      }
    }
  }
}
