import 'package:js_mimicry/test/test1.dart';
import 'package:js_mimicry/test/test11.dart';
import 'dart:js' as js;
import 'package:js_mimicry/annotation.dart';

main(){
  print("Run");
  js.context["dart"] = new js.JsObject.jsify({});
  js.context["test1"] = new js.JsFunction.withThis((that){
    return  JsProxyFactory.toJs(new Test2());
  });
}