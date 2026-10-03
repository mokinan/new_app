import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/features/session/session_notifier.dart';

@immutable
class LoginState {
  const LoginState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;
}

/// On success it only updates the session: the router redirects to home.
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    state = const LoginState(isLoading: true);
    try {
      final user = await ref.read(authRepositoryProvider).login(email: email, password: password);
      ref.read(sessionProvider.notifier).signedIn(user);
      if (ref.mounted) state = const LoginState();
    } on ApiException catch (e) {
      if (ref.mounted) state = LoginState(error: e.message);
    }
  }
}

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
