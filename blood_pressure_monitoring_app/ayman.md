# Blood Pressure Monitoring App - Setup Guide

A Flutter app for real-time blood pressure monitoring, designed for patients with Orthostatic Hypotension. This guide walks you through getting the project running on **Windows with Android Studio**.

---

## Prerequisites

You need three things installed:

1. **Flutter SDK** (3.9.2 or later)
2. **Android Studio** (with Flutter & Dart plugins)
3. **Git**

---

## Step 1: Install Flutter on Windows

1. Download the Flutter SDK from [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2. Extract the zip to a location with no spaces in the path (e.g. `C:\flutter`)
3. Add Flutter to your system PATH:
   - Search "Environment Variables" in the Start menu
   - Under **System variables**, find `Path` and click **Edit**
   - Add `C:\flutter\bin`
   - Click OK and restart any open terminals

4. Open a new Command Prompt or PowerShell and verify:

```
flutter doctor
```

You should see checkmarks for Flutter and Android toolchain. Fix any issues it reports before continuing.

---

## Step 2: Set Up Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio)
2. Open Android Studio and go to **File > Settings > Plugins**
3. Search for and install both:
   - **Flutter**
   - **Dart**
4. Restart Android Studio
5. Go to **File > Settings > Languages & Frameworks > Flutter** and set the Flutter SDK path (e.g. `C:\flutter`)

### Android SDK Setup

Android Studio should install the Android SDK automatically. If `flutter doctor` complains about it:

1. Go to **File > Settings > Languages & Frameworks > Android SDK**
2. Under the **SDK Tools** tab, make sure these are checked:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
3. Accept any license agreements:

```
flutter doctor --android-licenses
```

---

## Step 3: Clone and Run the Project

Open a terminal (Command Prompt, PowerShell, or the Android Studio terminal):

```
git clone <repository-url>
cd Capstone\blood_pressure_monitoring_app
```

Install dependencies:

```
flutter pub get
```

### Firebase Config

The app requires a `google-services.json` file for Firebase. Ask Zachary for this file, then place it at:

```
blood_pressure_monitoring_app\android\app\google-services.json
```

This file is gitignored for security reasons and won't be in the repo.

---

## Step 4: Run on an Emulator

1. In Android Studio, open the **Device Manager** (icon in the toolbar, or **Tools > Device Manager**)
2. Click **Create Virtual Device**
3. Pick a device (e.g. Pixel 7) and hit **Next**
4. Download a system image (API 34 or higher recommended) and hit **Next > Finish**
5. Launch the emulator by clicking the play button next to it

Then run:

```
flutter run
```

**Note:** BLE features (Bluetooth device scanning/connection) will not work on the emulator. Use a physical Android device for that.

---

## Step 5: Run on a Physical Android Device

1. On your phone, go to **Settings > About Phone** and tap **Build Number** 7 times to enable Developer Options
2. Go to **Settings > Developer Options** and enable **USB Debugging**
3. Plug your phone into the ThinkPad via USB
4. Accept the debugging prompt on your phone
5. Verify the device shows up:

```
flutter devices
```

6. Run the app:

```
flutter run
```

---

## Common Issues

| Problem | Fix |
|---|---|
| `flutter` not recognized | Restart your terminal after adding Flutter to PATH |
| Android licenses not accepted | Run `flutter doctor --android-licenses` |
| Gradle build fails | Run `flutter clean` then `flutter pub get` and try again |
| Missing `google-services.json` | Get the file from Zachary and put it in `android\app\` |
| Emulator won't start | Make sure virtualization (VT-x) is enabled in your ThinkPad BIOS |
| BLE not working on emulator | Use a physical device instead - emulators don't support BLE |

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` / `firebase_auth` / `cloud_firestore` | Backend, auth, database |
| `flutter_blue_plus` | Bluetooth Low Energy (BLE) for PPG sensor |
| `fl_chart` | Blood pressure trend charts |
| `provider` | State management |
| `flutter_local_notifications` | Alert notifications |
| `shared_preferences` | Local settings storage |

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── constants/             # Colors, text styles, BLE UUIDs
├── models/                # Data models (BP readings, PPG packets, alerts)
├── repositories/          # Data access layer (Firebase, BLE)
├── controllers/           # Business logic (Provider-based)
├── services/              # Auth, Bluetooth, Firestore, notifications
├── views/                 # Screens (home, history, alerts, settings, auth)
├── widgets/               # Reusable UI components
├── dsp/                   # Digital signal processing for PPG
└── utils/                 # Helpers (BP status classification)
```

---

## Useful Commands

```
flutter doctor          # Check your setup
flutter pub get         # Install dependencies
flutter run             # Run on connected device/emulator
flutter clean           # Clear build cache (fixes most build issues)
flutter build apk       # Build a release APK
```
