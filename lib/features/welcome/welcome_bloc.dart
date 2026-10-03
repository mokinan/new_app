import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/services/preferences_service.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc(this._repo, this._preferences) : super(const WelcomeState()) {
    on<WelcomeStarted>((event, emit) async {
      // The repository never throws: it falls back to built-in slides.
      emit(state.copyWith(slides: await _repo.getSlides(), isLoading: false));
    });
    on<WelcomePageChanged>((event, emit) => emit(state.copyWith(page: event.page)));
    on<WelcomeFinished>((event, emit) async {
      await _preferences.setOnboarded(value: true);
      emit(state.copyWith(finished: true));
    });
  }

  final OnboardingRepository _repo;
  final PreferencesService _preferences;
}
