# Keep the Flutter embedding and plugin entry points so R8 can't strip them.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
