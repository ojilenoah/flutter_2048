import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/colors.dart';
import '../const/theme.dart';
import '../game.dart';
import 'duo_button.dart';

//Breakpoint above which the desktop layout kicks in: game inside a phone
//frame on the left, info side panel on the right. Below this width the
//game renders full-screen and an info button overlays the top-left
//(web only — native mobile shows the game alone).
const double _desktopBreakpoint = 900.0;

//Logical "phone screen" size the Game widget pretends to render onto when
//framed on desktop. Picked so the game's own board-sizing math (which reads
//MediaQuery.shortestSide) produces a board that fits the frame cleanly.
const double _phoneLogicalWidth = 400.0;
const double _phoneLogicalHeight = 820.0;

//Phone-frame bezel: chunky and very dark, like the bezel of a real device
//in a press-kit screenshot. Square corners (no radius) per design.
const Color _frameBezel = Color(0xff1a1a1a);
const double _frameBorderWidth = 8.0;

class WebShell extends StatelessWidget {
  const WebShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const Game();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _desktopBreakpoint) {
          return const _MobileWebLayout();
        }
        return _DesktopLayout(maxHeight: constraints.maxHeight);
      },
    );
  }
}

//-----------------------------------------------------------------------
// Desktop: phone frame on the left, info side panel on the right.
//-----------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.maxHeight});

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final available = maxHeight - 48.0;
    final scale = available < _phoneLogicalHeight
        ? available / _phoneLogicalHeight
        : 1.0;
    final frameWidth =
        _phoneLogicalWidth * scale + _frameBorderWidth * 2;
    final frameHeight =
        _phoneLogicalHeight * scale + _frameBorderWidth * 2;

    return Scaffold(
      backgroundColor: context.game.background,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PhoneFrame(width: frameWidth, height: frameHeight),
            const SizedBox(width: 48.0),
            const SizedBox(width: 400.0, child: _InfoContent()),
          ],
        ),
      ),
    );
  }
}

//-----------------------------------------------------------------------
// Mobile web: full-screen game + a floating info button (top-left) that
// opens a bottom sheet containing the same content as the desktop panel.
//-----------------------------------------------------------------------

class _MobileWebLayout extends StatelessWidget {
  const _MobileWebLayout();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Game(),
        Positioned(
          top: 16.0,
          left: 16.0,
          child: SafeArea(child: _InfoFab(onTap: () => _openSheet(context))),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.game.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Drag handle
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: ctx.game.cardBorder,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const _InfoContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoFab extends StatelessWidget {
  const _InfoFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: context.game.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: context.game.cardBorder, width: 2.0),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.info_outline,
            color: context.game.uiText,
            size: 22.0,
          ),
        ),
      ),
    );
  }
}

//-----------------------------------------------------------------------
// Phone frame: chunky dark bezel containing the Game rendered against
// an overridden MediaQuery so the game's internal layout math fits.
//-----------------------------------------------------------------------

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.width, required this.height});

  final double width;
  final double height;

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
        border: Border.all(color: _frameBezel, width: _frameBorderWidth),
        color: _frameBezel,
      ),
      clipBehavior: Clip.hardEdge,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: framedGame,
      ),
    );
  }
}

//-----------------------------------------------------------------------
// Shared content: title, blurb, heads-up, name, and the 2x2 button grid.
// Used by both the desktop side panel and the mobile info bottom sheet.
//-----------------------------------------------------------------------

class _InfoContent extends StatelessWidget {
  const _InfoContent();

  @override
  Widget build(BuildContext context) {
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
            fontSize: 32.0,
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
        const _ButtonGrid(),
      ],
    );
  }
}

//-----------------------------------------------------------------------
// 2x2 grid of DuoButtons.
//-----------------------------------------------------------------------

class _ButtonGrid extends StatelessWidget {
  const _ButtonGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LinkButton(
                label: 'Portfolio',
                icon: Icons.public,
                url: 'https://noahojile.com',
                color: buttonColor,
                shadowColor: buttonColorShadow,
                foreground: Colors.white,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: _LinkButton(
                label: 'GitHub',
                icon: Icons.code,
                url: 'https://github.com/ojilenoah/flutter_2048',
                color: duoGray,
                shadowColor: Color(0xff2f2f2f),
                foreground: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _LinkButton(
                label: 'Coffee',
                icon: Icons.coffee,
                url: 'https://buymeacoffee.com/ojilenoah',
                color: color2048,
                shadowColor: color2048Shadow,
                foreground: textColor,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: _LinkButton(
                label: 'Download',
                icon: Icons.download,
                //Points at the GitHub Actions workflow that builds the
                //APK on every push to main — visitors grab the latest
                //artifact from the most recent successful run.
                url:
                    'https://github.com/ojilenoah/flutter_2048/actions/workflows/build-apk.yml',
                color: duoRed,
                shadowColor: duoRedShadow,
                foreground: Colors.white,
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18.0),
          const SizedBox(width: 8.0),
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
