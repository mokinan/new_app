import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_cubit.dart';

class RegisterState extends Equatable {
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

  @override
  List<Object?> get props => [isLoading, error, fieldErrors, passwordStrength];
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._auth, this._session) : super(const RegisterState());

  final AuthRepository _auth;
  final SessionCubit _session;

  void passwordChanged(String password) =>
      emit(state.copyWith(passwordStrength: Validators.passwordStrength(password)));

  void emailChanged() {
    if (state.fieldErrors.containsKey('email')) {
      emit(state.copyWith(fieldErrors: {...state.fieldErrors}..remove('email')));
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
    emit(state.copyWith(isLoading: true, error: () => null, fieldErrors: const {}));
    try {
      final user = await _auth.register(
        name: ownerName,
        email: email,
        password: password,
        phone: (phone?.trim().isEmpty ?? true) ? null : phone,
        businessName: businessName,
      );
      _session.signedIn(user);
      if (!isClosed) emit(state.copyWith(isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          error: () => e.message,
          fieldErrors: {for (final MapEntry(:key, :value) in e.fieldErrors.entries) key: value.first},
        ),
      );
    }
  }
}
