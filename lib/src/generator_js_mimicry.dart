part of jsMimicry.generator;

class GeneratorJsMimicry {
  Map<String, String> superClassByClass = {};
  Map<String, DartClassInfo> classInfo = {};
  Map<AssetId, String> _importPrefix = {};
  static const String NAME_jsProxyBootstrap = "jsProxyBootstrap";
  GeneratorJsMimicry() {}

  _superClassLink() {
    classInfo.forEach((className, info) {
      if (info.superClazz != null) {
        var parenClassInfo = classInfo[info.superClazz.dartClassName];
        if (parenClassInfo != null) {
          info.superClazz = parenClassInfo.clazz;
        }
      }
    });
  }

  String _assetIdToImport(AssetId id) {
    //js_test|lib/test1.dart
    if (id.path.startsWith('lib/')) {
      return 'package:${id.package}/${id.path.substring(4)}';
    }
    return id.path.substring(id.path.indexOf("/") + 1);
  }

  generateProxyFile(StringBuffer sb /*, String outputFileName*/) {
    _superClassLink();

    //  outputFileName = path.normalize(path.absolute(path.dirname(outputFileName)));
    sb.writeln("library jsProxy;");
    sb.writeln(r"/* AUTO-GENERATED FILE.  DO NOT MODIFY.*/");
    sb.writeln("");
    sb.writeln("import 'dart:js' as js;");
    sb.writeln(
        "import 'package:js_mimicry/annotation.dart' as ${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX};");
    sb.writeln("");
    _importPrefix.forEach((importAssetId, importPrefix) {
      sb.writeln(
          "import '${_assetIdToImport(importAssetId)}' as ${importPrefix};");
    });

    sb.writeln("");
    sb.writeln("//--------------------------");
    sb.writeln("//  ${NAME_jsProxyBootstrap}");
    sb.writeln("//--------------------------");
    sb.writeln("void ${NAME_jsProxyBootstrap}(){");
    classInfo.forEach((k, v) {
      sb.writeln(
          "${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.JsProxyFactory_CLASS}.registrationPrototype.add(${v.clazz.dartProxyClass}.${DartClassInfo.NAME_REG_PROTOTYPE_METHOD});");
      sb.writeln(
          "${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.JsProxyFactory_CLASS}.toJS[${v.clazz.importDartClassName}] = ${v.clazz.dartProxyClass}.${DartClassInfo.NAME_TO_JS_METHOD};");
      sb.writeln(
          "${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.JsProxyFactory_CLASS}.toDart[${v.clazz.importDartClassName}] = ${v.clazz.dartProxyClass}.${DartClassInfo.NAME_TO_DART_METHOD};");
    });
    sb.writeln("}");

    sb.writeln("dynamic _toDart(value){");
    sb.writeln("""
    if (value != null && (value is js.JsObject) && value['${DartClassInfo.DART_OBJ_KEY}']!=null){
     return value['${DartClassInfo.DART_OBJ_KEY}'];
    }
    return value;
    """);
    sb.writeln("}");

    sb.writeln("dynamic _toJs(value){");
    sb.writeln("""
    if (value is ${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.JsProxyContainer_KEY}){
      return value.${DartClassInfo.JS_INSTANCE_PROXY};
    }
    return value;
    """);
    sb.writeln("}");

    sb.writeln("");
    classInfo.forEach((k, v) {
      sb.writeln("");
      sb.writeln("//--------------------------");
      sb.writeln("//   ${v.clazz.importDartClassName} -> ${v.clazz.jsPath}");
      sb.writeln("//--------------------------");
      v.generateProxyClass(sb);
    });
  }

  int _importPrefixIndex = 0;

  void phase1(ClassDeclaration node, AssetId assetId) {
    //uri = 'asset:js_mimicry/test/test1.dart'
    String classPrefix =
        _importPrefix.putIfAbsent(assetId, () => "I${_importPrefixIndex++}_");
    var collector = new CollectorVisitor(this, classPrefix);
    node.accept(collector);
  }
}
