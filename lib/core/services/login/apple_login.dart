import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:tic_tac_toe/core/services/login/login.dart';

class AppleLogin extends Login {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;

  @override
  void init() async {}

  @override
  Future<UserCredential?> login() async {
    try {
      final AuthorizationCredentialAppleID appleIdCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      oAuthProvider = OAuthProvider('apple.com');
      if (oAuthProvider != null) {
        credential = oAuthProvider!.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential!);

        if (userCredential.additionalUserInfo!.isNewUser) {
          final String givenName = appleIdCredential.givenName ?? "";
          final String familyName = appleIdCredential.familyName ?? "";

          await userCredential.user!
              .updateDisplayName("$givenName $familyName");
          await userCredential.user!.reload();
        }

        return userCredential;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
