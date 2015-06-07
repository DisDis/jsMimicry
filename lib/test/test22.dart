part of test2;

@JsProxy("dart.T22")
class Test22 extends Test11{
  method2(p1,p2){
    print("Test2.method2 $p1, $p2");
    return p1+p2;
  }

  String get t2Getter1=>"123";

  methodt2Getter1(){
    return t2Getter1;
  }

  methodtt2Field(){
    return t2Field;
  }

  String _t2GetterSetter2 = "init_T2GetterSetter2";
  String get t2GetterSetter2=>_t2GetterSetter2;
  set t2GetterSetter2(String v)=>_t2GetterSetter2=v;

  String t2Field = "init_T2Field";

  Test11 fieldTest1 = new Test11();

  Test22 _propTest2;
  Test22 get propTest2=>_propTest2;
  set propTest2(Test22 v)=>_propTest2=v;
}

@JsProxy("dart.TestGeneric1")
class TestGeneric1<E>{
  E fieldGen1;
}

@JsProxy()
class Test113 extends Object{
}




