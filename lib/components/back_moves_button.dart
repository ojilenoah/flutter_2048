import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../managers/ad_service.dart';
import '../managers/back_moves.dart';
import 'duo_button.dart';
import 'payment_page.dart';

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
      barrierDismissible: true,
      builder: (context) => _TopUpSheet(ref: ref),
    );
  }
}

//Stateful so the WATCH AD button can swap to a spinner while the ad loads
//instead of the dialog closing instantly with no feedback.
class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  bool _loadingAd = false;

  Future<void> _onWatchAd() async {
    if (_loadingAd) return;
    setState(() => _loadingAd = true);

    final messenger = ScaffoldMessenger.of(context);
    final notifier = widget.ref.read(backMovesProvider.notifier);
    final adService = widget.ref.read(adServiceProvider);

    final earned = await adService.showRewardedAd();

    if (!mounted) return;
    Navigator.of(context).pop();

    if (earned) {
      //Don't downgrade an unlimited (-1) balance by adding to it.
      if (notifier.state >= 0) notifier.state += 5;
    } else {
      messenger.showSnackBar(const SnackBar(
        content: Text("Couldn't load an ad — try again in a moment."),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.game.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
              //Shows a real AdMob rewarded ad on mobile, no-op on web.
              //The +5 is granted only when the SDK reports a reward.
              onPressed: _loadingAd ? null : _onWatchAd,
              child: _loadingAd
                  ? const SizedBox(
                      height: 18.0,
                      width: 18.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
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
              //Opens the demo payment page. Replace with `in_app_purchase`
              //triggering the store's native payment sheet for production.
              onPressed: _loadingAd
                  ? null
                  : () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(MaterialPageRoute(
                          builder: (_) => const PaymentPage()));
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
              onPressed:
                  _loadingAd ? null : () => Navigator.of(context).pop(),
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
    );
  }
}
