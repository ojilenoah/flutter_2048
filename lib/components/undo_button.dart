import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/back_moves.dart';
import '../managers/board.dart';
import 'button.dart';

//The undo button, muted whenever a back move can't currently be made.
class UndoButton extends ConsumerWidget {
  const UndoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasHistory = ref.watch(boardManager.select((b) => b.undo != null));
    final backMoves = ref.watch(backMovesProvider);
    final canUndo = ref.watch(canUndoProvider);

    //Enabled when there is history to step back to and either an unlimited
    //balance, a bonus move, or the refreshed default move is available.
    final enabled =
        hasHistory && (backMoves < 0 || backMoves > 1 || canUndo);

    return ButtonWidget(
      icon: Icons.undo,
      onPressed:
          enabled ? () => ref.read(boardManager.notifier).undo() : null,
    );
  }
}
