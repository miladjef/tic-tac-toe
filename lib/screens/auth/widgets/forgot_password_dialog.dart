import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/validator.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_textfield.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is SendForgotPasswordEmailSuccessState) {
          Navigator.pop(context);
        }
        if (state is SendForgotPasswordEmailFailState) {
          setState(() => _errorText = state.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: CustomDialogBox(
              title: context.tr('forgotPassword'),
              buttons: [
                DialogButton(
                    color: Colors.transparent,
                    title: context.tr('cancel'),
                    onTap: state is SendForgotPasswordEmailInProgressState
                        ? null
                        : () => Navigator.pop(context)),
                DialogButton(
                    title: context.tr('sendEmail'),
                    inProgress: state is SendForgotPasswordEmailInProgressState,
                    onTap: state is SendForgotPasswordEmailInProgressState
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            setState(() => _errorText = null);
                            context.read<AuthenticationBloc>().add(
                                SendForgotPasswordEmailEvent(
                                    email: _emailController.text.trim()));
                          })
              ],
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      hintText: context.tr('enterYourEmail'),
                      validator: (value) =>
                          Validator.validateEmail(context, value),
                      controller: _emailController,
                    ),
                    if (_errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
