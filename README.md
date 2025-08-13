Dezerv Environment Generator ⚙️
A powerful build-time code generator for Flutter projects that creates a unified, type-safe API for accessing environment variables on both Mobile and Web platforms.

This generator reads your environment variable keys from a .env.sample file and automatically generates all the necessary Dart code to provide a simple, consistent AppConfig class.

✨ Features
Type-Safe & Simple API: Access all your environment variables through a clean, static class (AppConfig.someVariable) with no magic strings.

Platform-Specific Implementations: Automatically uses the best tool for each platform:

📱 Mobile (iOS/Android): Uses flutter_config for its robust native support and ability to handle build flavors.

🌐 Web: Uses String.fromEnvironment to support compile-time variable injection via --dart-define and --dart-define-from-file, which is ideal for CI/CD pipelines.

Single Source of Truth for Keys: Reads all required variable names from a single .env.sample file in your project root, ensuring consistency.

Zero Boilerplate: Eliminates the need to manually write platform-switching logic or configuration classes.

🚀 Setup
Follow these steps to integrate the generator into your Flutter project.

1. Update pubspec.yaml
Add the necessary dependencies to your project's pubspec.yaml file. The generator itself is a dev_dependency, while the runtime packages are regular dependencies.

# pubspec.yaml

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
    path: ../dezerv_env_generator # Or from pub.dev

After updating, run flutter pub get.

2. Create .env.sample File
In the root directory of your project, create a file named .env.sample. This file defines the structure of your environment variables. The generator reads this file to know which fields to create.

# .env.sample

ENV=
DEFAULT_BASE_URL=
MIXPANEL_PROJECT_TOKEN=
FIREBASE_APP_NAME=
# ... add all other required keys

3. Create the "Anchor" File
Create a new file in your project, for example, at lib/config/env.env.dart. This file tells the generator where to run.

Important: The file name must end with the .env.dart extension.

// lib/config/env.env.dart

import 'package:flutter/foundation.dart';
// This single import provides the annotation and flutter_config
import 'package:dezerv_env_generator/dezerv_env_generator.dart';

@dezervEnvironment
part 'env.g.dart';

4. Run the Code Generator
From the root of your project, run the build_runner command. This will generate the lib/config/env.g.dart file.

dart run build_runner build --delete-conflicting-outputs

5. Native Setup for Mobile
For the mobile implementation to work, you must perform the one-time native setup for the flutter_config package.

Follow the instructions to configure your android/app/build.gradle and Xcode build phases.

🛠️ How to Use
1. Initialize in main()
Before your app runs, you must call the asynchronous initialize() method to load the correct configuration for the current platform.

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:your_app/config/env.env.dart'; // Import your anchor file

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the AppConfig before running the app
  await AppConfig.initialize();

  runApp(const MyApp());
}

2. Access Variables Anywhere
Once initialized, you can access your environment variables from anywhere in your app using the static getters on the AppConfig class.

import 'package:your_app/config/env.env.dart';

class MyApiService {
  void connect() {
    // The generator converts SNAKE_CASE to camelCase
    final baseUrl = AppConfig.defaultBaseUrl;
    final mixpanelToken = AppConfig.mixpanelProjectToken;

    print('Connecting to API at: $baseUrl');
    print('Initializing Mixpanel with token: $mixpanelToken');
  }
}

🚢 Web Deployment & CI/CD
The web implementation is designed to work with the --dart-define-from-file flag, making it perfect for CI/CD.

Create a JSON Configuration File: In your deployment pipeline, create a JSON file (e.g., env.json) containing your environment-specific values.

{
  "ENV": "production",
  "DEFAULT_BASE_URL": "https://api.production.dezerv.in",
  "MIXPANEL_PROJECT_TOKEN": "your_production_token"
}

Build Your App: Use the --dart-define-from-file flag in your flutter build command to inject these values at compile time.

flutter build web --dart-define-from-file=env.json --base-href "/your-app/"

📄 Sample Generated File (env.g.dart)
For reference, here is an example of the code that the generator automatically creates for you. You should never edit this file manually.

// AUTO-GENERATED FILE BY DEZERV_ENV_GENERATOR. DO NOT MODIFY.
// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

part of 'env.env.dart';

/// A contract defining the required environment variables.
abstract class AppEnvironment {
  String get env;
  String get defaultBaseUrl;
  String get mixpanelProjectToken;
  String get firebaseAppName;
}

/// Web implementation (uses --dart-define for values)
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

/// Mobile implementation (uses flutter_config)
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

/// Unified access point
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
