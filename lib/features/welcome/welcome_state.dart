part of 'welcome_bloc.dart';

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
