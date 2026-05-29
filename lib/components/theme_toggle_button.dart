import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/theme_mode.dart';
import 'button.dart';

//Flips between light and dark mode; the choice is persisted.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return ButtonWidget(
      icon: isDark ? Icons.light_mode : Icons.dark_mode,
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
    );
  }
}
