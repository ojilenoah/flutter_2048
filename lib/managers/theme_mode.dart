import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

//Holds the current light/dark choice and persists it across launches.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  static const _boxName = 'settingsBox';
  static const _key = 'themeMode';

  void _load() async {
    final box = await Hive.openBox(_boxName);
    if (box.get(_key) == 'dark') state = ThemeMode.dark;
  }

  void toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, state == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
