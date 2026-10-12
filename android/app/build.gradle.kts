import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. The keystore and key.properties live OUTSIDE version control
// (see docs/RELEASE.md). With no key.properties the release build falls back to
// the debug key so `flutter run --release` keeps working locally, but CI and
// scripts/release_android_internal.sh refuse to ship an unsigned-by-us bundle.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.gymtross.app"
    // Flutter 3.38 defaults to SDK 37, which currently only ships as the
    // preview platform `android-37.0` -- AGP resolves the target by the exact
    // hash string `android-37` and fails. Pinned to the newest stable platform
    // until a non-preview 37 lands.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gymtross.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                // storeFile may be absolute or ~-prefixed; keep the keystore out of the repo.
                storeFile = file(
                    keystoreProperties.getProperty("storeFile").replaceFirst("^~", System.getProperty("user.home"))
                )
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("android/key.properties not found: release is signed with the DEBUG key (not uploadable to Play).")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
