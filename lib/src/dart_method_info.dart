part of jsMimicry.generator;

class DartMethodParameterTransformer {
  final String methodName;
  DartMethodParameterTransformer(this.methodName);

  String generateTransformParamCode(DartMethodParameter param) {
    String paramAccess;
    if (param.kind == ParameterKind.NAMED) {
      paramAccess =
          """${DartMethodInfo.NAMED_PARAMETERS_NAME}[r"${param.name}"]""";
    } else {
      paramAccess = """${param.name}""";
    }
    return """${paramAccess} = ${methodName}(${paramAccess});""";
  }
}

class DartMethodParameter {
  final String name;
  final ParameterKind kind;
  final DartMethodParameterTransformer transformer;
  final bool isMutated;
  DartMethodParameter(this.name, this.kind,
      [this.transformer, this.isMutated = false]);

  static DartMethodParameter convert(FormalParameter element) {
    DartMethodParameterTransformer transformer;
    if (element is SimpleFormalParameter) {
      Annotation annotation = element.metadata.firstWhere(
          (ann) => ann.name.toString() == DartClassInfo.ANNOTATION_PARAMETER,
          orElse: () => null);
      if (annotation != null) {
        var args = annotation.arguments;
        if (args != null && args.arguments.length != 0) {
          transformer = new DartMethodParameterTransformer(
              (args.arguments[0] as PrefixedIdentifier).name.toString());
        }
      }
    }
    return new DartMethodParameter(
        element.identifier.toString(), element.kind, transformer);
  }
}

class DartMethodInfo {
  final String name;
  final List<DartMethodParameter> parameters;
  static const String NAMED_PARAMETERS_NAME = "_input_map_params";
  DartMethodMutator mutator;
  DartMethodInfo.empty(String this.name) : this.parameters = const [];
  DartMethodInfo.fromConstructor(ConstructorDeclaration node)
      : this.name = node.name != null ? node.name.toString() : null,
        this.parameters = _convertParameters(node.parameters.parameters) {}

  DartMethodInfo(MethodDeclaration node)
      : this.name = node.name.toString(),
        this.parameters = _convertParameters(node.parameters.parameters) {}

  static List<DartMethodParameter> _convertParameters(
      NodeList<FormalParameter> nodeList) {
    return nodeList.map(DartMethodParameter.convert).toList(growable: false);
  }
  void getConstructorCode(
      StringBuffer sb, JsClass clazz, String nameFunction, String parentCall) {
    StringBuffer sbParamsWithType = new StringBuffer();
    StringBuffer sbParams = new StringBuffer();
    if (parameters.length > 0) {
      _generateParams(sbParamsWithType, sbParams);
    }
    String dartClassName = clazz.dartClassName;
    String postFixName = name == null ? '' : '_$name';
    sb.writeln(
        """context[r"${nameFunction}${postFixName}"] = new js.JsFunction.withThis((that$sbParamsWithType) {""");
    _generateParamTransforms(sb);
    sb.writeln("""print(r"ctr:${clazz.jsPath}${postFixName}");
      var obj = new ${clazz.importDartClassName}${name==null?'':'.$name'}($sbParams);
      obj.JS_INSTANCE_PROXY = that;
      that[r"${DartClassInfo.DART_OBJ_KEY}"] = obj;$parentCall
    });""");
  }
  void getMethodCode(StringBuffer sb, JsClass clazz) {
    StringBuffer sbParamsWithType = new StringBuffer();
    StringBuffer sbParams = new StringBuffer();
    if (parameters.length > 0) {
      _generateParams(sbParamsWithType, sbParams);
    }
    sb.writeln(
        """proto[r'${name}'] = new js.JsFunction.withThis((that$sbParamsWithType) {""");
    _generateParamTransforms(sb);
    sb.write("""return _toJs(""");
    var methodCall =
        """((that["${DartClassInfo.DART_OBJ_KEY}"] as ${clazz.importDartClassName}).${name}($sbParams))""";
    if (mutator != null) {
      methodCall = mutator.changeResult(methodCall);
    }
    sb.write(methodCall);
    sb.write(');');//end return
    sb.writeln("});");
  }

//  void _convertParamsToDart(StringBuffer sb){
//    parameters.forEach((param) {
//      sb.writeln(
//    });
//  }

  void _generateParamTransforms(StringBuffer sb) {
    parameters.forEach((param) {
      if (param.transformer != null) {
        sb.writeln(param.transformer.generateTransformParamCode(param));
      }
    });
  }

  void _generateParams(StringBuffer sbInputParams, StringBuffer sbParams) {
    List<DartMethodParameter> parameters = this.parameters;
    if (mutator != null) {
      parameters = mutator.changeInputParameters(parameters);
    }
    bool first = true;
    bool isOptional = false;
    String namedParam = null;
    parameters.forEach((param) {
      if (namedParam == null) {
        if (param.kind == ParameterKind.NAMED) {
          namedParam = NAMED_PARAMETERS_NAME;
          isOptional = true;
          sbInputParams.write(',');
          sbInputParams.write("[");
          sbInputParams.write(namedParam);
          sbInputParams.write(" = const {}");
        } else {
          sbInputParams.write(',');
          if (!isOptional && param.kind.isOptional) {
            isOptional = true;
            sbInputParams.write("[");
          }
          sbInputParams.write(param.name);
        }
      }
      if (param.isMutated) {
        return;
      }
      if (!first) {
        sbParams.write(',');
      }
      if (namedParam == null) {
        sbParams.write(" _toDart(${param.name}) ");
      } else {
        sbParams.write("${param.name} : _toDart(${namedParam}['${param.name}']) ");
      }
      first = false;
    });
    if (isOptional) {
      sbInputParams.write(']');
    }
  }
}
