# 2048 — Flutter

![2048 Game in Flutter Logo](https://user-images.githubusercontent.com/9529847/172828266-75dc15a5-f591-42ea-b037-90ab1efed42e.png)

A polished take on the classic 2048 sliding-tile puzzle, built with Flutter and Riverpod. Tile movement and merges use Flutter's explicit animation system (`AnimatedWidget` + `AnimationController`), and game state is saved locally with Hive. Runs on Android, iOS, Web and desktop.

## Features I added

- **Light & dark mode** — a saved theme toggle pinned to the top-right corner.
- **Rewinds (back moves)** — a counter that lets you undo multiple moves; it depletes as you use it.
  - **Tap the counter** to open a top-up sheet: **watch an ad for +5** or **go unlimited**.
  - You always keep one default rewind, refreshed after each forward move.
  - The undo button mutes itself when no rewind is available.
- **Smoother merges** — merged tiles settle in with a gentle grow-in instead of a pop.
- **Reset high score** — long-press the **BEST** card for a confirmation dialog.
- **Duolingo-style UI** — chunky 3D buttons and rounded cards over the classic 2048 palette.

## Demo

<!-- Add a screenshot or screen-recording of your build here, e.g.: -->
<!-- ![Gameplay](docs/demo.gif) -->

## Run it

**Web (quickest):**
```bash
flutter pub get
flutter run -d chrome
```

**Android APK — in the cloud (no Android SDK needed):**
This repo includes a GitHub Actions workflow (`.github/workflows/build-apk.yml`).
1. Push to `main`, or trigger **Build Android APK** from the **Actions** tab.
2. Open the finished run → download the **app-release-apk** artifact.
3. Unzip and install `app-release.apk` on your phone.

**Android APK — locally** (requires the Android SDK):
```bash
flutter pub get
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Credits

- The original 2048 game by [Gabriele Cirulli](https://github.com/gabrielecirulli).
- Base Flutter implementation by [angjelkom](https://github.com/angjelkom/flutter_2048); the features listed above were added on top of it.

## License

Licensed under the MIT License.
