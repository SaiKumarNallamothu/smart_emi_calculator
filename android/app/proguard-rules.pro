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

# AndroidX WorkManager & Room (Fixes WorkDatabase instantiation crash in minified release builds)
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-dontwarn androidx.room.**
-dontwarn androidx.work.**

# AndroidX Startup
-keep class androidx.startup.** { *; }

# Google Mobile Ads SDK
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

