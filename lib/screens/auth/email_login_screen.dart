// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/validator.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/custom_textfield.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/login/apple_login.dart';
import 'package:tic_tac_toe/core/services/login/email_login.dart';
import 'package:tic_tac_toe/core/services/login/google_login.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/screens/auth/widgets/forgot_password_dialog.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  static Route route(RouteSettings settings) {
    return GradientRouter(builder: (context) => const EmailLoginScreen());
  }

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _onTapSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthenticationBloc>().add(SigninEvent(
        authProvider: EmailLogin()
          ..setData(EmailLoginParameters(
              email: _emailController.text,
              password: _passwordController.text.trim(),
              type: EmailLoginType.signin))));
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    await UiUtils.showDialog(context, child: ForgotPasswordDialog());
  }

  void _onTapGoogleLogin() {
    context
        .read<AuthenticationBloc>()
        .add(SigninEvent(authProvider: GoogleLogin()));
  }

  void _onTapAppleLogin() {
    context
        .read<AuthenticationBloc>()
        .add(SigninEvent(authProvider: AppleLogin()));
  }

  void _onTapGuestLogin() {
    context.read<AuthenticationBloc>().add(GuestLoginEvent());
  }

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
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: context.screenHeight * 0.05,
                  ),
                  CustomImage(
                    AppIcons.doraIcon,
                    width: context.screenWidth,
                    fit: BoxFit.fitHeight,
                    height: 250,
                  ),
                  Column(
                    children: [
                      CustomText(
                        context.tr('signIn'),
                        fontSize: context.font.xXL,
                        color: AppColors.white,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hintText: context.tr('email'),
                        validator: (value) =>
                            Validator.validateEmail(context, value),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        hintText: context.tr('password'),
                        obscureText: true,
                        validator: (value) =>
                            Validator.validatePassword(context, value),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _showForgotPasswordDialog(context);
                            },
                            child: CustomText(
                              context.tr('forgotPasswordQuestion'),
                              fontSize: context.font.small,
                              color: AppColors.white,
                            ),
                          )),
                      SizedBox(
                        height: 24,
                      ),
                      BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          final inProgress = state is SigninInProgressState;
                          return CustomButton(
                            onTap: inProgress ? null : _onTapSignIn,
                            title: context.tr('signIn'),
                            type: ButtonType.primary,
                            inProgress: inProgress,
                          );
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      buildDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: BlocBuilder<AuthenticationBloc,
                            AuthenticationState>(
                          builder: (context, state) {
                            final googleInProgress =
                                state is SigninInProgressState;
                            final guestInProgress =
                                state is GuestLoginInProgressState;
                            final anyInProgress =
                                googleInProgress || guestInProgress;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 25,
                              children: [
                                buildGoogleLoginButton(
                                  onTap:
                                      anyInProgress ? null : _onTapGoogleLogin,
                                  inProgress: googleInProgress,
                                ),
                                // Apple only: Sign in with Google without an
                                // Apple equivalent fails App Store review
                                // (Guideline 4.8).
                                if (Platform.isIOS)
                                  buildAppleLoginButton(
                                    onTap:
                                        anyInProgress ? null : _onTapAppleLogin,
                                    inProgress: googleInProgress,
                                  ),
                                buildGuestLoginButton(
                                  onTap:
                                      anyInProgress ? null : _onTapGuestLogin,
                                  inProgress: guestInProgress,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      buildCreateAccountLink()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCreateAccountLink() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.tr('dontHaveAnAccount'),
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: FontWeight.w500,
              color: context.color.onSurface.withAlpha(150),
            ),
          ),
          TextSpan(
            text: context.tr('register'),
            style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.emailSignupScreen);
              },
          ),
        ],
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildGoogleLoginButton(
      {VoidCallback? onTap, bool inProgress = false}) {
    return GestureDetector(
      onTap: onTap,
      child: InnerShadowContainer(
        width: 50,
        height: 50,
        child: inProgress ? buildLoader() : CustomImage(AppIcons.google),
      ),
    );
  }

  Widget buildAppleLoginButton({VoidCallback? onTap, bool inProgress = false}) {
    return GestureDetector(
      onTap: onTap,
      child: InnerShadowContainer(
        width: 50,
        height: 50,
        child: inProgress
            ? buildLoader()
            : CustomImage(AppIcons.apple, color: AppColors.white),
      ),
    );
  }

  Widget buildGuestLoginButton({VoidCallback? onTap, bool inProgress = false}) {
    return GestureDetector(
      onTap: onTap,
      child: InnerShadowContainer(
        width: 50,
        height: 50,
        child: inProgress ? buildLoader() : CustomImage(AppIcons.guestLogin),
      ),
    );
  }

  Widget buildLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.color.onSurface,
      ),
    );
  }

  Widget buildDivider() {
    var divider = Container(
      height: 1.5,
      color: context.color.outline,
    );
    return Row(
      spacing: 14,
      children: [
        Expanded(
          child: divider,
        ),
        Text(context.tr('or')),
        Expanded(
          child: divider,
        ),
      ],
    );
  }
}
