import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import 'duo_button.dart';

class ButtonWidget extends ConsumerWidget {
  const ButtonWidget({super.key, this.text, this.icon, this.onPressed});

  final String? text;
  final IconData? icon;
  //A null callback renders the button in a muted, disabled state.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (icon != null) {
      //Icon button (Undo / Restart): 2048 tan with the Duolingo 3D shelf.
      return DuoButton(
        color: scoreColor,
        shadowColor: scoreColorShadow,
        onPressed: onPressed,
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24.0,
        ),
      );
    }
    //Text button (New Game / Try Again): 2048 brown with the Duolingo 3D shelf.
    return DuoButton(
      color: buttonColor,
      shadowColor: buttonColorShadow,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      child: Text(
        text!.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
    );
  }
}
