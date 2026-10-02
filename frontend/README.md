# biblione

## Run on the Android device

In VS Code, open **Terminal → Run Task…** (or press `Ctrl+Shift+P` and choose
**Tasks: Run Task**), then select **Flutter: Run on 25028RN03A**. This runs the
app with the local API and Google Books configuration from `dart_defines.json`.

The local config is ignored by Git so API keys are not added to commits. If it
is missing, copy `dart_defines.example.json` to `dart_defines.json` and fill in
your values. The phone and API server must be reachable on the same network.

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
