part of jsMimicry.generator;

class JsClass {
  String jsPath;
  String className;
  String dartClassName;
  DartLibraryMetadata library;
  String get importDartClassName =>
      "${library.importPrefix!=null?library.importPrefix+'.':''}${dartClassName}";
  String get dartProxyClass => "${dartClassName}Proxy";
}

class DartClassInfo {
  List<DartMethodInfo> methods = [];
  final Annotation annotation;
  List<DartMethodInfo> constructors = [];
  List<DartPropertyInfo> properties = [];

  JsClass clazz = new JsClass();
  JsClass superClazz;
  final bool isAbstract;

  static const String ANNOTATION_CLASS = "JsProxy";
  static const String ANNOTATION_METHOD = "JsMutator";
  static const String ANNOTATION_PARAMETER = "JsTransform";

  static const String NAME_REG_PROTOTYPE_METHOD = "jsRegistrationPrototype";
  static const String NAME_TO_JS_METHOD = "toJs";
  static const String NAME_TO_DART_METHOD = "toDart";
  static const String NAME_PROTOTYPE_FLAG = "__prototypeReg";
  static const String DART_OBJ_KEY = "_dartObj";
  static const String NAME_JS_PROXY_INTERFACE = 'JsProxyContainer';
  static const String JS_INSTANCE_PROXY = 'JS_INSTANCE_PROXY';
  static const String NAME_PROXY_FACTORY = 'JsProxyFactory';

  static const String NAME_IMPORT_ANNOTATION_PREFIX = "jsProxy";
  final GeneratorJsMimicry generator;

  _searchJsProxyParent(ClassElement element) {
    while (element != null) {
      if (element.library.isInSdk) {
        return null;
      }
      if (GeneratorJsMimicry.getAnnotationFromElement(element)!=null) {
        JsClass result = new JsClass();
        result.dartClassName = element.name;
        result.library = generator.genImportLibraryPrefix(element.library);
        return result;
      }
      element = element.supertype.element;
    }
    return null;
  }

  DartClassInfo(
      Annotation this.annotation, ClassDeclaration node, this.generator):this.isAbstract = node.isAbstract {
    if (annotation != null) {
      var args = annotation.arguments;
      if (args != null && args.arguments.length != 0) {
        clazz.jsPath = args.arguments[0].value;
        clazz.className = clazz.jsPath.split(".").last;
      } else {
        clazz.jsPath = node.name.toString();
        clazz.className = node.name.toString();
      }
    } else {
      clazz.jsPath = node.name.toString();
      clazz.className = node.name.toString();
    }
    if (node.extendsClause != null) {
        superClazz = _searchJsProxyParent(node.element.supertype.element);
    }
    //getConstructor
    clazz.dartClassName = node.name.toString();
    clazz.library = generator.genImportLibraryPrefix(node.element.library);

    parsingConstructors(node);

    node.accept(new DartClassVisitor(this,generator));
  }

  void parsingConstructors(ClassDeclaration node) {
    node.members
        .where((item) => item is ConstructorDeclaration)
        .forEach((ConstructorDeclaration classMember) {
      var tmp = new DartMethodInfo.fromConstructor(classMember, generator);
      constructors.add(tmp);
    });
  }
  DartMethodInfo addMethod(MethodDeclaration node) {
    var tmp = new DartMethodInfo(node, generator);
    methods.add(tmp);
    if (clazz.dartClassName != clazz.jsPath) {
      //print("dart:${clazz.dartClassName} js:${clazz.jsPath}.${node.name}");
    } else {
      //print("js:${clazz.jsPath}.${node.name}");
    }
    return tmp;
  }

