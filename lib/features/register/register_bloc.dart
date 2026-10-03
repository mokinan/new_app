import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._auth, this._session) : super(const RegisterState()) {
    on<RegisterPasswordChanged>(
      (event, emit) => emit(state.copyWith(passwordStrength: Validators.passwordStrength(event.password))),
    );
    on<RegisterEmailChanged>((event, emit) {
      if (state.fieldErrors.containsKey('email')) {
        emit(state.copyWith(fieldErrors: {...state.fieldErrors}..remove('email')));
      }
    });
    on<RegisterSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AuthRepository _auth;
  final SessionBloc _session;

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true, error: () => null, fieldErrors: const {}));
    try {
      final user = await _auth.register(
        name: event.ownerName,
        email: event.email,
        password: event.password,
        phone: (event.phone?.trim().isEmpty ?? true) ? null : event.phone,
        businessName: event.businessName,
      );
      _session.add(SessionSignedIn(user));
      emit(state.copyWith(isLoading: false));
    } on ApiException catch (e) {
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
