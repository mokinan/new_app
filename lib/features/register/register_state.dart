part of 'register_bloc.dart';

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
