// dezerv_env_generator/lib/builder.dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dezerv_env_generator/src/environment_generator.dart';

Builder environmentBuilder(BuilderOptions options) {
  // Read the 'env_path' from build.yaml, defaulting to '.env' if not provided.
  print(options.config['env_path']);
  final String path = options.config['env_path'] as String? ?? '.env.sample';

  // Pass the path to the generator's constructor.
  return PartBuilder([EnvironmentGenerator(path)], '.g.dart');
}
