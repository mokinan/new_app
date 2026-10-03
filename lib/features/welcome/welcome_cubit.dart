import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/settings/settings_cubit.dart';

class WelcomeState extends Equatable {
  const WelcomeState({this.slides = const [], this.isLoading = true, this.page = 0, this.finished = false});

  final List<OnboardingSlideModel> slides;
  final bool isLoading;
  final int page;

  /// Onboarding completed; the page navigates to login.
  final bool finished;

  bool get isLastPage => page == slides.length - 1;

  WelcomeState copyWith({List<OnboardingSlideModel>? slides, bool? isLoading, int? page, bool? finished}) =>
      WelcomeState(
        slides: slides ?? this.slides,
        isLoading: isLoading ?? this.isLoading,
        page: page ?? this.page,
        finished: finished ?? this.finished,
      );

  @override
  List<Object> get props => [slides, isLoading, page, finished];
}

class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit(this._repo, this._settings) : super(const WelcomeState());

  final OnboardingRepository _repo;
  final SettingsCubit _settings;

  Future<void> load() async {
    // The repository never throws: it falls back to built-in slides.
    final slides = await _repo.getSlides();
    if (!isClosed) emit(state.copyWith(slides: slides, isLoading: false));
  }

  void pageChanged(int page) => emit(state.copyWith(page: page));

  Future<void> finish() async {
    await _settings.completeOnboarding();
    if (!isClosed) emit(state.copyWith(finished: true));
  }
}
