part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionSignedIn extends SessionEvent {
  const SessionSignedIn(this.user);
  final UserModel user;
}

final class SessionLogoutRequested extends SessionEvent {
  const SessionLogoutRequested();
}

/// Sent by `AuthInterceptor` when the refresh token is rejected.
final class SessionExpired extends SessionEvent {
  const SessionExpired();
}
