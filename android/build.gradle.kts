buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versión del Android Gradle Plugin (ajusta según tu proyecto)
        classpath("com.android.tools.build:gradle:8.0.2")
        // Agrega el plugin de Google Services
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()        // Repositorio de Google
        mavenCentral()  // Repositorio Maven Central
        maven { url = uri("https://jitpack.io") } // Repositorio JitPack
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
