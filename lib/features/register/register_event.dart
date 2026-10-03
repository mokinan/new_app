part of 'register_bloc.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

final class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.password);
  final String password;
}

/// Clears a server-side email error as soon as the user edits the field.
final class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged();
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.password,
    this.phone,
  });

  final String businessName;
  final String ownerName;
  final String email;
  final String password;
  final String? phone;
}
