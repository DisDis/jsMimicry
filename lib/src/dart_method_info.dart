part of jsMimicry.generator;


class DartMethodParameterTransformer {
  final DartMethodMetadata method;
  DartMethodParameterTransformer(this.method);

  String generateTransformParamCode(DartMethodParameter param) {
    String paramAccess;
    if (param.kind == ParameterKind.NAMED) {
      paramAccess =
          """${DartMethodInfo.NAMED_PARAMETERS_NAME}[r'${param.name}']""";
    } else {
      paramAccess = """${param.name}""";
    }
    return """${paramAccess} = ${method.toString()}(${paramAccess});""";
  }
}

class DartMethodParameter {
  final String name;
  final DartType type;
  final ParameterKind kind;
  final DartMethodParameterTransformer transformer;
  final bool isMutated;
  DartMethodParameter(this.name, this.type, this.kind,
      [this.transformer, this.isMutated = false]);


  static DartMethodParameter convert(FormalParameter element, GeneratorJsMimicry generator) {
    DartMethodParameterTransformer transformer;
    NodeList<Annotation> metadata;
    if (element is DefaultFormalParameter){
      metadata = element.parameter.metadata;
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
          Identifier v = args.arguments[0];
          var methodMetadata = generator.getMethodMetadata(v);
          if (methodMetadata != null) {
            transformer = new DartMethodParameterTransformer(methodMetadata);
          }
        }
      }
    }
    return new DartMethodParameter(
        element.identifier.toString(), element.declaredElement.type, element.kind, transformer);
  }
}

class DartMethodInfo {
  final String name;
  final DartType returnType;
  final List<DartMethodParameter> parameters;
  final TypeProviderHelper typeProviderHelper;
  final GeneratorJsMimicry generator;
  static const String NAMED_PARAMETERS_NAME = "_input_map_params";
  DartMethodMutator mutator;
  DartMethodInfo.empty(String this.name, this.generator) :
        this.parameters = const [],
        this.returnType = null,
        typeProviderHelper = generator.typeProviderHelper;

  DartMethodInfo.fromConstructor(ConstructorDeclaration node,this.generator)
      : this.name = node.name != null ? node.name.toString() : null,
        this.parameters = _convertParameters(node.parameters.parameters,generator),
        this.returnType = node.declaredElement.returnType,
        this.typeProviderHelper = generator.typeProviderHelper {}

  DartMethodInfo(MethodDeclaration node,this.generator)
      : this.name = node.name.toString(),
        this.returnType = node.declaredElement.returnType,
        this.parameters = _convertParameters(node.parameters.parameters,generator),
        this.typeProviderHelper = generator.typeProviderHelper  {}

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
        """context[r'${nameFunction}${postFixName}'] = new js.JsFunction.withThis((dynamic that$sbParamsWithType) {""");
    _generateParamTransforms(sb);
    var constructorName = name == null ? '' : '.$name';
    if (name!=null && name.indexOf("_") == 0 ) {
      sb.writeln("""   throw new UnsupportedError("Private constructor '${dci.clazz.dartClassName}${constructorName}'");""");
    } else
    if (dci.isAbstract) {
      sb.writeln("""   throw new UnsupportedError("Abstract class '${dci.clazz.dartClassName}'");""");
    }else{
      sb.writeln("""    final dynamic _obj_ = new ${dci.clazz.importDartClassName}${constructorName}($sbParams);""");
      sb.writeln("""    // ignore: undefined_setter""");
      sb.writeln("""    _obj_.JS_INSTANCE_PROXY = that;""");
      sb.writeln("""    that[r'${DartClassInfo.DART_OBJ_KEY}'] = _obj_;$parentCall""");
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
        """proto[r'${name}'] = new js.JsFunction.withThis((dynamic that$sbParamsWithType) {""");
    if (parameters.any((p) => p.kind == ParameterKind.NAMED)) {
      sb.writeln('''$NAMED_PARAMETERS_NAME = new Map<dynamic, dynamic>.from($NAMED_PARAMETERS_NAME);''');
    }
    _generateParamTransforms(sb);
    var methodCall =
        """((that['${DartClassInfo.DART_OBJ_KEY}'] as ${clazz.importDartClassName}).${name}($sbParams))""";
    if (mutator != null) {
      methodCall = mutator.changeResult(methodCall);
    }

    final toJsCast = mutator != null || returnType.isDynamic ? 'dynamic' : (returnType.isVoid ? 'void' : null);
    sb.write("""return _toJs${toJsCast != null ? '<$toJsCast>' : ''}($methodCall);"""); //end return
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
          sbInputParams.write('Map<dynamic, dynamic> $namedParam');
          sbInputParams.write(" = const <dynamic, dynamic>{}");
        } else {
          sbInputParams.write(',');
          if (!isOptional && param.kind.isOptional) {
            isOptional = true;
            sbInputParams.write("[");
          }
          sbInputParams.write('dynamic ${param.name}');
        }
      }
      if (param.isMutated) {
        return;
      }
      if (!first) {
        sbParams.write(',');
      }

      bool isIterable = typeProviderHelper.isIterableType(param.type);
      bool isMap = typeProviderHelper.isMapType(param.type);
      bool needCast = (isIterable || isMap) && (param.type is ParameterizedType)
        && ((param.type as ParameterizedType).typeArguments.any((t) => !t.isDynamic));

      if (namedParam == null) {
        sbParams.write(" ${needCast ? '(' : ''} _toDart(${param.name}) ");
      } else {
        sbParams.write("${param.name} : ${needCast ? '(' : ''} _toDart(${namedParam}['${param.name}']) ");
      }

      if (needCast) {
        sbParams.write(' )?.cast<${(param.type as ParameterizedType).typeArguments.map((t) => t.name).join(',')}>()');
      }

      first = false;
    });
    if (isOptional) {
      sbInputParams.write(']');
    }
  }
}

