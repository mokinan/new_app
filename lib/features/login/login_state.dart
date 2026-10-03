part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [isLoading, error];
}
