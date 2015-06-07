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
  detachJsInstance();
}

abstract class JsProxyFactory{
  static final List<Function> registrationPrototype = [];
  static final Map<Type,Function> toJS = {};
  static final Map<Type,Function> toDart = {};
  static init(){
    registrationPrototype.forEach((item)=>item());
  }
}