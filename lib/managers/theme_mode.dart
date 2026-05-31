import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

//Holds the current light/dark choice and persists it across launches.
//Defaults to `system`, which makes MaterialApp follow the OS / browser
//preference. The very first time the user taps the toggle, the choice
//becomes explicit (light or dark) and is saved.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _boxName = 'settingsBox';
  static const _key = 'themeMode';

  void _load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get(_key);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'light') {
      state = ThemeMode.light;
    }
    //Anything else (null, 'system') leaves us on ThemeMode.system.
  }

  //Flip between explicit light and dark. If we're currently on `system`,
  //resolve to the *opposite* of what the user is seeing right now using
  //the supplied current brightness, so the tap always visibly changes
  //the theme.
  void toggle(Brightness currentBrightness) async {
    final next =
        currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
