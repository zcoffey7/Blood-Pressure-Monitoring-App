# Mobile Blood Pressure Monitoring App

This repository contains the mobile application for a wearable blood pressure monitoring and regulation system designed to assist patients with Orthostatic Hypotension (OH). The app serves as the primary user interface for viewing real-time blood pressure data, historical trends, and system alerts from a wearable compression device.

The application is developed using Flutter (Dart) and is currently targeted for Android, with future support planned for iOS.

## 📱 Application Overview

The mobile app is designed specifically with elderly users in mind and follows accessibility-focused UI principles, including:

- Large, readable fonts
- High-contrast color schemes
- Simple, intuitive navigation
- Minimal on-screen complexity

### Core Features

- Real-time blood pressure and heart rate display
- Historical data visualization and trend plotting
- Alert notifications for abnormal blood pressure events
- Secure user authentication
- Cloud-based data synchronization

Sensor data is transmitted from an ESP32-based wearable device and processed by an external machine learning backend before being displayed in the app.

## 🧩 System Architecture (High-Level)

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication + Realtime Database)
- **Hardware:** ESP32-based sensor and pump boards
- **Data Format:** JSON over Wi-Fi
- **ML Backend:** External blood pressure estimation model

The mobile app does not perform raw signal processing. It displays preprocessed blood pressure values and system status updates received from the backend.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio (with Flutter & Dart plugins installed)
- Android Emulator or physical Android device
- Firebase project (configured separately)

### Verify Flutter installation:

```bash
flutter doctor
```

### Installation

1. Clone this repository:
```bash
git clone [<repository-url>](https://github.com/zcoffey7/Blood-Pressure-Monitoring-App.git)
cd Capstone
```

2. Navigate to the Flutter project directory:
```bash
cd blood_pressure_monitoring_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
Capstone/
└── blood_pressure_monitoring_app/  # Flutter mobile application
    ├── lib/                        # Application source code
    ├── android/                    # Android platform files
    ├── ios/                        # iOS platform files (future support)
    └── test/                       # Unit and widget tests
```

## 🔧 Configuration

Firebase configuration files need to be added to the project:
- `android/app/google-services.json` for Android
- `ios/Runner/GoogleService-Info.plist` for iOS (when supported)

## 📝 License

[Add license information here]

## 👥 Contributors

[Add contributor information here]

## 📧 Contact

[Add contact information here]



