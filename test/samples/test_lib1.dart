library jsMimicry.test.lib1;

import 'package:js_mimicry/annotation.dart';

@JsProxy()
class SimpleClass1 extends Object with JsProxyMixin {}

@JsProxy('dart.SimpleClass2WithNS')
class SimpleClass2WithNS extends Object with JsProxyMixin {}

@JsProxy()
class SimpleClass3 extends Object with JsProxyMixin {
  String method1woArgs() => "method1woArgs_TEST_RESULT_SimpleClass3";
  String method2woArgs() {
    return "method2woArgs_TEST_RESULT_SimpleClass3";
  }
  int method3woArgs() => 42;
  bool method4woArgs() => true;
}

@JsProxy()
class SimpleClass4 extends Object with JsProxyMixin {
  SimpleClass4();
  SimpleClass4.public1();
  SimpleClass4._internal();
}

@JsProxy()
class SimpleClass5 extends Object with JsProxyMixin {
  String get propertyString1ReadOnly => "SimpleClass5_propertyString1ReadOnly";
  int get propertyInt1ReadOnly => 41;

  String _privateProperty2 = "SimpleClass5__privateProperty2";
  String get propertyString2 => _privateProperty2;
  set propertyString2(v) => _privateProperty2 = v;
  String getPropertyString2()=>_privateProperty2;

  String _privateProperty3 = "SimpleClass5__privateProperty3";
  String get propertyString3 => _privateProperty3;
  set propertyString3(v) => _privateProperty3 = v;
  String getPropertyString3()=>_privateProperty3;
}

@JsProxy()
class SimpleClass6 extends SimpleClass5 {
  String get propertyString1ReadOnly => "SimpleClass6_propertyString1ReadOnly";

  String _privateProperty3_ = "SimpleClass6__privateProperty3_";
  String get propertyString3 => _privateProperty3_;
  set propertyString3(v) => _privateProperty3_ = v;
  String getPropertyString3()=>_privateProperty3_;
}

class SimpleClass7SkipJsProxy extends SimpleClass3{

}
@JsProxy()
class SimpleClass8 extends SimpleClass7SkipJsProxy{

}

@JsProxy()
class SimpleClass11 extends Object with JsProxyMixin {
  @JsIgnore()
  ignoreMethod1()=>"ignoreMethod1";
  @JsIgnore()
  String ignoreField1 = "ignoreField1";
  @JsIgnore()
  String get ignoreProperty=>ignoreField1;
  @JsIgnore()
  set ignoreProperty(v)=>ignoreField1=v;
}

@JsProxy()
abstract class SimpleClass9Abstract extends SimpleClass3 {
  int method1AbstractClass()=>10;
}

@JsProxy()
class SimpleClass10 extends SimpleClass9Abstract {
  int method1SimpleClass10()=>11;
}


@JsProxy()
class GenericClass1<T extends String> extends SimpleClass5 {
   T field1 = 'GenericClass1_field1' as T;
}

@JsProxy()
class GenericClass2 extends GenericClass1<String> {
  String field2 = "GenericClass2_field1";
}

@JsProxy()
class JsTransformClass1 extends Object with JsProxyMixin {
  static String ANY_TO_STRING1(v)=>v!=null?"$v":null;
  static String ANY_TO_STRING2(v)=>v!=null?"$v":null;
  static String ANY_TO_STRING3(v)=>v!=null?"$v":null;
  bool method1AlwaysString(@JsTransform(ANY_TO_STRING1)v){
    return v is String;
  }
  bool method2WithOptParamAlwaysString([@JsTransform(ANY_TO_STRING2)v]){
    return v is String;
  }
  bool method3WithNameParamAlwaysString({@JsTransform(ANY_TO_STRING3)v}){
    return v is String;
  }
}