# biblione

## Run on the Android device

In VS Code, open **Terminal → Run Task…** (or press `Ctrl+Shift+P` and choose
**Tasks: Run Task**), then select **Flutter: Run on 25028RN03A**. Connect the
phone over USB (with USB debugging enabled), start the backend, then run the
task. It forwards port 8080
over ADB and points the app at `localhost`, so it does not depend on the phone
and computer being on the same Wi-Fi network or on a fixed LAN IP.

The local config is ignored by Git so API keys are not added to commits. If it
is missing, copy `dart_defines.example.json` to `dart_defines.json` and fill in
your Google Books key. The Android VS Code task overrides `API_BASE` for the
ADB-forwarded local API. For other run methods, set `API_BASE` to an address
reachable from that device.

Google Books keys are included in the built app and should not be treated as
secret once distributed. Restrict the key in Google Cloud to the APIs and
applications that need it.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
