import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../managers/back_moves.dart';
import 'duo_button.dart';

//Shows how many back (undo) moves the player has left in its own box.
//Tapping it opens the top-up sheet to earn or buy more.
class BackMovesButton extends ConsumerWidget {
  const BackMovesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backMoves = ref.watch(backMovesProvider);

    return GestureDetector(
      onTap: () => _showTopUpSheet(context, ref),
      child: Container(
        height: 48.0,
        constraints: const BoxConstraints(minWidth: 48.0),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
            color: context.game.cardBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: context.game.cardBorder, width: 2.0)),
        child: Text(
          backMoves < 0 ? '∞' : '$backMoves',
          style: TextStyle(
              color: context.game.uiText,
              fontWeight: FontWeight.bold,
              fontSize: 24.0),
        ),
      ),
    );
  }

  //Offer the player ways to refill their back moves.
  void _showTopUpSheet(BuildContext context, WidgetRef ref) {
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
                'Need more rewinds?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: context.game.uiText,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'Every step back uses one rewind. Top up so you can keep '
                'undoing your moves.',
                textAlign: TextAlign.center,
                style: TextStyle(color: duoGrayLight, fontSize: 15.0),
              ),
              const SizedBox(height: 24.0),
              DuoButton(
                color: buttonColor,
                shadowColor: buttonColorShadow,
                //Placeholder reward; real ad integration comes later.
                onPressed: () {
                  final notifier = ref.read(backMovesProvider.notifier);
                  //Don't downgrade an unlimited (-1) balance by adding to it.
                  if (notifier.state >= 0) notifier.state += 5;
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'WATCH AD  ·  +5',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 12.0),
              DuoButton(
                color: color2048,
                shadowColor: color2048Shadow,
                //Placeholder purchase; real in-app purchase comes later.
                onPressed: () {
                  ref.read(backMovesProvider.notifier).state = -1;
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'GO UNLIMITED',
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 12.0),
              DuoButton(
                color: context.game.cardBackground,
                shadowColor: context.game.cardBorder,
                borderColor: context.game.cardBorder,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'MAYBE LATER',
                  style: TextStyle(
                      color: duoGrayLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
