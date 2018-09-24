import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_resolvers/src/resolver.dart';

class MimicryResolver implements Resolver {
  final Resolver _delegate;
  MimicryResolver(this._delegate);

  AssetId getSourceAssetId(Element element) {
    var source = element.source;
    if (source is AssetBasedSource) return source.assetId;
    return null;
  }

  @override
  Future<LibraryElement> findLibraryByName(String libraryName) =>
    _delegate.findLibraryByName(libraryName);

  @override
  Future<bool> isLibrary(AssetId assetId) => _delegate.isLibrary(assetId);

  @override
  Stream<LibraryElement> get libraries => _delegate.libraries;

  @override
  Future<LibraryElement> libraryFor(AssetId assetId) =>
      _delegate.libraryFor(assetId);

}