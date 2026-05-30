import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../managers/back_moves.dart';
import 'duo_button.dart';

//Demo payment page for the "Unlimited Rewinds" offer. Fakes a payment flow
//and unlocks unlimited back moves on success. For real money, swap this for
//the `in_app_purchase` package — Android/iOS require the store's native
//payment sheet for digital goods (custom checkout UIs get rejected).
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  bool _processing = false;
  bool _success = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    //Pretend to call a payment processor.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    //Unlock unlimited back moves.
    ref.read(backMovesProvider.notifier).state = -1;
    setState(() {
      _processing = false;
      _success = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.game.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _success
              ? const _SuccessView(key: ValueKey('success'))
              : _checkoutView(context),
        ),
      ),
    );
  }

  Widget _checkoutView(BuildContext context) {
    return Padding(
      key: const ValueKey('checkout'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.close, color: context.game.uiText),
              onPressed:
                  _processing ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 8.0),
          Center(
            child: Container(
              width: 96.0,
              height: 96.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color2048,
                borderRadius: BorderRadius.circular(28.0),
                boxShadow: const [
                  BoxShadow(
                      color: color2048Shadow,
                      offset: Offset(0, 5),
                      blurRadius: 0),
                ],
              ),
              child: const Text(
                '∞',
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 56.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Unlimited Rewinds',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.game.uiText,
                fontSize: 26.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Never run out of undos. Yours forever.',
            textAlign: TextAlign.center,
            style: TextStyle(color: duoGrayLight, fontSize: 15.0),
          ),
          const SizedBox(height: 24.0),
          _bullet(context, 'Undo as many moves as you want'),
          _bullet(context, 'No more "watch an ad" prompts'),
          _bullet(context, 'One-time payment, lasts forever'),
          const Spacer(),
          //Mock payment method card — makes it clear this is a demo.
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: context.game.cardBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: context.game.cardBorder, width: 2.0),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: context.game.uiText),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'Demo card  ····  4242',
                    style: TextStyle(
                        color: context.game.uiText,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Text(
                  'CHANGE',
                  style: TextStyle(
                      color: duoGrayLight,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          DuoButton(
            color: color2048,
            shadowColor: color2048Shadow,
            onPressed: _processing ? null : _pay,
            child: _processing
                ? const SizedBox(
                    height: 22.0,
                    width: 22.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: textColor),
                  )
                : const Text(
                    'PAY  \$2.99',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
          ),
          const SizedBox(height: 12.0),
          const Text(
            'Demo checkout — no real charge will be made.',
            textAlign: TextAlign.center,
            style: TextStyle(color: duoGrayLight, fontSize: 12.0),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: color2048, size: 22.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: context.game.uiText, fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('success-center'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110.0,
            height: 110.0,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: color2048, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: textColor, size: 64.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Payment successful!',
            style: TextStyle(
                color: context.game.uiText,
                fontSize: 22.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Unlimited rewinds unlocked.',
            style: TextStyle(color: duoGrayLight, fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
