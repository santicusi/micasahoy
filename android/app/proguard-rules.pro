# Keep annotations
-keepclassmembers class * {
    @com.google.errorprone.annotations.* *;
    @javax.annotation.* *;
    @javax.annotation.concurrent.* *;
}

-keep class com.google.crypto.tink.** { *; }

-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**


# Keep errorprone annotations
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Keep javax annotations
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**
