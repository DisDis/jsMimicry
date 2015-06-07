part of test;

@JsProxy()
class Test5 extends Object{
  final int finalField;
  int field2;
  methodTest5(p1){
    print("Test5.methodTest5 $p1");
  }
  Test5(this.finalField){
    print("Test5.ctr $finalField");
  }
  Test5.namedCtr1(this.finalField){
      field2 = finalField * 10;
      print("Test5.namedCtr1 $finalField");
  }
  Test5.namedCtr2(this.finalField){
      field2 = finalField * 20;
      print("Test5.namedCtr2 $finalField");
  }
  //@jsTransform(Test1Proxy.toDart)
  Test5.namedCtr3( Test1 t1):this.finalField=3{
        field2 = finalField * 20;
        print("Test5.namedCtr2 $finalField $t1");
    }
}

@JsProxy()
class Test6 extends Test5{
  Test6(int finalField) : super(finalField);
  
}