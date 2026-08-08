part of 'authentication_bloc.dart';

class AuthenticationState {}

class UnAuthorizedState extends AuthenticationState {}

class SigninInProgressState extends AuthenticationState {}

class GuestLoginInProgressState extends AuthenticationState {}

class AuthenticatedState extends AuthenticationState {
  final UserModel user;
  AuthenticatedState(this.user);
}

class AuthenticationFailedState<T> extends AuthenticationState {
  AuthenticationFailedState(this.error);
  final T error;
}

class AuthenticatedAsGuestState extends AuthenticationState {
  final UserModel user;
  AuthenticatedAsGuestState(this.user);
}

abstract class SendForgotPasswordEmailState extends AuthenticationState {}

class SendForgotPasswordEmailInProgressState
    extends SendForgotPasswordEmailState {}

class SendForgotPasswordEmailFailState extends SendForgotPasswordEmailState {
  final String error;
  SendForgotPasswordEmailFailState(this.error);
}

class SendForgotPasswordEmailSuccessState
    extends SendForgotPasswordEmailState {}
