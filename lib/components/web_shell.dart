import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/theme.dart';
import '../game.dart';

//Breakpoint above which the desktop layout kicks in: game inside a phone
//frame on the left, info side panel on the right. Below this width (and on
//all native platforms) the game renders full-screen exactly as before.
const double _desktopBreakpoint = 900.0;

//Phone-frame dimensions on the desktop layout. Picked to match a roughly
//9:19.5 aspect ratio (modern phones) while staying visible on shorter
//desktop windows.
const double _frameWidth = 380.0;
const double _frameHeight = 760.0;

//Wraps the game so that on a wide web window the game appears inside a
//mobile-shaped frame next to a side panel describing the project. On
//mobile screens and all native platforms it just returns the game directly.
class WebShell extends StatelessWidget {
  const WebShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const Game();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _desktopBreakpoint) {
          return const Game();
        }
        return _DesktopLayout(maxHeight: constraints.maxHeight);
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.maxHeight});

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    //Shrink the frame proportionally if the browser window is short.
    final frameHeight =
        maxHeight < _frameHeight + 48.0 ? maxHeight - 48.0 : _frameHeight;
    final frameWidth = frameHeight * (_frameWidth / _frameHeight);

    return Scaffold(
      backgroundColor: context.game.background,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PhoneFrame(
              width: frameWidth,
              height: frameHeight,
              child: const Game(),
            ),
            const SizedBox(width: 48.0),
            const SizedBox(
              width: 360.0,
              child: _SidePanel(),
            ),
          ],
        ),
      ),
    );
  }
}

//Minimal flat frame: thin border, lightly rounded corners, no shadow.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.game.cardBorder, width: 2.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context) {
    final textColor = context.game.uiText;
    final subtleColor = textColor.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '2048 Rewind',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 36.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'A take on the classic 2048 with undoable moves — earn rewinds by '
          'watching an ad or unlock unlimited rewinds.',
          style: TextStyle(color: subtleColor, fontSize: 15.0, height: 1.4),
        ),
        const SizedBox(height: 20.0),
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: context.game.cardBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: context.game.cardBorder),
          ),
          child: Text(
            'Heads up: this is the web build. Rewarded ads and the '
            '"Go Unlimited" payment flow are mobile-only — install the '
            'Android app to use them.',
            style: TextStyle(color: subtleColor, fontSize: 13.0, height: 1.4),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          'Built by Noah Ojile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
          ),
        ),
        const SizedBox(height: 16.0),
        const _LinkButton(
          label: 'View Portfolio',
          icon: Icons.public,
          url: 'https://noahojile.com',
        ),
        const SizedBox(height: 10.0),
        const _LinkButton(
          label: 'GitHub Repo',
          icon: Icons.code,
          url: 'https://github.com/ojilenoah/flutter_2048',
        ),
        const SizedBox(height: 10.0),
        const _LinkButton(
          label: 'Buy Me a Coffee',
          icon: Icons.coffee,
          url: 'https://buymeacoffee.com/ojilenoah',
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.game.uiText;

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: context.game.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: context.game.cardBorder, width: 2.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20.0),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_outward, color: textColor, size: 16.0),
          ],
        ),
      ),
    );
  }
}
