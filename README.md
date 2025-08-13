# Dezerv Environment Generator

A build-time code generator for Flutter projects that creates a unified, type-safe API for accessing environment variables on both mobile and web platforms.

This generator reads environment variable keys from a `.env.sample` file and automatically generates all the necessary Dart code to provide a simple, consistent `AppConfig` class.

---

## Features

* **Type-Safe & Simple API**
  Access all environment variables through a clean, static class (`AppConfig.someVariable`) without using magic strings.

* **Platform-Specific Implementations**
  Automatically uses the optimal tool for each platform:

  * **Mobile (iOS/Android):** Uses `flutter_config` for robust native support and build flavor handling.
  * **Web:** Uses `String.fromEnvironment` for compile-time variable injection via `--dart-define` or `--dart-define-from-file`, ideal for CI/CD.

* **Single Source of Truth for Keys**
  Reads all required variable names from a single `.env.sample` file, ensuring consistency.

* **Zero Boilerplate**
  Eliminates the need for manually writing platform-switching logic or configuration classes.

---

## Setup

### 1. Update `pubspec.yaml`

Add the dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Runtime dependencies required by the generated code
  flutter_config: ^2.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9

  # Your generator package
  dezerv_env_generator:
    path: ../dezerv_env_generator # Or use a published version
```

Run:

```bash
flutter pub get
```

---

### 2. Create `.env.sample`

In your project root, create `.env.sample` to define the structure of environment variables:

```dotenv
ENV=
DEFAULT_BASE_URL=
MIXPANEL_PROJECT_TOKEN=
FIREBASE_APP_NAME=
# Add additional keys as required
```

---

### 3. Create the Anchor File

Create `lib/config/env.env.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:dezerv_env_generator/dezerv_env_generator.dart';

@dezervEnvironment
part 'env.g.dart';
```

> **Note:** The file name must end with `.env.dart`.

---

### 4. Run the Code Generator

From the root directory:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `lib/config/env.g.dart`.

---

### 5. Native Setup for Mobile

For mobile, configure the `flutter_config` package in `android/app/build.gradle` and Xcode build phases.
Follow the official `flutter_config` setup guide.

---

## Usage

### 1. Initialize in `main()`

```dart
import 'package:flutter/material.dart';
import 'package:your_app/config/env.env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  runApp(const MyApp());
}
```

---

### 2. Access Variables Anywhere

```dart
import 'package:your_app/config/env.env.dart';

class MyApiService {
  void connect() {
    final baseUrl = AppConfig.defaultBaseUrl;
    final mixpanelToken = AppConfig.mixpanelProjectToken;

    print('Connecting to API at: $baseUrl');
    print('Initializing Mixpanel with token: $mixpanelToken');
  }
}
```

---

## Web Deployment & CI/CD

The web implementation works with `--dart-define-from-file`.

### Steps:

1. **Create a JSON Configuration File**
   Example: `env.json`

   ```json
   {
     "ENV": "production",
     "DEFAULT_BASE_URL": "https://api.production.dezerv.in",
     "MIXPANEL_PROJECT_TOKEN": "your_production_token"
   }
   ```

2. **Build Your App**

   ```bash
   flutter build web --dart-define-from-file=env.json --base-href "/your-app/"
   ```

---

## Example Generated File (`env.g.dart`)

```dart
// AUTO-GENERATED FILE BY DEZERV_ENV_GENERATOR. DO NOT MODIFY.
// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

part of 'env.env.dart';

abstract class AppEnvironment {
  String get env;
  String get defaultBaseUrl;
  String get mixpanelProjectToken;
  String get firebaseAppName;
}

class _WebEnvConfig implements AppEnvironment {
  const _WebEnvConfig();
  @override
  String get env => const String.fromEnvironment('ENV', defaultValue: 'NOT SET');
  @override
  String get defaultBaseUrl => const String.fromEnvironment('DEFAULT_BASE_URL', defaultValue: 'NOT SET');
  @override
  String get mixpanelProjectToken => const String.fromEnvironment('MIXPANEL_PROJECT_TOKEN', defaultValue: 'NOT SET');
  @override
  String get firebaseAppName => const String.fromEnvironment('FIREBASE_APP_NAME', defaultValue: 'NOT SET');
}

class _MobileFlutterConfig implements AppEnvironment {
  _MobileFlutterConfig._();

  static Future<_MobileFlutterConfig> create() async {
    await FlutterConfig.loadEnvVariables();
    return _MobileFlutterConfig._();
  }

  @override
  String get env => FlutterConfig.get('ENV');
  @override
  String get defaultBaseUrl => FlutterConfig.get('DEFAULT_BASE_URL');
  @override
  String get mixpanelProjectToken => FlutterConfig.get('MIXPANEL_PROJECT_TOKEN');
  @override
  String get firebaseAppName => FlutterConfig.get('FIREBASE_APP_NAME');
}

class AppConfig {
  static late final AppEnvironment _instance;
  AppConfig._();

  static Future<void> initialize() async {
    if (kIsWeb) {
      _instance = const _WebEnvConfig();
    } else {
      _instance = await _MobileFlutterConfig.create();
    }
  }

  static String get env => _instance.env;
  static String get defaultBaseUrl => _instance.defaultBaseUrl;
  static String get mixpanelProjectToken => _instance.mixpanelProjectToken;
  static String get firebaseAppName => _instance.firebaseAppName;
}
```
