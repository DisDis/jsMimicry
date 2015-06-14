part of jsMimicry.generator;

class DartMethodMetadata {
  final String name;
  final DartClassMetadata clazz;
  final DartLibraryMetadata library;
  DartMethodMetadata.fromClass(this.name, DartClassMetadata clazz):this.library=clazz.library,this.clazz=clazz;
  DartMethodMetadata.fromLibrary(this.name, this.library):this.clazz=null;
  toString() =>
      "${library.importPrefix}.${clazz!=null?clazz.name+'.':''}${name}";
}

class DartClassMetadata {
  final DartLibraryMetadata library;
  final String name;
  DartClassMetadata(this.name, this.library);
}

class DartLibraryMetadata {
  final String importPrefix;
  final String import;

  static String _assetIdToImport(AssetId id) {
    //js_test|lib/test1.dart
    if (id.path.startsWith('lib/')) {
      return 'package:${id.package}/${id.path.substring(4)}';
    }
    return id.path.substring(id.path.indexOf("/") + 1);
  }

  DartLibraryMetadata(AssetId assetId, this.importPrefix)
      : this.import = _assetIdToImport(assetId);
}
