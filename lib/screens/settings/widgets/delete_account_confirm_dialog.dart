import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/local_storage.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/core/services/login/google_login.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/screens/settings/widgets/reauthenticate_password_dialog.dart';

class DeleteAccountConfirmDialog {
  DeleteAccountConfirmDialog._();

  static Future<void> show(BuildContext context) {
    return UiUtils.showDialog(context,
        child: const _DeleteAccountConfirmDialog());
  }
}

class _DeleteAccountConfirmDialog extends StatefulWidget {
  const _DeleteAccountConfirmDialog();

  @override
  State<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<_DeleteAccountConfirmDialog> {
  bool _inProgress = false;
  String? _error;

  /// Re-verifies credentials right before the destructive delete, for
  /// providers Firebase can revoke with `requires-recent-login`. Doing this
  /// upfront (instead of reacting to that error after already wiping the
  /// user's DB data) avoids stranding an account whose data is gone but whose
  /// Auth user survives because the final `delete()` bounced. Returns false
  /// if the user backs out of the reauth prompt.
  Future<bool> _ensureFreshLogin(User user) async {
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;

    if (providerId == 'password') {
      final String? password = await UiUtils.showDialog(
        context,
        child: const ReauthenticatePasswordDialog(),
      );
      if (password == null || password.isEmpty) return false;
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
      return true;
    }

    if (providerId == 'google.com') {
      await GoogleLogin.ensureInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      await user.reauthenticateWithCredential(GoogleAuthProvider.credential(
        idToken: auth.idToken,
      ));
      return true;
    }

    if (providerId == 'apple.com') {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      await user.reauthenticateWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        ),
      );
      return true;
    }

    // Guest/anonymous sessions have no separate credential to re-verify.
    return true;
  }

  String _authErrorKey(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'incorrectEmailOrPassword';
      case 'user-disabled':
        return 'accountDisabled';
      case 'too-many-requests':
        return 'tooManyAttemptsTryLater';
      case 'network-request-failed':
        return 'networkErrorTryAgain';
      case 'requires-recent-login':
        return 'deleteAccountRequiresRecentLogin';
      default:
        return 'somethingWentWrongTryAgain';
    }
  }

  Future<void> _delete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _inProgress = true;
      _error = null;
    });

    try {
      if (!await _ensureFreshLogin(user)) {
        setState(() => _inProgress = false);
        return;
      }
      await DatabaseService.instance.deleteAccountData();
      await user.delete();
      try {
        await GoogleLogin.ensureInitialized();
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await LocalStorage.logoutUser();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.authOptionsScreen, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _inProgress = false;
        _error = context.tr(_authErrorKey(e.code));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _inProgress = false;
        _error = context.tr('somethingWentWrongTryAgain');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('deleteAccount'),
      hideCloseButton: true,
      buttons: [
        DialogButton(
          title: context.tr('no'),
          color: context.color.secondary,
          textColor: AppColors.white,
          onTap: _inProgress ? null : () => Navigator.pop(context),
        ),
        DialogButton(
          title: context.tr('yesDelete'),
          color: AppColors.white,
          textColor: AppColors.black,
          inProgress: _inProgress,
          onTap: _inProgress ? null : _delete,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              AppIcons.deleteAccountIllustration,
              width: 114,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            CustomText(
              context.tr('areYouSureDeleteAccount'),
              textAlign: TextAlign.center,
              fontSize: context.font.medium,
              color: context.color.onSurface.withAlpha(200),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              CustomText(
                _error!,
                textAlign: TextAlign.center,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
