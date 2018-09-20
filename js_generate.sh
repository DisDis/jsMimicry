reset

# cleaning generator's cache
rm -rf ./.dart_tool/build

# avoiding build errors
cd tool/generate
pub get --packages-dir
cd ../../

dart ./tool/generate/tool/js_resolver_build.dart
