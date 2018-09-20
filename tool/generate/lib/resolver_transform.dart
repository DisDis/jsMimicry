library wrike_model_generator.src.resolver_transform;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as path;

/// Resolver transform is used for model generator resolver.
class ResolverTransform implements Transform{
  @override
  void addOutput(Asset output) {
    return null;
  }

  @override
  void consumePrimary() {
    return null;
  }

  @override
  Future<Asset> getInput(AssetId id) {
    return null;
  }

  @override
  Future<bool> hasInput(AssetId id) {
    return null;
  }

  @override
  TransformLogger get logger => null;

  @override
  Asset get primaryInput =>
      /// We need this fake asset for Resolvers.get method.
  new Asset.fromString(new AssetId("", ""), "");

  @override
  Stream<List<int>> readInput(AssetId id) {
    return null;
  }

  @override
  Future<String> readInputAsString(AssetId assetId, {Encoding encoding}) {
    String filename = assetId.path;
    if (filename.startsWith('lib/')) {
      filename = path.join('packages', '${assetId.package}',
          '${filename.replaceFirst('lib/', '')}');
    }
    return new File(path.absolute(filename)).readAsString();
  }
}
