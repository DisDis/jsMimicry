part of jsMimicry.generator;

class GeneratorJsMimicry {
  Map<String, DartClassInfo> classInfo = {};
  Map<AssetId, DartLibraryMetadata> _importPrefix = {};
  static const String NAME_jsProxyBootstrap = "jsProxyBootstrap";
  final Resolver resolver;
  GeneratorJsMimicry(this.resolver) {}

  _superClassLink() {
    classInfo.forEach((className, info) {
      if (info.superClazz != null) {
        var parenClassInfo = classInfo[info.superClazz.importDartClassName];
        if (parenClassInfo != null) {
          info.superClazz = parenClassInfo.clazz;
        }
      }
    });
  }

  static ElementAnnotation getAnnotationFromElement(Element clazz) {
    return clazz.metadata.firstWhere((ElementAnnotation item) => item.element?.enclosingElement?.displayName == DartClassInfo.ANNOTATION_CLASS, orElse:() => null);
  }

  static Annotation getAnnotation(ClassDeclaration node) {
    if (node.metadata != null) {
      return node.metadata.firstWhere(
              (ann) => ann.name.toString() == DartClassInfo.ANNOTATION_CLASS,
          orElse: () => null);
    } else {
      return null;
    }
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
    _importPrefix.forEach((importAssetId, library) {
      sb.writeln(
          "import '${library.import}' as ${library.importPrefix};");
    });

    sb.writeln("");
    sb.writeln("//--------------------------");
    sb.writeln("//  ${NAME_jsProxyBootstrap}");
    sb.writeln("//--------------------------");
    sb.writeln("void ${NAME_jsProxyBootstrap}(){");
    classInfo.forEach((k, v) {
      sb.writeln(
          """${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.NAME_PROXY_FACTORY}.registration(
              ${v.clazz.importDartClassName}, ${v.clazz.dartProxyClass}.${DartClassInfo.NAME_REG_PROTOTYPE_METHOD},
                 ${v.clazz.dartProxyClass}.${DartClassInfo.NAME_TO_JS_METHOD}, ${v.clazz.dartProxyClass}.${DartClassInfo.NAME_TO_DART_METHOD});""");
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
    if (value is ${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX}.${DartClassInfo.NAME_JS_PROXY_INTERFACE}){
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

  DartLibraryMetadata genImportLibraryPrefix(LibraryElement library) {
    var classAssetId = resolver.getSourceAssetId(library);
    return _importPrefix.putIfAbsent(
        classAssetId, () => new DartLibraryMetadata(classAssetId,"I${_importPrefixIndex++}_"));
  }

  void phase1(ClassElement clazz) {
    ClassDeclaration node = clazz.computeNode();
    var collector = new CollectorVisitor(this);
    node.accept(collector);
//    var dci = new DartClassInfo(annotation, node, this);
//    classInfo[dci.clazz.importDartClassName] = dci;
  }

  DartMethodMetadata getMethodMetadata(Identifier v) {
    var m = v.staticElement;
    Declaration mnode = m.computeNode();
    DartMethodMetadata methodMetadata;
    if (mnode is MethodDeclaration && mnode.isStatic) {
      ClassDeclaration clazz = mnode.parent;
      //print("${clazz.element.name}.${m.name} staticElement:${m} ${mnode.runtimeType} ${clazz.element.library}");
      var library = genImportLibraryPrefix(clazz.element.library);
      methodMetadata = new DartMethodMetadata.fromClass(m.name, new DartClassMetadata(clazz.element.name, library));
    } else if (mnode is FunctionDeclaration) {
      CompilationUnit parent = mnode.parent;
      //print("${m.name} staticElement:${m} ${mnode.runtimeType} ${parent.element.library}");
      methodMetadata = new DartMethodMetadata.fromLibrary(m.name, genImportLibraryPrefix(parent.element.library));
    }
    return methodMetadata;
  }
}
