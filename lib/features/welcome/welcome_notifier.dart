import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/data/models/onboarding_slide_model.dart';
import 'package:new_app/data/repositories/onboarding_repository.dart';
import 'package:new_app/features/settings/settings_notifier.dart';

class WelcomeNotifier extends SafeChangeNotifier {
  WelcomeNotifier(this._repo, this._settings);

  final OnboardingRepository _repo;
  final SettingsNotifier _settings;

  List<OnboardingSlideModel> slides = const [];
  bool isLoading = true;
  int page = 0;

  /// Onboarding completed; the page navigates to login.
  bool finished = false;

  bool get isLastPage => page == slides.length - 1;

  Future<void> load() async {
    // The repository never throws: it falls back to built-in slides.
    slides = await _repo.getSlides();
    isLoading = false;
    notifyListeners();
  }

  void pageChanged(int index) {
    page = index;
    notifyListeners();
  }

  Future<void> finish() async {
    await _settings.completeOnboarding();
    finished = true;
    notifyListeners();
  }
}
