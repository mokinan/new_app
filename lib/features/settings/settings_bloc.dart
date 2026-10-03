import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/services/preferences_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Theme and language, persisted through [PreferencesService].
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._prefs) : super(SettingsState(isDarkMode: _prefs.isDarkMode, locale: Locale(_prefs.locale))) {
    on<SettingsDarkModeToggled>((event, emit) async {
      emit(state.copyWith(isDarkMode: !state.isDarkMode));
      await _prefs.setDarkMode(value: state.isDarkMode);
    });
    on<SettingsLocaleChanged>((event, emit) async {
      emit(state.copyWith(locale: Locale(event.languageCode)));
      await _prefs.setLocale(event.languageCode);
    });
  }

  final PreferencesService _prefs;
}
