package com.sagen.app

import android.os.Build
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.sagen.app.ui.components.FlameAnimationViewFactory
import com.sagen.app.ui.components.MainActivityFlameBridge
import com.sagen.app.ui.components.FlamePhase
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes?.let {
                it.layoutInDisplayCutoutMode =
                    android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register PlatformView for flame animation (ComposeView)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("com.sagen.app/flame_animation", FlameAnimationViewFactory())

        // Flame animation MethodChannel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dev.sagen.app/flame_animation"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPhase" -> {
                    val phaseName = call.argument<String>("phase")
                    if (phaseName == null) {
                        result.error("MISSING_ARG", "phase required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val phase = FlamePhase.valueOf(phaseName)
                        MainActivityFlameBridge.view?.setPhase(phase)
                        result.success(true)
                    } catch (e: IllegalArgumentException) {
                        result.error("INVALID_PHASE", "Unknown phase: $phaseName", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Firebase recovery MethodChannel
        // Native reinitializes from google-services.json — no secrets passed from Dart.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dev.sagen.app/firebase"
        ).setMethodCallHandler { call, result ->
            if (call.method == "recoverFirebaseApp") {
                try {
                    val existing = FirebaseApp.getInstance("[DEFAULT]")
                    existing.delete()
                } catch (_: Exception) {}

                try {
                    val opts = FirebaseOptions.fromResource(applicationContext)
                    if (opts == null) {
                        result.error("FIREBASE_ERROR", "FirebaseOptions not found", null)
                    } else {
                        FirebaseApp.initializeApp(applicationContext, opts, "[DEFAULT]")
                        result.success(true)
                    }
                } catch (e: Exception) {
                    result.error("FIREBASE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