  generateJsRegistrationPrototype(StringBuffer sb) {
    StringBuffer parentCall = new StringBuffer();
    StringBuffer parentCallInt = new StringBuffer();
    var constructorPath = clazz.jsPath.split('.');
    var nameFunction = constructorPath.last;
    String contextB = _getContext(constructorPath);
    String contextParent;
    String parentClass;

    if (superClazz != null && superClazz.jsPath != null) {
      parentCall.writeln("");
      parentCallInt.writeln("");
      contextParent = _getContext(superClazz.jsPath.split('.'));
      parentClass = superClazz.className;
      parentCall.writeln("// Call parent ctor '${parentClass}'");
      parentCallInt.writeln("// Call parent ctor '${parentClass}'");
      parentCall.writeln(
          '''${contextParent}[r"${parentClass}_int"].callMethod('call',[that,_obj_]);''');
      parentCallInt.writeln(
          '''${contextParent}[r"${parentClass}_int"].callMethod('call',[that,_obj_]);''');
    }

    sb.writeln("");
    sb.writeln("""static void $NAME_REG_PROTOTYPE_METHOD(){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
""");
    sb.writeln("""if ($NAME_PROTOTYPE_FLAG) {
      return;
    }""");
    if (superClazz != null && superClazz.jsPath != null) {
      sb.writeln(
          """${superClazz.dartProxyClass}.$NAME_REG_PROTOTYPE_METHOD();""");
    }
    sb.writeln("""$NAME_PROTOTYPE_FLAG = true;
     var context = ${contextB};""");
    sb.writeln("""// Constructors""");
    _generatePrototypeConstructors(sb, parentCall);
    if (superClazz != null && superClazz.jsPath != null) {
      sb.writeln("""var F = new js.JsFunction.withThis((that){});
F["prototype"]=${contextParent}[r"${parentClass}"]["prototype"];
context[r"${nameFunction}"]["prototype"] = new js.JsObject(F);
context[r"${nameFunction}"]["prototype"]["constructor"] = context[r"${nameFunction}"];
""");
    }
    sb.writeln("""// Methods""");
    sb.writeln("""var proto = context[r"${nameFunction}"]["prototype"];""");
    methods.forEach((v) {
      v.getMethodCode(sb, clazz);
    });
    sb.writeln("""// Constructor for method toJs""");
    sb.writeln(
        """context[r"${nameFunction}_int"] = new js.JsFunction.withThis((that, _obj_) {
      //print(r"ctr:${clazz.jsPath}_int");
      that[r"${DART_OBJ_KEY}"] = _obj_;$parentCallInt
    });""");
    sb.writeln("""// Constructors connect to prototype""");
    constructors.forEach((ctr) {
      if (ctr.name != null) {
        sb.writeln(
            """context[r"${nameFunction}_${ctr.name}"]["prototype"] = proto;""");
      }
    });
    sb.writeln("//   internal constructor");
    sb.writeln('context[r"${nameFunction}_int"]["prototype"] = proto;');
    sb.writeln("""// Properties""");
    properties.forEach((prop) => prop.getCode(sb, clazz));
    sb.writeln("    }" "");
  }

  void _generatePrototypeConstructors(
      StringBuffer sb, StringBuffer parentCall) {
    if (constructors.length == 0) {
      new DartMethodInfo.empty(null).getConstructorCode(this,
          sb, parentCall.toString());
    } else {
      constructors.forEach((ctr) {
        ctr.getConstructorCode(this,sb, parentCall.toString());
      });
    }
  }

  generateToJS(StringBuffer sb) {
    var constructorPath = clazz.jsPath.split('.');
    String contextB = _getContext(constructorPath);
    var nameFunction = constructorPath.last;
    sb.writeln("");
    sb.writeln(
        """static js.JsObject $NAME_TO_JS_METHOD(${clazz.importDartClassName} obj){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/""");
    sb.writeln("""
    $NAME_REG_PROTOTYPE_METHOD();
    return new js.JsObject(${contextB}["${nameFunction}_int"], [obj]);}""");
  }

  void generateToDart(StringBuffer sb) {
    sb.writeln("");
    sb.writeln("""static ${clazz.importDartClassName} $NAME_TO_DART_METHOD(obj){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/""");
    sb.writeln("""if (obj==null){
 return null;
}else if (obj is ${clazz.importDartClassName}){
 return obj;
}else if (obj is js.JsObject){
 return obj[r"${DART_OBJ_KEY}"] as ${clazz.importDartClassName};
} else{
 throw new Exception('Unknown \$obj');
}
}""");
  }

  FunctionBody jsRegistrationPrototypeBody(BlockFunctionBody oldBody) {
    StringBuffer sb = new StringBuffer();
    generateJsRegistrationPrototype(sb);
    var astF = parseCompilationUnit(sb.toString());
    FunctionDeclaration fd = astF.declarations[0];
    var astClone = new AstCloner();
    return astClone.cloneNode(fd.functionExpression.body);
  }

  generateProxyClass(StringBuffer sb) {
    sb.writeln("""abstract class ${clazz.dartProxyClass} {""");
    sb.writeln('static bool ${DartClassInfo.NAME_PROTOTYPE_FLAG} = false;');
    generateJsRegistrationPrototype(sb);
    generateToJS(sb);
    generateToDart(sb);
    sb.writeln("}");
  }

  String _getContext(List<String> constructorPath) {
    StringBuffer contextB = new StringBuffer("js.context");
    if (constructorPath.length > 1) {
      constructorPath.take(constructorPath.length - 1).forEach((item) {
        contextB.write('[r"$item"]');
      });
    }
    return contextB.toString();
  }

  void addField(FieldDeclaration node) {
    node.fields.variables.forEach((VariableDeclaration vitem) {
      if (vitem.name.toString().startsWith("_")) {
        return;
      }
      properties.add(new DartPropertyInfo.field(vitem));
      //print("addField: ${ node.fields} ${vitem.name.toString()}");
    });
  }

  addProperty(MethodDeclaration node) {
    var name = node.name.toString();
    DartPropertyInfo prop =
        properties.firstWhere((v) => v.name == name, orElse: () => null);
    if (prop == null) {
      //print("addProperty: ${name}");
      prop =
          new DartPropertyInfo(name, isFinal: false, isWritable: node.isSetter);
      properties.add(prop);
    }
    if (node.isSetter) {
      prop.isWritable = true;
    }
  }
}
