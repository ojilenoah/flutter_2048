import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../game.dart';
import 'duo_button.dart';

//Breakpoint above which the desktop layout kicks in: game inside a phone
//frame on the left, info side panel on the right. Below this width (and on
//all native platforms) the game renders full-screen exactly as before.
const double _desktopBreakpoint = 900.0;

//Logical "phone screen" size the Game widget pretends to render onto when
//framed on desktop. Picked so the game's own board-sizing math (which reads
//MediaQuery.shortestSide) produces a board that fits the frame cleanly.
const double _phoneLogicalWidth = 400.0;
const double _phoneLogicalHeight = 820.0;

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
    //Scale the phone frame down if the browser window is too short to
    //accommodate the full logical phone size with breathing room.
    final available = maxHeight - 48.0;
    final scale = available < _phoneLogicalHeight
        ? available / _phoneLogicalHeight
        : 1.0;
    final frameWidth = _phoneLogicalWidth * scale;
    final frameHeight = _phoneLogicalHeight * scale;

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
              scale: scale,
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

//Minimal flat frame: thin border, lightly rounded corners, no shadow. The
//Game inside renders against a MediaQuery override that reports a phone-
//sized viewport so its internal layout math fits the frame correctly. If
//the browser is too short we scale the whole thing down via Transform.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.width,
    required this.height,
    required this.scale,
  });

  final double width;
  final double height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final framedGame = SizedBox(
      width: _phoneLogicalWidth,
      height: _phoneLogicalHeight,
      child: MediaQuery(
        data: mediaQuery.copyWith(
          size: const Size(_phoneLogicalWidth, _phoneLogicalHeight),
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: const Game(),
      ),
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.game.cardBorder, width: 2.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: framedGame,
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context) {
    //Local rename so the top-level const `textColor` from colors.dart stays
    //visible inside the `const _LinkButton(...)` calls below.
    final panelText = context.game.uiText;
    final subtleColor = panelText.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '2048 Rewind',
          style: TextStyle(
            color: panelText,
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
            color: panelText,
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
          ),
        ),
        const SizedBox(height: 16.0),
        const _LinkButton(
          label: 'View Portfolio',
          icon: Icons.public,
          url: 'https://noahojile.com',
          color: buttonColor,
          shadowColor: buttonColorShadow,
          foreground: Colors.white,
        ),
        const SizedBox(height: 12.0),
        const _LinkButton(
          label: 'GitHub Repo',
          icon: Icons.code,
          url: 'https://github.com/ojilenoah/flutter_2048',
          color: duoGray,
          shadowColor: Color(0xff2f2f2f),
          foreground: Colors.white,
        ),
        const SizedBox(height: 12.0),
        const _LinkButton(
          label: 'Buy Me a Coffee',
          icon: Icons.coffee,
          url: 'https://buymeacoffee.com/ojilenoah',
          color: color2048,
          shadowColor: color2048Shadow,
          foreground: textColor,
        ),
      ],
    );
  }
}

//Duolingo-style raised button that opens an external URL in a new tab.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.url,
    required this.color,
    required this.shadowColor,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final String url;
  final Color color;
  final Color shadowColor;
  final Color foreground;

  Future<void> _open() async {
    //LaunchMode.platformDefault on web opens the URL in a new browser tab.
    //Avoid LaunchMode.externalApplication — it's not supported on web and
    //makes the call silently fail.
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return DuoButton(
      color: color,
      shadowColor: shadowColor,
      onPressed: _open,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18.0),
          const SizedBox(width: 10.0),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
