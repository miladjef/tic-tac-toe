import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/login/apple_login.dart';
import 'package:tic_tac_toe/core/services/login/google_login.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';

class AuthOptionsScreen extends StatefulWidget {
  final bool hideGuestOption;

  const AuthOptionsScreen({super.key, this.hideGuestOption = false});
  static Route route(RouteSettings settings) {
    final hideGuestOption = settings.arguments == true;
    return GradientRouter(
        builder: (context) =>
            AuthOptionsScreen(hideGuestOption: hideGuestOption));
  }

  @override
  State<AuthOptionsScreen> createState() => _AuthOptionsScreenState();
}

class _AuthOptionsScreenState extends State<AuthOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailedState) {
            final message = state.error is String
                ? context.tr(state.error as String)
                : context.tr('somethingWentWrongTryAgain');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }

          if (state is AuthenticatedState ||
              state is AuthenticatedAsGuestState) {
            Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
          }
        },
        child: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Spacer(
                  flex: 3,
                ),
                CustomImage(
                  AppIcons.doraIcon,
                  width: context.screenWidth,
                  height: 250,
                  fit: BoxFit.fitHeight,
                ),
                Spacer(
                  flex: 2,
                ),
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    final googleInProgress = state is SigninInProgressState;
                    final guestInProgress = state is GuestLoginInProgressState;
                    final anyInProgress = googleInProgress || guestInProgress;
                    return Column(
                      spacing: 16,
                      children: [
                        buildButton(context,
                            icon: AppIcons.google,
                            inProgress: googleInProgress,
                            onTap: anyInProgress
                                ? null
                                : () {
                                    context.read<AuthenticationBloc>().add(
                                        SigninEvent(
                                            authProvider: GoogleLogin()));
                                  },
                            title: context.tr('signInWithGoogle')),
                        // Apple only: Sign in with Google without an Apple
                        // equivalent fails App Store review (Guideline 4.8).
                        if (Platform.isIOS)
                          buildButton(context,
                              icon: AppIcons.apple,
                              iconColor: AppColors.white,
                              inProgress: googleInProgress,
                              onTap: anyInProgress
                                  ? null
                                  : () {
                                      context.read<AuthenticationBloc>().add(
                                          SigninEvent(
                                              authProvider: AppleLogin()));
                                    },
                              title: context.tr('signInWithApple')),
                        if (!widget.hideGuestOption)
                          buildButton(context,
                              icon: AppIcons.guestLogin,
                              inProgress: guestInProgress,
                              onTap: anyInProgress
                                  ? null
                                  : () {
                                      context
                                          .read<AuthenticationBloc>()
                                          .add(GuestLoginEvent());
                                    },
                              title: context.tr('playAsAGuest')),
                        buildButton(context,
                            icon: AppIcons.emailLogin,
                            onTap: anyInProgress
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.emailLoginScreen);
                                  },
                            title: context.tr('signInWithEmail')),
                      ],
                    );
                  },
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(
    BuildContext context, {
    String? title,
    String? icon,
    Color? iconColor,
    VoidCallback? onTap,
    bool inProgress = false,
  }) {
    return CustomButton(
      width: context.screenWidth,
      height: 52,
      inProgress: inProgress,
      customWidget: inProgress
          ? null
          : Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImage(
                  icon ?? "",
                  width: 40,
                  height: 40,
                  color: iconColor,
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: CustomText(
                    title ?? '',
                    fontSize: context.font.medium,
                    color: AppColors.white,
                    maxLines: 1,
                    ellipsis: true,
                  ),
                ),
              ],
            ),
      onTap: onTap,
    );
  }
}
