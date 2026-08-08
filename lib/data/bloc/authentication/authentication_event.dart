// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class CheckAuthenticationEvent extends AuthenticationEvent {}

class SendForgotPasswordEmailEvent extends AuthenticationEvent {
  final String email;
  SendForgotPasswordEmailEvent({required this.email});
}

class SigninEvent extends AuthenticationEvent {
  final Login authProvider;
  SigninEvent({
    required this.authProvider,
  });
}

class GuestLoginEvent extends AuthenticationEvent {
  final GuestLogin guestLogin = GuestLogin();
  GuestLoginEvent();
}

/// Internal event fired by the live user stream so the authenticated state is
/// re-emitted with fresh score/coin/match values.
class _UserDataChangedEvent extends AuthenticationEvent {
  final UserModel user;
  _UserDataChangedEvent(this.user);
}
