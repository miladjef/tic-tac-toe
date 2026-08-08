import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/local_storage.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/login/google_login.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class LogoutConfirmDialog {
  LogoutConfirmDialog._();

  static Future<void> show(BuildContext context) {
    return UiUtils.showDialog(context, child: const _LogoutConfirmDialog());
  }
}

class _LogoutConfirmDialog extends StatefulWidget {
  const _LogoutConfirmDialog();

  @override
  State<_LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<_LogoutConfirmDialog> {
  bool _inProgress = false;

  Future<void> _logout() async {
    setState(() => _inProgress = true);
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleLogin.ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await LocalStorage.logoutUser();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.authOptionsScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('logoutAccount'),
      hideCloseButton: true,
      buttons: [
        DialogButton(
          title: context.tr('no'),
          color: context.color.secondary,
          textColor: AppColors.black,
          onTap: _inProgress ? null : () => Navigator.pop(context),
        ),
        DialogButton(
          title: context.tr('yesLogout'),
          color: AppColors.white,
          textColor: AppColors.black,
          inProgress: _inProgress,
          onTap: _inProgress ? null : _logout,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              AppIcons.logoutAccountIllustration,
              width: 114,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            CustomText(
              context.tr('areYouSureLogout'),
              textAlign: TextAlign.center,
              fontSize: context.font.medium,
              color: context.color.onSurface.withAlpha(200),
            ),
          ],
        ),
      ),
    );
  }
}
