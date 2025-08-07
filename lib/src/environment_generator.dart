import 'dart:io';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dezerv_env_annotation/dezerv_env_annotation.dart';
import 'package:source_gen/source_gen.dart';

class EnvironmentGenerator extends GeneratorForAnnotation<DezervEnvironment> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (!buildStep.inputId.path.startsWith('lib/')) {
      return '';
    }

    final envFile = File('.env');
    if (!envFile.existsSync()) {
      throw Exception('Generator Error: `.env` file not found.');
    }

    final lines = envFile.readAsLinesSync();
    final envMap = <String, String>{};
    for (final line in lines) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;
      final parts = line.split('=');
      if (parts.length >= 2) {
        final key = parts.first.trim();
        final value = parts.sublist(1).join('=').trim();
        envMap[key] = _escapeDartString(value);
      }
    }

    final fieldNames = envMap.keys.toList();
    if (fieldNames.isEmpty) {
      throw Exception('Generator Error: `.env` file is empty.');
    }

    final buffer = StringBuffer();
    _generateHeader(buffer);
    _generateAppEnvironmentInterface(buffer, fieldNames);
    _generateEnviedWebConfig(buffer, fieldNames, envMap); // For web
    _generateFlutterConfigMobile(buffer, fieldNames); // For mobile
    _generateAppConfigFacade(buffer, fieldNames);

    return buffer.toString();
  }

  String _escapeDartString(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  }

  String _toCamelCase(String str) {
    final parts = str.toLowerCase().split('_');
    if (parts.isEmpty) return '';
    final buffer = StringBuffer(parts.first);
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase() + parts[i].substring(1));
      }
    }
    return buffer.toString();
  }

  void _generateHeader(StringBuffer buffer) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln();
  }

  void _generateAppEnvironmentInterface(
      StringBuffer buffer, List<String> fieldNames) {
    buffer.writeln('\nabstract class AppEnvironment {');
    for (final field in fieldNames) {
      buffer.writeln('  String get ${_toCamelCase(field)};');
    }
    buffer.writeln('}');
  }

  void _generateEnviedWebConfig(StringBuffer buffer, List<String> fieldNames,
      Map<String, String> envMap) {
    buffer.writeln('\n/// Web implementation (uses compile-time constants)');
    buffer.writeln('class _WebEnvConfig implements AppEnvironment {');
    buffer.writeln('  const _WebEnvConfig();');
    for (final field in fieldNames) {
      final camel = _toCamelCase(field);
      final value = envMap[field]!;
      buffer.writeln("  @override\n  String get $camel => '$value';");
    }
    buffer.writeln('}');
  }

  void _generateFlutterConfigMobile(
      StringBuffer buffer, List<String> fieldNames) {
    buffer.writeln('\n/// Mobile implementation (uses flutter_config)');
    buffer.writeln('class _MobileFlutterConfig implements AppEnvironment {');
    buffer.writeln('  _MobileFlutterConfig._();');
    buffer.writeln('\n  static Future<_MobileFlutterConfig> create() async {');
    buffer.writeln('    await FlutterConfig.loadEnvVariables();');
    buffer.writeln('    return _MobileFlutterConfig._();');
    buffer.writeln('  }');

    for (final field in fieldNames) {
      final camel = _toCamelCase(field);
      buffer.writeln(
          "  @override\n  String get $camel => FlutterConfig.get('$field');");
    }
    buffer.writeln('}');
  }

  void _generateAppConfigFacade(StringBuffer buffer, List<String> fieldNames) {
    buffer.writeln('\n/// Unified access point');
    buffer.writeln('class AppConfig {');
    buffer.writeln('  static late final AppEnvironment _instance;');
    buffer.writeln('  AppConfig._();');
    buffer.writeln('\n  static Future<void> initialize() async {');
    buffer.writeln('    if (kIsWeb) {');
    buffer.writeln('      _instance = const _WebEnvConfig();');
    buffer.writeln('    } else {');
    buffer.writeln('      _instance = await _MobileFlutterConfig.create();');
    buffer.writeln('    }');
    buffer.writeln('  }');

    for (final field in fieldNames) {
      final camel = _toCamelCase(field);
      buffer.writeln('  static String get $camel => _instance.$camel;');
    }

    buffer.writeln('}');
  }
}
