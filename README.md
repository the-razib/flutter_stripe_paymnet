<img src="https://user-images.githubusercontent.com/19904063/116995247-20519e80-acda-11eb-8e1b-7d0efbd193ad.png" height="36" />

# Flutter Stripe

![stripe-flutter_cover](https://user-images.githubusercontent.com/19904063/121511757-48bf6d80-c9e9-11eb-9674-0fec35e26ef5.png)

### [Read documentation](https://pub.dev/packages/flutter_stripe)

## Installation

```sh
dart pub add flutter_stripe
```

## Steps to get started

1. Install `flutter_stripe` and `http` or `dio` in your project.
2. Add Stripe publishable key to your payment profile

### Requirements

#### Android

This plugin requires several changes to be able to work on Android devices. Please make sure you follow all these steps:

1. Use Android 5.0 (API level 21) and above. Open `android/app/build.gradle.kts` and change `minSdkVersion` to 21.
2. Use Kotlin version 1.8.0 and above: [example](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/android/settings.gradle#L22). Open `android/settings.gradle.kts` and change `kotlinVersion` to 1.8.0

   ```gradle
       plugins {
           ...
           id("org.jetbrains.kotlin.android") version "2.1.20" apply false
       }
   ```

3. Requires Android Gradle plugin 8 and higher
   ```gradle
       plugins {
           ...
           id("com.android.application") version "8.7.0" apply false
       }
   ```
4. Using a descendant of `Theme.AppCompat` for your activity: [example](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/android/app/src/main/res/values/styles.xml#L15), [example night theme](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/android/app/src/main/res/values-night/styles.xml#L16)
   Open `android/app/src/main/res/values/styles.xml` and edit the `parent="@android:style/Theme.Light.NoTitleBar"` to `parent="Theme.MaterialComponents"`.

   ```xml
   <style name="NormalTheme" parent="Theme.MaterialComponents">
       <item name="android:windowBackground">?android:colorBackground</item>
   </style>
   ```

   Open`android/app/src/main/res/values-night/styles.xml` and edit the `parent="@android:style/Theme.Black.NoTitleBar"` to `parent="Theme.MaterialComponents"`.

   ```xml
   <style name="NormalTheme" parent="Theme.MaterialComponents">
       <item name="android:windowBackground">?android:colorBackground</item>
   </style>
   ```

5. Using an up-to-date Android gradle build tools version: [example](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/android/build.gradle#L9) and an up-to-date gradle version accordingly: [example](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/android/gradle/wrapper/gradle-wrapper.properties#L6) (skip it)
6. Using `FlutterFragmentActivity` instead of `FlutterActivity` in `MainActivity.kt`: [example](https://github.com/flutter-stripe/flutter_stripe/blob/79b201a2e9b827196d6a97bb41e1d0e526632a5a/example/android/app/src/main/kotlin/com/flutter/stripe/example/MainActivity.kt#L6)
   ```kotlin
   ...
   import io.flutter.embedding.android.FlutterFragmentActivity
   class MainActivity : FlutterFragmentActivity()
   ```
7. Create a new `proguard-rules.pro` file in `android/app/` directory and add the following lines: [example](https://github.com/flutter-stripe/flutter_stripe/blob/master/example/android/app/proguard-rules.pro)

```proguard
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
```

8. Add the following line to your `android/gradle.properties` file: [example](https://github.com/flutter-stripe/flutter_stripe/blob/master/example/android/gradle.properties)

```properties
android.enableR8.fullMode=false
```

This will prevent crashes with the Stripe SDK on Android (see [issue](https://github.com/flutter-stripe/flutter_stripe/issues/1909)).

9. Rebuild the app, as the above changes don't update with hot reload

These changes are needed because the Android Stripe SDK requires the use of the AppCompat theme for their UI components and the Support Fragment Manager for the Payment Sheets

If you are having troubles to make this package to work on Android, join [this discussion](https://github.com/flutter-stripe/flutter_stripe/discussions/538) to get some support.

#### iOS

Compatible with apps targeting iOS 13 or above.

To upgrade your iOS deployment target to 13.0, you can either do so in Xcode under your Build Settings, or by modifying IPHONEOS_DEPLOYMENT_TARGET in your project.pbxproj directly.

You will also need to update in your `ios/Podfile`:

`platform :ios, '13.0'`

For card scanning add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Scan your card to add it automatically</string>
<key>NSCameraUsageDescription</key>
<string>To scan cards</string>
```

#### Web

Now you can use Stripe with Flutter web! Notice right now it is highly experimental and only a subset of features is implemented. Namely:

- Create paymentmethod
- Confirm payment intent
- Confirm setup intent
- Create token

### Supported widgets

- [Confirm payment element](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/lib/screens/payment_sheet/payment_element/platforms/payment_element_web.dart) (recommended way of handling payments on web)
- [Express checkout](https://github.com/flutter-stripe/flutter_stripe/blob/main/example/lib/screens/payment_sheet/express_checkout/platforms/express_checkout_element_web.dart)

To use Stripe on web, it is required to add `flutter_stripe_web` in your pubspec file
