import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';

@immutable
class WelcomeState {
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
}

class WelcomeNotifier extends Notifier<WelcomeState> {
  @override
  WelcomeState build() {
    Future.microtask(_load);
    return const WelcomeState();
  }

  Future<void> _load() async {
    // The repository never throws: it falls back to built-in slides.
    final slides = await ref.read(onboardingRepositoryProvider).getSlides();
    if (ref.mounted) state = state.copyWith(slides: slides, isLoading: false);
  }

  void pageChanged(int page) => state = state.copyWith(page: page);

  Future<void> finish() async {
    await ref.read(preferencesServiceProvider).setOnboarded(value: true);
    if (ref.mounted) state = state.copyWith(finished: true);
  }
}

/// `autoDispose`: the state is discarded when the page closes.
final welcomeProvider = NotifierProvider.autoDispose<WelcomeNotifier, WelcomeState>(WelcomeNotifier.new);
