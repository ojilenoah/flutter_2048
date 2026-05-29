import 'package:flutter_riverpod/flutter_riverpod.dart';

//The first milestone worth celebrating.
const celebrationThreshold = 2048;

//The milestone value currently being celebrated (0 = no celebration showing).
final celebrationProvider = StateProvider<int>((ref) => 0);

//The highest milestone (>= 2048) already celebrated this game, so each new
//milestone (2048, 4096, 8192, ...) celebrates exactly once.
final lastCelebratedProvider = StateProvider<int>((ref) => 0);
