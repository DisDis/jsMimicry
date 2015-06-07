library test2;
import 'dart:js' as js;
import 'package:js_mimicry/annotation.dart';
import 'dart:async';

part 'test22.dart';

@JsProxy("dart.T11")
class Test11{
  String name;
  String getName(){
    return name;
  }

  method1(p1,p2){
    print("Test1.method1 $p1, $p2");
    return p1+p2;
  }
  method2(p1,p2){
    print("Test1.method2 $p1, $p2");
    return p1+p2;
  }
}


