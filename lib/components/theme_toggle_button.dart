import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/theme_mode.dart';
import 'button.dart';

//Flips between light and dark mode; the choice is persisted. Reads the
//actual rendered brightness rather than the stored ThemeMode, so when the
//theme is following the OS (`ThemeMode.system`) the icon still reflects
//what the user is currently looking at.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return ButtonWidget(
      icon: isDark ? Icons.light_mode : Icons.dark_mode,
      onPressed: () =>
          ref.read(themeModeProvider.notifier).toggle(brightness),
    );
  }
}
