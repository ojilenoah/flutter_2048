import 'package:flutter/material.dart';

//Themeable colors for the game, swapped between light and dark mode.
//The 2048 tile colors and the tan/brown buttons stay constant (see colors.dart)
//since they read well on either background.
class GameTheme extends ThemeExtension<GameTheme> {
  final Color background;
  final Color boardBackground;
  final Color emptyTile;
  final Color uiText;
  final Color cardBackground;
  final Color cardBorder;
  final Color overlay;

  const GameTheme({
    required this.background,
    required this.boardBackground,
    required this.emptyTile,
    required this.uiText,
    required this.cardBackground,
    required this.cardBorder,
    required this.overlay,
  });

  static const light = GameTheme(
    background: Color(0xfffaf8ef),
    boardBackground: Color(0xffbbada0),
    emptyTile: Color(0xffcdc1b4),
    uiText: Color(0xff776e65),
    cardBackground: Color(0xffffffff),
    cardBorder: Color(0xffe5e5e5),
    overlay: Color.fromRGBO(238, 228, 218, 0.73),
  );

  static const dark = GameTheme(
    background: Color(0xff1a1814),
    boardBackground: Color(0xff3c362e),
    emptyTile: Color(0xff4e463c),
    uiText: Color(0xfff0ece2),
    cardBackground: Color(0xff2a2823),
    cardBorder: Color(0xff433d34),
    overlay: Color.fromRGBO(26, 24, 20, 0.78),
  );

  @override
  GameTheme copyWith({
    Color? background,
    Color? boardBackground,
    Color? emptyTile,
    Color? uiText,
    Color? cardBackground,
    Color? cardBorder,
    Color? overlay,
  }) =>
      GameTheme(
        background: background ?? this.background,
        boardBackground: boardBackground ?? this.boardBackground,
        emptyTile: emptyTile ?? this.emptyTile,
        uiText: uiText ?? this.uiText,
        cardBackground: cardBackground ?? this.cardBackground,
        cardBorder: cardBorder ?? this.cardBorder,
        overlay: overlay ?? this.overlay,
      );

  @override
  GameTheme lerp(ThemeExtension<GameTheme>? other, double t) {
    if (other is! GameTheme) return this;
    return GameTheme(
      background: Color.lerp(background, other.background, t)!,
      boardBackground: Color.lerp(boardBackground, other.boardBackground, t)!,
      emptyTile: Color.lerp(emptyTile, other.emptyTile, t)!,
      uiText: Color.lerp(uiText, other.uiText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

//Convenience accessor: context.game.background, etc.
extension GameThemeContext on BuildContext {
  GameTheme get game => Theme.of(this).extension<GameTheme>()!;
}
