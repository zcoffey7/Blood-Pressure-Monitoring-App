# Blood Pressure Monitoring App - Architecture Documentation

## 📁 Project Structure

This project follows the **MVC (Model-View-Controller)** pattern with clean architecture principles (SRP, OCP, DIP).

```
lib/
├── constants/           # App-wide constants
│   ├── app_colors.dart      # High-contrast color scheme
│   └── app_text_styles.dart # Large, accessible text styles
│
├── models/              # Data models (SRP)
│   ├── blood_pressure_reading.dart
│   └── device_connection.dart
│
├── repositories/        # Data layer - Repository Pattern (DIP)
│   ├── blood_pressure_repository.dart
│   └── device_repository.dart
│
├── controllers/         # Business logic - State Management (SRP)
│   ├── blood_pressure_controller.dart
│   └── device_controller.dart
│
├── views/              # UI Screens (SRP)
│   ├── main_navigation.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── alerts/
│   │   └── alerts_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
├── widgets/            # Reusable UI components (OCP)
│   ├── action_buttons.dart
│   ├── connection_status_widget.dart
│   ├── current_reading_card.dart
│   ├── live_trend_chart.dart
│   └── widgets.dart (barrel file)
│
├── utils/              # Helper functions
│   └── blood_pressure_status.dart
│
└── main.dart           # App entry point
```

## 🏗️ Architecture Principles

### Single Responsibility Principle (SRP)

Each class/file has one reason to change:

- **Models**: Only data structure
- **Controllers**: Only business logic
- **Views**: Only UI layout
- **Widgets**: Only specific UI component

### Open/Closed Principle (OCP)

Easy to extend without modifying existing code:

- Repository pattern allows swapping data sources
- Widget composition for UI flexibility
- Controller extension points

### Dependency Inversion Principle (DIP)

High-level modules don't depend on low-level modules:

- Abstract repository interfaces
- Concrete implementations (Mock → Firebase/API)
- Easy to swap data sources

## 🔄 Data Flow

```
User Action → View → Controller → Repository → Data Source
                ↓
            Provider (State Management)
                ↓
            View Updates
```

## 📦 State Management

**Provider** is used for state management:

- `BloodPressureController` - Manages BP readings
- `DeviceController` - Manages device connection
- Both extend `ChangeNotifier`
- Views use `Consumer` and `context.watch/read`

## 🔌 Repository Pattern

### Current: Mock Implementation

```dart
MockBloodPressureRepository
MockDeviceRepository
```

### Future: Firebase/API Implementation

To integrate with Firebase or an API:

1. Create new implementation:

```dart
class FirebaseBloodPressureRepository implements BloodPressureRepository {
  // Implement interface methods
}
```

2. Swap in `main.dart`:

```dart
final bpRepository = FirebaseBloodPressureRepository();
```

No other code changes needed! ✅

## 🎨 UI/UX Design

### Accessibility Features

- **Large fonts** (32-56px for main values)
- **High contrast** colors
- **Simple navigation** with bottom tabs
- **Touch-friendly** button sizes (48px minimum)
- **Clear visual feedback** for all actions

### Color Coding

- **Blue** - Systolic BP
- **Purple** - Diastolic BP
- **Green** - Normal/Success
- **Orange** - Warning/Elevated
- **Red** - Danger/Critical

## 🧪 Testing Strategy

### Widget Tests

Located in `test/widget_test.dart`:

- Navigation flow tests
- Screen loading tests
- Component integration tests

### Running Tests

```bash
flutter test
```

## 📱 Features Implemented

### Home Screen

- ✅ Real-time BP monitoring
- ✅ Connection status display
- ✅ Current reading card (BP + HR)
- ✅ Live trend chart (dual-line graph)
- ✅ Action buttons (Pause/Sync)
- ✅ Pull-to-refresh

### Future Screens

- 📋 History - Historical data and trends
- 🔔 Alerts - System alerts and notifications
- ⚙️ Settings - App configuration

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code

### Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📚 Dependencies

- `provider: ^6.1.1` - State management
- `fl_chart: ^0.68.0` - Chart visualization
- `intl: ^0.19.0` - Date/time formatting

## 🔮 Future Enhancements

### Integration Points

- [ ] Firebase Authentication
- [ ] Firestore for data storage
- [ ] Bluetooth LE for device communication
- [ ] Push notifications for alerts
- [ ] Export data to PDF/CSV
- [ ] Multi-user support
- [ ] Caregiver monitoring dashboard

### Features

- [ ] Historical data analysis
- [ ] Customizable alerts
- [ ] Medication reminders
- [ ] Doctor appointment scheduling
- [ ] Health report generation

## 👥 Contributing

When adding new features:

1. Follow the existing architecture pattern
2. Maintain SRP, OCP, and DIP principles
3. Add appropriate tests
4. Update this documentation
5. Ensure accessibility compliance

## 📄 License

[Add license information here]
