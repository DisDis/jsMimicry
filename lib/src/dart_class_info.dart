part of jsMimicry.generator;

class JsClass {
  String jsPath;
  String className;
  String dartClassName;
}

class DartClassInfo {
  List<DartMethodInfo> methods = [];
  final Annotation annotation;
  List<DartMethodInfo> constructors = [];
  //bool _toJSMethod = false;
  //bool _regProtoMethod = false;

  JsClass clazz = new JsClass();
  JsClass superClazz;

  static const String ANNOTATION_CLASS = "jsProxy";
  static const String ANNOTATION_METHOD = "jsMutator";
  static const String ANNOTATION_PARAMETER = "jsTransform";

  static const String NAME_REG_PROTOTYPE_METHOD = "jsRegistrationPrototype";
  static const String NAME_TO_JS_METHOD = "toJS";
  static const String NAME_TO_DART_METHOD = "toDart";
  static const String NAME_PROTOTYPE_FLAG = "__prototypeReg";
  static const String DART_OBJ_KEY = "_dartObj";

  DartClassInfo(Annotation this.annotation, ClassDeclaration node) {
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
      superClazz = new JsClass();
      superClazz.dartClassName = node.extendsClause.superclass.toString();
    }
    //getConstructor
    clazz.dartClassName = node.name.toString();

    parsingConstructors(node);

    node.accept(new DartClassVisitor(this));
  }

  void parsingConstructors(ClassDeclaration node) {
    node.members.where((item) => item is ConstructorDeclaration).forEach((ConstructorDeclaration classMember) {
      var tmp = new DartMethodInfo.fromConstructor(classMember);
      constructors.add(tmp);
    });
  }
  DartMethodInfo addMethod(MethodDeclaration node) {
    var tmp = new DartMethodInfo(node);
    methods.add(tmp);
    if (clazz.dartClassName != clazz.jsPath) {
      print("dart:${clazz.dartClassName} js:${clazz.jsPath}.${node.name}");
    } else {
      print("js:${clazz.jsPath}.${node.name}");
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
      parentCall.writeln('''${contextParent}[r"${parentClass}_int"].callMethod('call',[that,obj]);''');
      parentCallInt.writeln('''${contextParent}[r"${parentClass}_int"].callMethod('call',[that,obj]);''');
    }

    sb.writeln("");
    sb.writeln("""static void $NAME_REG_PROTOTYPE_METHOD(){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
""");
    sb.writeln("""if ($NAME_PROTOTYPE_FLAG) {
      return;
    }""");
    if (superClazz != null && superClazz.jsPath != null) {
      sb.writeln("""${_getDartProxyClass(superClazz.dartClassName)}.$NAME_REG_PROTOTYPE_METHOD();""");
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
      v.getMethodCode(sb, clazz.dartClassName);
    });
    sb.writeln("""// Constructor for method toJS""");
    sb.writeln("""context[r"${nameFunction}_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:${clazz.jsPath}_int");
      that[r"${DART_OBJ_KEY}"] = obj;$parentCallInt
    });""");
sb.writeln("""// Constructors connect to prototype""");
constructors.forEach((ctr){
 if (ctr.name!=null){
   sb.writeln("""context[r"${nameFunction}_${ctr.name}"]["prototype"] = proto;""");
 }
});
sb.writeln("""context[r"${nameFunction}_int"]["prototype"] = proto;
    }""");
  }

  void _generatePrototypeConstructors(StringBuffer sb, StringBuffer parentCall) {
    var constructorPath = clazz.jsPath.split('.');
    var nameFunction = constructorPath.last;
    if (constructors.length == 0){
    /*sb.writeln("""context[r"${nameFunction}"] = new js.JsFunction.withThis((that) {
      print(r"ctr:${clazz.jsPath}");
      var obj = new ${clazz.dartClassName}();
      that[r"${DART_OBJ_KEY}"] = obj;$parentCall
    });""");*/
      new DartMethodInfo.empty(null).getConstructorCode(sb, clazz, nameFunction, parentCall.toString());
    }else{
      constructors.forEach((ctr){
        ctr.getConstructorCode(sb, clazz, nameFunction,parentCall.toString());
      });
    }
  }


  generateToJS(StringBuffer sb) {
    var constructorPath = clazz.jsPath.split('.');
    String contextB = _getContext(constructorPath);
    var nameFunction = constructorPath.last;
    sb.writeln("");
    sb.writeln("""static js.JsObject $NAME_TO_JS_METHOD(${clazz.dartClassName} obj){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/""");
    sb.writeln("""
    $NAME_REG_PROTOTYPE_METHOD();
    return new js.JsObject(${contextB}["${nameFunction}_int"], [obj]);}""");
  }

  void generateToDart(StringBuffer sb) {
    sb.writeln("");
    sb.writeln("""static ${clazz.dartClassName} $NAME_TO_DART_METHOD(obj){
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/""");
    sb.writeln("""if (obj==null){
 return null;
}else if (obj is ${clazz.dartClassName}){
 return obj;
}else if (obj is js.JsObject){
 return obj[r"${DART_OBJ_KEY}"] as ${clazz.dartClassName};
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

  FunctionBody toJSBody(BlockFunctionBody oldBody) {
    StringBuffer sb = new StringBuffer();
    generateToJS(sb);
    var astF = parseCompilationUnit(sb.toString());
    FunctionDeclaration fd = astF.declarations[0];

    var astClone = new AstCloner();
    return astClone.cloneNode(fd.functionExpression.body);
  }

  String _getDartProxyClass(String name) => "${name}Proxy";
  generateProxyClass(StringBuffer sb) {
    sb.writeln("""abstract class ${_getDartProxyClass(clazz.dartClassName)} {""");
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
}
