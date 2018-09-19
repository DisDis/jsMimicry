@TestOn("browser")
library jsMimicry.testweb;
import 'dart:js';
import 'package:js_mimicry/annotation.dart';
import "package:test/test.dart";
import 'main_test.dart';
import 'package:js_mimicry/annotation.dart';
import 'index.js.g.dart';
import 'samples/test_lib1.dart';

main(){
  jsProxyBootstrap();
  print("Run");
  context["dart"] = new JsObject.jsify({});
  initTest();
  JsProxyFactory.init();
}