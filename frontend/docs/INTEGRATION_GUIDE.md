# Integration Guide - Health Monitoring Screens

## Quick Start

This guide will help you integrate the new health monitoring screens into your Healio Flutter app.

## Step 1: Verify File Structure

Ensure all the following files are present in your `lib/screens/` directory:

```
lib/screens/
├── blood_pressure_screen.dart    (NEW)
├── blood_sugar_screen.dart       (NEW)
├── body_temperature_screen.dart  (NEW)
├── spo2_screen.dart             (NEW)
├── vitals_analysis.dart         (UPDATED)
├── dashboard.dart               (UPDATED)
├── bmi_calculator.dart
├── heart_rate.dart
├── profile.dart
├── login.dart
├── nearbyservices.dart
├── edit_profile.dart
└── user_data.dart
```

## Step 2: Dependencies Check

Make sure your `pubspec.yaml` has the required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

No additional packages are required for these screens!

## Step 3: Test the Integration

### 3.1 Run the App
```bash
flutter clean
flutter pub get
flutter run
```

### 3.2 Navigate Through the App

1. **Login Screen** → Enter user details
2. **Dashboard** → Tap "Vitals Analysis"
3. **Vitals Analysis** → You'll see all 6 health monitors:
   - BMI Checker
   - Heart Rate
   - Blood Sugar (NEW)
   - Body Temperature (NEW)
   - Blood Pressure (NEW)
   - SpO₂ (NEW)

### 3.3 Test Each Screen

**Blood Pressure:**
- Enter Systolic: 130
- Enter Diastolic: 95
- Tap "Check Blood Pressure"
- Should show: "Stage 2 Hypertension" in red

**Blood Sugar:**
- Enter Fasting: 100
- Enter Post-meal: 140
- Tap "Check Blood Sugar"
- Should show: "Prediabetic Range" in yellow

**Body Temperature:**
- Toggle to °F (or °C)
- Enter: 101
- Tap "Check Temperature"
- Should show: "Fever" in yellow

**SpO₂:**
- Enter: 98
- Tap "Check SpO₂"
- Should show: "Normal" in green

## Step 4: Customization Options

### 4.1 Change Color Scheme

If you want to change the primary color from teal to another color:

**In each screen file**, find and replace:
```dart
const Color(0xFF4DB6AC)  // Current teal color
```

With your preferred color, e.g.:
```dart
const Color(0xFF6200EE)  // Purple
const Color(0xFF2196F3)  // Blue
const Color(0xFF4CAF50)  // Green
```

### 4.2 Modify Health Ranges

To adjust the classification ranges for health metrics:

**Blood Pressure** (in `blood_pressure_screen.dart`):
```dart
if (systolic < 120 && diastolic < 80) {
  _result = 'Normal';
  // Modify these values as needed
}
```

**Blood Sugar** (in `blood_sugar_screen.dart`):
```dart
if (fasting < 100 && postMeal < 140) {
  _result = 'Normal';
  // Modify these values as needed
}
```

### 4.3 Add History Tracking

To add history tracking for each vital sign, you could:

1. Create a new model class:
```dart
class VitalReading {
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> values;
  final String result;
}
```

2. Store readings using `shared_preferences` or a local database

3. Display history in a list view

## Step 5: Common Issues & Solutions

### Issue 1: Navigation Not Working
**Solution:** Ensure all imports are correct at the top of `vitals_analysis.dart`:
```dart
import 'blood_pressure_screen.dart';
import 'blood_sugar_screen.dart';
import 'body_temperature_screen.dart';
import 'spo2_screen.dart';
```

### Issue 2: Colors Not Displaying Correctly
**Solution:** The color values must be in hex format with `0xFF` prefix:
```dart
const Color(0xFF4DB6AC)  ✓ Correct
Color(#4DB6AC)           ✗ Wrong
```

### Issue 3: Input Validation Errors
**Solution:** All screens have built-in validation. Check that:
- TextEditingControllers are properly disposed
- Input fields use correct keyboard types:
  - `TextInputType.number` for integers
  - `TextInputType.numberWithOptions(decimal: true)` for decimals

### Issue 4: Build Errors
**Solution:** Run these commands:
```bash
flutter clean
flutter pub get
flutter run
```

## Step 6: Testing Checklist

- [ ] App launches without errors
- [ ] Dashboard displays correctly with new UI
- [ ] "Vitals Analysis" card navigates to vitals screen
- [ ] All 6 vital monitors are visible
- [ ] Blood Pressure screen works and shows correct results
- [ ] Blood Sugar screen works and shows correct results
- [ ] Body Temperature screen works with C/F toggle
- [ ] SpO₂ screen works with subscript formatting
- [ ] "Check Another" buttons reset the forms
- [ ] Back navigation works from all screens
- [ ] Bottom navigation bar works correctly

## Step 7: Next Steps

### Add More Features:
1. **History Tracking** - Store and display past readings
2. **Export Data** - Generate PDF reports
3. **Reminders** - Set up notifications for regular checkups
4. **Trends** - Show graphs of vital signs over time
5. **Doctor Integration** - Share results with healthcare providers

### Performance Optimization:
1. Use `const` constructors where possible
2. Minimize rebuilds using `setState` carefully
3. Add loading indicators for async operations
4. Implement error handling for edge cases

## Support & Documentation

For more details, see:
- `HEALTH_MONITORS_README.md` - Overview of all features
- Flutter documentation: https://flutter.dev/docs
- Material Design: https://material.io/

## Version History

- **v2.0** - Added Blood Pressure, Blood Sugar, Temperature, SpO₂ monitors
- **v1.0** - Initial release with BMI and Heart Rate

---

**Need Help?** Check the code comments in each screen file for detailed explanations.
