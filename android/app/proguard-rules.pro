# Flutter framework
-keepclassmembers class * {
    public static *** main(java.lang.String[]);
}
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep generated code for the app
-keepclassmembers class ** {
    @androidx.annotation.Keep *;
}
