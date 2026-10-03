import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/features/session/session_notifier.dart';

@immutable
class RegisterState {
  const RegisterState({this.isLoading = false, this.error, this.fieldErrors = const {}, this.passwordStrength = 0});

  final bool isLoading;
  final String? error;

  /// Server-side field errors (e.g. email already taken), keyed by field.
  final Map<String, String> fieldErrors;
  final int passwordStrength;

  RegisterState copyWith({
    bool? isLoading,
    String? Function()? error,
    Map<String, String>? fieldErrors,
    int? passwordStrength,
  }) => RegisterState(
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error() : this.error,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    passwordStrength: passwordStrength ?? this.passwordStrength,
  );
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  void passwordChanged(String password) =>
      state = state.copyWith(passwordStrength: Validators.passwordStrength(password));

  void emailChanged() {
    if (state.fieldErrors.containsKey('email')) {
      state = state.copyWith(fieldErrors: {...state.fieldErrors}..remove('email'));
    }
  }

  Future<void> submit({
    required String businessName,
    required String ownerName,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: () => null, fieldErrors: const {});
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(
            name: ownerName,
            email: email,
            password: password,
            phone: (phone?.trim().isEmpty ?? true) ? null : phone,
            businessName: businessName,
          );
      ref.read(sessionProvider.notifier).signedIn(user);
      if (ref.mounted) state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
        fieldErrors: {for (final MapEntry(:key, :value) in e.fieldErrors.entries) key: value.first},
      );
    }
  }
}

final registerProvider = NotifierProvider.autoDispose<RegisterNotifier, RegisterState>(RegisterNotifier.new);
