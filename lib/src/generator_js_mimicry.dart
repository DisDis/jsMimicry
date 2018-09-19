part of jsMimicry.generator;

class GeneratorJsMimicry {
  Map<String, DartClassInfo> classInfo = {};
  Map<AssetId, DartLibraryMetadata> importPrefix = {};
  static const String NAME_jsProxyBootstrap = "jsProxyBootstrap";
  final MimicryResolver resolver;
  final TypeProviderHelper typeProviderHelper;
  GeneratorJsMimicry(this.resolver, this.typeProviderHelper) {}

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

  DartLibraryMetadata addImport(AssetId classAssetId, {String forceNamespace}) {
    return importPrefix.putIfAbsent(
        classAssetId, () => new DartLibraryMetadata(classAssetId,forceNamespace != null ? forceNamespace : "I${_importPrefixIndex++}_"));
  }

  String generateProxyFile(/*, String outputFileName*/) {
    _superClassLink();

    StringBuffer resultSb = new StringBuffer();

    //  outputFileName = path.normalize(path.absolute(path.dirname(outputFileName)));
    StringBuffer sb = new StringBuffer();

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

    sb.writeln("dynamic _toDart(dynamic value){");
    sb.writeln("""
    if (value != null && (value is js.JsObject) && value['${DartClassInfo.DART_OBJ_KEY}']!=null){
     return value['${DartClassInfo.DART_OBJ_KEY}'];
    }
    return value;
    """);
    sb.writeln("}");

    sb.writeln("dynamic _toJs<T>(T value){");
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

    resultSb.writeln("library jsproxy;");
    resultSb.writeln(r"/* AUTO-GENERATED FILE.  DO NOT MODIFY.*/");
    resultSb.writeln("");
    resultSb.writeln("// ignore_for_file: library_prefixes");
    resultSb.writeln("// ignore_for_file: non_constant_identifier_names");
    resultSb.writeln("// ignore_for_file: argument_type_not_assignable");
    resultSb.writeln("// ignore_for_file: invalid_assignment");
    resultSb.writeln("");
    resultSb.writeln("import 'dart:js' as ${DartClassInfo.NAME_SPACE_DART_JS};");
    resultSb.writeln(
        "import 'package:js_mimicry/annotation.dart' as ${DartClassInfo.NAME_IMPORT_ANNOTATION_PREFIX};");
    resultSb.writeln("");
    importPrefix.forEach((importAssetId, library) {
      resultSb.writeln(
          "import '${library.import}' as ${library.importPrefix};");
    });

    resultSb.write(sb.toString());

    return resultSb.toString();
  }

  int _importPrefixIndex = 0;

  DartLibraryMetadata addImportForDartType(DartType type) {
    var library = type.element?.library;
    if (library != null && !library.isInSdk) {
      return genImportLibraryPrefix(library);
    }
    return null;
  }

  DartLibraryMetadata genImportLibraryPrefix(LibraryElement library, {String forceNamespace}) {
    var classAssetId = resolver.getSourceAssetId(library);
    return addImport(classAssetId, forceNamespace: forceNamespace);
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
