part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.isDarkMode, required this.locale});

  final bool isDarkMode;
  final Locale locale;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({bool? isDarkMode, Locale? locale}) =>
      SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode, locale: locale ?? this.locale);

  @override
  List<Object> get props => [isDarkMode, locale];
}
