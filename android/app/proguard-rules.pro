# Proguard rules for F4 Supermarket App
# Fixes geolocator R8 shrinking missing class warning/error
-dontwarn com.baseflow.geolocator.errors.ErrorCodes
-keep class com.baseflow.geolocator.** { *; }
