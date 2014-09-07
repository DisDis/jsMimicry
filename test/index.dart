import 'test1.dart';
import 'index.dart.proxy.dart';
import 'dart:js' as js;

main(){
  print("Run");
  js.context["dart"] = new js.JsObject.jsify({});
  Test2Proxy.jsRegistrationPrototype();
  TestMimicry1Proxy.jsRegistrationPrototype();
  js.context["test1"] = new js.JsFunction.withThis((that){
    return Test2Proxy.toJS(new Test2()); 
  });
  Test5Proxy.jsRegistrationPrototype();
}