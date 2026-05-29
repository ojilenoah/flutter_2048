import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'const/theme.dart';
import 'managers/theme_mode.dart';
import 'models/board_adapter.dart';

import 'game.dart';

void main() async {
  //Allow only portrait mode on Android & iOS
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  //Make sure Hive is initialized first and only after register the adapter.
  await Hive.initFlutter();
  Hive.registerAdapter(BoardAdapter());
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: '2048',
      theme: ThemeData.light().copyWith(extensions: const [GameTheme.light]),
      darkTheme: ThemeData.dark().copyWith(extensions: const [GameTheme.dark]),
      themeMode: themeMode,
      home: const Game(),
    );
  }
}
