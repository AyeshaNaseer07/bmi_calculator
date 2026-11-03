import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';

import 'main.dart' as app;

/// Debug entry point that starts the app simulated as an iPad, so the tablet
/// layout can be checked on a phone:
///   flutter run -t lib/main_preview.dart
/// Use the floating devices button to switch to another device at runtime.
/// Simulation is off in release builds, where this behaves like main.dart.
void main() {
  DevicePreview.enable();
  DevicePreview.maybeController?.applyPreset(DevicePresets.iPadPro11M4);
  app.main();
}
