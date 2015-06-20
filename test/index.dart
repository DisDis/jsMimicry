@TestOn("browser")
library jsMimicry.testweb;
import 'package:js_mimicry/test/test1.dart';
import 'package:js_mimicry/test/test11.dart';
import 'package:js_mimicry/test/test_lib1.dart';
import 'dart:js' as js;
import 'package:js_mimicry/annotation.dart';
import "package:test/test.dart";
import 'main_test.dart';

main(){
  print("Run");
  js.context["dart"] = new js.JsObject.jsify({});
  js.context["test1"] = new js.JsFunction.withThis((that){
    return  JsProxyFactory.toJs(new Test2());
  });
  initTest();
}