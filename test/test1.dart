library test;
import 'dart:js' as js;
import 'package:js_mimicry/annotation.dart';
import 'dart:async';
import 'index.dart.proxy.dart';

part 'test2.dart';
part 'test5.dart';
part 'test4.dart';
part 'test3.dart';
part 'test_mimicry1.dart';

@jsProxy("dart.T1")
class Test1{
  method1(p1,p2){
    print("Test1.method1 $p1, $p2");
    return p1+p2;
  }
  method2(p1,p2){
    print("Test1.method2 $p1, $p2");
    return p1+p2;
  }
}


