# ─────────────────────────────────────────────────────────────
# SAGEN — ProGuard / R8 Rules (Optimized for Release)
# ─────────────────────────────────────────────────────────────

# ── Flutter Engine ───────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.**

# ── Firebase Core + Services ────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.appcheck.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** { *; }
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Google Sign-In ──────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }
-dontwarn com.google.android.gms.auth.**
-dontwarn com.google.android.gms.common.**

# ── Play Core / Integrity ───────────────────────────────────
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.integrity.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.integrity.**

# ── HTTP / Network ──────────────────────────────────────────
-keep class org.apache.http.** { *; }
-keep class android.net.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.http.**
-dontwarn okhttp3.**
-dontwarn okio.**

# ── Serialization ───────────────────────────────────────────
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Enums ───────────────────────────────────────────────────
-keepclassmembers enum * { *; }
-keep enum * { *; }

# ── Annotations ─────────────────────────────────────────────
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# ── Provider (ChangeNotifier subclasses) ────────────────────
-keep class * extends ChangeNotifier { *; }

# ── Flutter Secure Storage ──────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── JSON ────────────────────────────────────────────────────
-keepclassmembers class * {
    *** $serializer();
}

# ── Kotlin ──────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ── Speech Recognition ──────────────────────────────────────
-keep class android.speech.** { *; }
-dontwarn android.speech.**

# ── Remove Logging in Release ───────────────────────────────
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# ── freezed / json_serializable (generated data classes) ────
-keep class **._$* { *; }
-keepclassmembers class * {
    *** copyWith();
    *** copyWith.*;
    *** toJson();
    static *** fromJson(...);
}

# ── Cloud Firestore model classes ───────────────────────────
-keepclassmembers class com.sagen.app.models.** { *; }
-keep class com.sagen.app.models.** { *; }

# ── google_generative_ai SDK ─────────────────────────────────
-keep class com.google.ai.generativelanguage.** { *; }
-dontwarn com.google.ai.generativelanguage.**

# ── WorkManager (background sync) ────────────────────────────
-keep class be.tramorkes.workmanager.** { *; }
-dontwarn be.tramorkes.workmanager.**

# ── Remove debug metadata from release ──────────────────────
-assumenosideeffects class java.io.PrintStream {
    public void println(...);
    public void print(...);
}

# ── Resource Optimization ──────────────────────────────────
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ── General Android ────────────────────────────────────────
-keep class android.** { *; }
-dontwarn android.**
