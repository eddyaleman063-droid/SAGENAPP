plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.plugin.compose")
}

import java.util.Properties
import java.io.FileInputStream

fun Properties.loadKeyProps(baseDir: File) {
    val f = File(baseDir, "key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.sagen.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.sagen.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 9
        versionName = "5.1.2"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keyProps = Properties().apply { loadKeyProps(rootProject.projectDir) }
            val keystoreName = keyProps.getProperty("storeFile") ?: "release.keystore"
            storeFile = file(keystoreName)
            storePassword = keyProps.getProperty("storePassword") ?: System.getenv("SAGEN_STORE_PASSWORD") ?: ""
            keyAlias = keyProps.getProperty("keyAlias") ?: System.getenv("SAGEN_KEY_ALIAS") ?: ""
            keyPassword = keyProps.getProperty("keyPassword") ?: System.getenv("SAGEN_KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    val isBundle = gradle.startParameter.taskNames.any { it.contains("bundle") }
    splits {
        abi {
            isEnable = !isBundle
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }

    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "/META-INF/DEPENDENCIES"
            excludes += "/META-INF/INDEX.LIST"
            pickFirsts += "/META-INF/services/com.google.firebase.components.ComponentRegistrar"
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("com.google.firebase:firebase-auth:23.2.1")
    implementation("com.google.firebase:firebase-common:21.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2026.05.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.runtime:runtime")
}
