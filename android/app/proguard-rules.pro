# MLKit Text Recognition ProGuard Rules
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General MLKit ignore for missing optional modules
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**
-dontwarn com.google.mlkit.vision.text.**

# If the above still fails, force ignore all missing classes (common for R8 failures)
-ignorewarnings
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
