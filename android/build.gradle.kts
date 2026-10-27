plugins {
    // Puts the Android Gradle Plugin classes on the root build classpath.
    id("com.android.application") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// tflite_flutter compiles Java for 11 while Kotlin targets 17, which fails the
// JVM target validation. Align its Java target with the app (17), without
// touching the plugin copy in the pub cache.
subprojects {
    if (name == "tflite_flutter") {
        afterEvaluate {
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                ?.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
