part of 'welcome_bloc.dart';

sealed class WelcomeEvent {
  const WelcomeEvent();
}

final class WelcomeStarted extends WelcomeEvent {
  const WelcomeStarted();
}

final class WelcomePageChanged extends WelcomeEvent {
  const WelcomePageChanged(this.page);
  final int page;
}

/// Skip, or "start" on the last slide.
final class WelcomeFinished extends WelcomeEvent {
  const WelcomeFinished();
}
