import org.gradle.api.JavaVersion

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Aplica el plugin de Google Services
}

android {
    namespace = "io.dycompany.dysaeats"
    compileSdk = 35  // Asegúrate de usar la versión adecuada

    defaultConfig {
        applicationId = "io.dycompany.dysaeats"
        minSdk = 23
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            isMinifyEnabled = false  // Cambia a true para producción si deseas optimización
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-maps:18.0.2")
    implementation("com.google.android.libraries.places:places:2.6.0")
    implementation("com.google.maps.android:android-maps-utils:3.8.0")
    implementation("com.google.code.gson:gson:2.10")
    implementation("com.google.android.gms:play-services-location:21.0.1")
}
