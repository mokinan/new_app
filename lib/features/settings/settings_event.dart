part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsDarkModeToggled extends SettingsEvent {
  const SettingsDarkModeToggled();
}

final class SettingsLocaleChanged extends SettingsEvent {
  const SettingsLocaleChanged(this.languageCode);
  final String languageCode;
}
