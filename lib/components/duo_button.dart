import 'package:flutter/material.dart';

//A Duolingo-style button: a flat coloured face sitting on top of a darker
//"shelf". Pressing it sinks the face down onto the shelf for a tactile,
//3D feel.
class DuoButton extends StatefulWidget {
  const DuoButton(
      {super.key,
      required this.color,
      required this.shadowColor,
      required this.child,
      required this.onPressed,
      this.borderColor,
      this.borderRadius = 16.0,
      this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0)});

  final Color color;
  final Color shadowColor;
  final Color? borderColor;
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  static const double _depth = 5.0;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final enabled = widget.onPressed != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        decoration: BoxDecoration(color: widget.shadowColor, borderRadius: radius),
        padding: EdgeInsets.only(
            top: _pressed ? _depth : 0.0, bottom: _pressed ? 0.0 : _depth),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: radius,
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 2.0)
                : null,
          ),
          child:
              Center(widthFactor: 1.0, heightFactor: 1.0, child: widget.child),
        ),
        ),
      ),
    );
  }
}
