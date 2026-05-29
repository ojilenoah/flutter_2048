import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../managers/board.dart';
import 'duo_button.dart';

class ScoreBoard extends ConsumerWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(boardManager.select((board) => board.score));
    final best = ref.watch(boardManager.select((board) => board.best));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Score(label: 'Score', score: '$score'),
        const SizedBox(
          width: 8.0,
        ),
        Score(
            label: 'Best',
            score: '$best',
            onLongPress: () => _confirmResetBest(context, ref)),
      ],
    );
  }

  //Prompt the user to confirm before clearing their saved high score.
  void _confirmResetBest(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.game.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset high score?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: context.game.uiText,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'This will set your best score back to 0. This can’t be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: duoGrayLight, fontSize: 15.0),
              ),
              const SizedBox(height: 24.0),
              DuoButton(
                color: duoRed,
                shadowColor: duoRedShadow,
                onPressed: () {
                  ref.read(boardManager.notifier).resetBest();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'RESET',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 12.0),
              DuoButton(
                color: context.game.cardBackground,
                shadowColor: context.game.cardBorder,
                borderColor: context.game.cardBorder,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                      color: duoGrayLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Score extends StatelessWidget {
  const Score(
      {Key? key, required this.label, required this.score, this.onLongPress})
      : super(key: key);

  final String label;
  final String score;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: context.game.cardBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: context.game.cardBorder, width: 2.0)),
        child: Column(children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 13.0,
                color: duoGrayLight,
                fontWeight: FontWeight.bold),
          ),
          Text(
            score,
            style: TextStyle(
                color: context.game.uiText,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
          )
        ]),
      ),
    );
  }
}
