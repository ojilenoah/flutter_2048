import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../managers/celebration.dart';
import 'duo_button.dart';

//Full-screen confetti celebration shown when a new milestone tile (2048,
//4096, ...) is formed. The player taps "Keep going" to dismiss and continue.
class CelebrationOverlay extends ConsumerStatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  ConsumerState<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestone = ref.watch(celebrationProvider);
    final showing = milestone != 0;

    //Fire the confetti the moment a milestone appears.
    ref.listen<int>(celebrationProvider, (prev, next) {
      if (next != 0) {
        _confetti.play();
      } else {
        _confetti.stop();
      }
    });

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !showing,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showing ? 1.0 : 0.0,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                maxBlastForce: 26,
                minBlastForce: 8,
                gravity: 0.25,
                shouldLoop: false,
                colors: const [
                  color2048,
                  color64,
                  color8,
                  color512,
                  scoreColor,
                  duoRed,
                ],
              ),
            ),
            if (showing)
              TweenAnimationBuilder<double>(
                key: ValueKey(milestone),
                tween: Tween(begin: 0.7, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: _card(context, milestone),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, int milestone) {
    final won = milestone == celebrationThreshold;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: context.game.cardBackground,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: context.game.cardBorder, width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$milestone',
            style: GoogleFonts.montserrat(
                fontSize: 56.0,
                fontWeight: FontWeight.w800,
                color: color2048),
          ),
          const SizedBox(height: 8.0),
          Text(
            won ? 'You won!' : 'Milestone reached!',
            style: GoogleFonts.montserrat(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: context.game.uiText),
          ),
          const SizedBox(height: 8.0),
          Text(
            won
                ? 'You made the 2048 tile! Keep going for an even bigger one.'
                : 'You reached $milestone. Keep going!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15.0, color: duoGrayLight),
          ),
          const SizedBox(height: 24.0),
          DuoButton(
            color: buttonColor,
            shadowColor: buttonColorShadow,
            onPressed: () =>
                ref.read(celebrationProvider.notifier).state = 0,
            child: Text(
              'KEEP GOING',
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
