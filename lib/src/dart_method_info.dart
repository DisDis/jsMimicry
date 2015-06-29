part of jsMimicry.generator;


class DartMethodParameterTransformer {
  final DartMethodMetadata method;
  DartMethodParameterTransformer(this.method);

  String generateTransformParamCode(DartMethodParameter param) {
    String paramAccess;
    if (param.kind == ParameterKind.NAMED) {
      paramAccess =
          """${DartMethodInfo.NAMED_PARAMETERS_NAME}[r"${param.name}"]""";
    } else {
      paramAccess = """${param.name}""";
    }
    return """${paramAccess} = ${method.toString()}(${paramAccess});""";
  }
}

class DartMethodParameter {
  final String name;
  final ParameterKind kind;
  final DartMethodParameterTransformer transformer;
  final bool isMutated;
  DartMethodParameter(this.name, this.kind,
      [this.transformer, this.isMutated = false]);


  static DartMethodParameter convert(FormalParameter element, GeneratorJsMimicry generator) {
    DartMethodParameterTransformer transformer;
    NodeList<Annotation> metadata;
    if (element is DefaultFormalParameter){
      metadata = (element as DefaultFormalParameter).parameter.metadata;
    }else if (element is NormalFormalParameter){
      metadata = element.metadata;
    }

    if (metadata != null) {
      Annotation annotation = metadata.firstWhere(
          (ann) => ann.name.toString() == DartClassInfo.ANNOTATION_PARAMETER,
          orElse: () => null);
      if (annotation != null) {
        var args = annotation.arguments;
        if (args != null && args.arguments.length != 0) {
          SimpleIdentifier v = args.arguments[0];
          var methodMetadata = generator.getMethodMetadata(v);
          if (methodMetadata != null) {
            transformer = new DartMethodParameterTransformer(methodMetadata);
          }
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
  DartMethodInfo.fromConstructor(ConstructorDeclaration node,GeneratorJsMimicry generator)
      : this.name = node.name != null ? node.name.toString() : null,
        this.parameters = _convertParameters(node.parameters.parameters,generator) {}

  DartMethodInfo(MethodDeclaration node,GeneratorJsMimicry generator)
      : this.name = node.name.toString(),
        this.parameters = _convertParameters(node.parameters.parameters,generator) {}

  static List<DartMethodParameter> _convertParameters(
      NodeList<FormalParameter> nodeList,GeneratorJsMimicry generator) {
    return nodeList.map((item)=>DartMethodParameter.convert(item,generator)).toList(growable: false);
  }
  void getConstructorCode(
      DartClassInfo dci, StringBuffer sb, String parentCall) {
    var constructorPath = dci.clazz.jsPath.split('.');
    String nameFunction = constructorPath.last;
    StringBuffer sbParamsWithType = new StringBuffer();
    StringBuffer sbParams = new StringBuffer();
    if (parameters.length > 0) {
      _generateParams(sbParamsWithType, sbParams);
    }
    String postFixName = name == null ? '' : '_$name';
    sb.writeln("//    constructor '${nameFunction}.${name == null ? '' : name}'");
    sb.writeln(
        """context[r"${nameFunction}${postFixName}"] = new js.JsFunction.withThis((that$sbParamsWithType) {""");
    _generateParamTransforms(sb);
    sb.writeln("""//print(r"ctr:${dci.clazz.jsPath}${postFixName}");""");
    if (dci.isAbstract) {
      sb.writeln("""   throw new UnsupportedError("Abstract class '${dci.clazz.dartClassName}'");""");
    }else{
      sb.writeln("""    var _obj_ = new ${dci.clazz.importDartClassName}${name == null ? '' : '.$name'}($sbParams);""");
      sb.writeln("""    _obj_.JS_INSTANCE_PROXY = that;""");
      sb.writeln("""    that[r"${DartClassInfo.DART_OBJ_KEY}"] = _obj_;$parentCall""");
    }
    sb.writeln("""  });""");
  }
  void getMethodCode(StringBuffer sb, JsClass clazz) {
    StringBuffer sbParamsWithType = new StringBuffer();
    StringBuffer sbParams = new StringBuffer();
    if (parameters.length > 0) {
      _generateParams(sbParamsWithType, sbParams);
    }
    sb.writeln("//   method '${name}'");
    sb.writeln(
        """proto[r'${name}'] = new js.JsFunction.withThis((that$sbParamsWithType) {""");
    _generateParamTransforms(sb);
    var methodCall =
        """((that["${DartClassInfo.DART_OBJ_KEY}"] as ${clazz.importDartClassName}).${name}($sbParams))""";
    if (mutator != null) {
      methodCall = mutator.changeResult(methodCall);
    }
    sb.write("""return _toJs($methodCall);""");//end return
    sb.writeln("});");
  }

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
