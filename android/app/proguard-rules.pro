# android/app/proguard-rules.pro
#
# App-level R8 rules. Referenced from build.gradle.kts, where release builds
# run with isMinifyEnabled = true and isShrinkResources = true.
#
# Plugin-specific keeps are NOT repeated here: plugins that need them ship
# their own via consumerProguardFiles, which R8 merges in automatically
# (awesome_notifications/android/consumer-rules.pro covers its Gson models and
# SQLCipher classes). Flutter's own embedding rules come from the Flutter
# Gradle plugin. Duplicating either would only rot as those packages change.

# Keep line numbers so Play Console stack traces stay readable after
# obfuscation. Without this, release crashes deobfuscate to method names only
# and every frame reports an unknown line.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Annotations are load-bearing for the Gson serialization awesome_notifications
# performs on notification payloads.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
