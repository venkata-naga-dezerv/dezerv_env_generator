// dezerv_env_generator/lib/builder.dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dezerv_env_generator/src/environment_generator.dart';

Builder environmentBuilder(BuilderOptions options) {
  return PartBuilder([EnvironmentGenerator()], '.g.dart');
}
