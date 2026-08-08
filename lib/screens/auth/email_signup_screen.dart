import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/validator.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/custom_textfield.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/services/login/email_login.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';

class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});
  static Route route(RouteSettings settings) {
    return GradientRouter(builder: (context) => const EmailSignupScreen());
  }

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onTapSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthenticationBloc>().add(SigninEvent(
        authProvider: EmailLogin()
          ..setData(EmailLoginParameters(
              email: _emailController.text,
              password: _passwordController.text.trim(),
              username: _usernameController.text.trim(),
              type: EmailLoginType.signup))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.screenHeight * 0.05),
                  CustomImage(
                    AppIcons.doraIcon,
                    width: context.screenWidth,
                    height: 200,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomText(
                    context.tr('signUp'),
                    fontSize: context.font.xXL,
                    color: AppColors.white,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    spacing: 24,
                    children: [
                      CustomTextField(
                        prefixIcon: Icons.email_outlined,
                        hintText: context.tr('email'),
                        controller: _emailController,
                        validator: (value) =>
                            Validator.validateEmail(context, value),
                      ),
                      CustomTextField(
                        prefixIcon: Icons.person_outline,
                        hintText: context.tr('username'),
                        controller: _usernameController,
                        validator: (value) =>
                            Validator.validateRequired(context, value),
                      ),
                      CustomTextField(
                        prefixIcon: Icons.lock_outline,
                        hintText: context.tr('password'),
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) =>
                            Validator.validatePassword(context, value),
                      ),
                      CustomTextField(
                        prefixIcon: Icons.lock_outline,
                        hintText: context.tr('confirmPassword'),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text.trim()) {
                            return context.tr('passwordsDoNotMatch');
                          }
                          return Validator.validatePassword(context, value);
                        },
                      ),
                      BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          final inProgress = state is SigninInProgressState;
                          return CustomButton(
                            onTap: inProgress ? null : _onTapSignUp,
                            title: context.tr('signUp'),
                            type: ButtonType.primary,
                            inProgress: inProgress,
                          );
                        },
                      ),
                      buildLoginTextLink()
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

  Widget buildLoginTextLink() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.tr('haveAnAccount'),
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: FontWeight.w500,
              color: context.color.onSurface.withAlpha(150),
            ),
          ),
          TextSpan(
            text: context.tr('signIn'),
            style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.emailLoginScreen);
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
}
