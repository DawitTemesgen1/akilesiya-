import org.gradle.api.tasks.Delete
import com.android.build.api.dsl.CommonExtension // Import the correct, modern DSL interface

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// THIS IS THE FINAL CORRECTED KOTLIN BLOCK
subprojects {
    afterEvaluate {
        // Find the Android extension by its modern type (CommonExtension).
        // This will work for both app and library modules.
        extensions.findByType(CommonExtension::class.java)?.apply {
            // The 'compileSdk' property is defined on CommonExtension.
            compileSdk = 36
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}