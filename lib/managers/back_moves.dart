import 'package:flutter_riverpod/flutter_riverpod.dart';

//Number of back (undo) moves currently available to the player.
//Defaults to 1 back move (the always-available undo of your last move).
//Watching an ad adds 5 (which then deplete back down to 1 as they are used);
//an in-app purchase sets it to -1, meaning unlimited (shown as ∞).
final backMovesProvider = StateProvider<int>((ref) => 1);

//Whether the default (1) back move is currently usable. It is refreshed by
//making a forward move and spent by undoing once no ad/bonus moves remain,
//so at the default level you must move forward before you can undo again.
final canUndoProvider = StateProvider<bool>((ref) => false);
