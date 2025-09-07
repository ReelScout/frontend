# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuration

- API base URL is provided via `--dart-define`:
  - Run: `flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1`
  - Build: `flutter build <platform> --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1`
- In debug, API requests/responses are logged via Dio's `LogInterceptor`.

## Dependency Injection

- Dependencies are wired with `injectable`/`get_it`.
- After changing DI annotations, regenerate with:
  - `dart run build_runner build --delete-conflicting-outputs`

## Linting

- Stronger lints and analyzer settings are enabled in `analysis_options.yaml`.
- Prefer `package:frontend/...` imports over relative imports.
