library jsMimicry.annotation;

/**
 * Indicator from proxy
 */
class JsProxy {
  const JsProxy([String path]);
}

/**
 * Method mutator
 */
class JsMutator {
  const JsMutator({List<String> insertParams,Function result});
}

/**
 * Transform parameter
 */
class JsTransform{
  const JsTransform(Function transformer);
}

abstract class JsProxyContainer{
  dynamic JS_INSTANCE_PROXY;
  bool get hasJsInstance;
  detachJsInstance();
}

abstract class JsProxyFactory{
  static void registration(Type dartType,Function regPrototype,Function toJs, Function toDart){
    _registrationPrototype.add(regPrototype);
    _toJs[dartType] = toJs;
    _toDart[dartType] = toDart;
  }
  static dynamic toJs(Object obj){
    if (obj == null) { return null; }
    JsProxyContainer objProxy = (obj as JsProxyContainer);
    if (objProxy!=null){
      if (objProxy.hasJsInstance){
        return objProxy.JS_INSTANCE_PROXY;
      }
      return objProxy.JS_INSTANCE_PROXY = _toJs[objProxy.runtimeType](objProxy);
    }
    throw new UnsupportedError("${obj.runtimeType} not supported");
  }
  static dynamic toDart(Type dartType, Object obj){
    if (obj == null) { return null; }
    return _toDart[dartType](obj);
  }

  static final List<Function> _registrationPrototype = [];
  static final Map<Type,Function> _toJs = {};
  static final Map<Type,Function> _toDart = {};
  static init(){
    _registrationPrototype.forEach((item)=>item());
    _registrationPrototype.clear();
  }
}