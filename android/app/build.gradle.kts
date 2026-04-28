plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.setthawut.dormfix"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: "dormfix"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "dormfix123"
            storeFile = file("dormfix.keystore")
            storePassword = System.getenv("STORE_PASSWORD") ?: "dormfix123"
        }
    }
    defaultConfig {
        applicationId = "com.setthawut.dormfix"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = (System.getenv("VERSION_CODE") ?: flutter.versionCode.toString()).toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/*.kotlin_module",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
            pickFirsts += setOf(
                "META-INF/INDEX.LIST",
                "META-INF/io.netty.versions.properties"
            )
        }
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
flutter {
    source = "../.."
}
