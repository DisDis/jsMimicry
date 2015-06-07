part of test;

@JsProxy()
class TestMimicry1 {
  
  var state1 = 0;
  var state2 = 0;

  method1(int p1) {
    print("TestMimicry1.method1 p1:$p1");
    this.state1 = p1;
    return "state: $p1,$state2";
  }

  method2(p2) {
    print("TestMimicry1.method2 p2:$p2");
    this.state2 = p2;
    return "state: $state1,$p2";
  }
  
  method3(p1,[int p2]) {
    print("TestMimicry1.method3 p1:$p1, p2:$p2");
   }
  
  method4(p1,{int p2, String p3}) {
    print("TestMimicry1.method4 p1:$p1, p2:$p2, p3:$p3");
  }
  

  methodWithoutParams() {
    print("TestMimicry1.methodWithoutParams");
  }
  _methodPrivate() {
    print("TestMimicry1._methodPrivate - ERROR");
    throw new Exception("Private method invisibled");
  }
  
  static futureToCallbacks(Future result,js.JsFunction resultCb,[js.JsFunction errorCb]){
    if (errorCb!=null){
      result = result.catchError(
          (err)=>errorCb.apply([err])
          );
    }
    result.then(
        (o)=>resultCb.apply([o])
        );
    return result;
  }
  
  @JsMutator(insertParams:const ["resultCb","errorCb"],result:TestMimicry1.futureToCallbacks)
  Future<int> methodLongWork1(int p1){
    Completer<int> c = new Completer();
    print("TestMimicry1.methodLongWork1 - start");
    new Timer(new Duration(seconds: 1),(){
      c.complete(p1);
      print("TestMimicry1.methodLongWork1 - end");
    });
    return c.future;
  }
  
  @JsMutator(insertParams:const ["resultCb","errorCb"],result:TestMimicry1.futureToCallbacks)
  Future<int> methodLongWork2(int p1){
      Completer<int> c = new Completer();
      print("TestMimicry1.methodLongWork2 - start");
      new Timer(new Duration(seconds: 1),(){
        c.completeError(p1);
        print("TestMimicry1.methodLongWork2 - end (error)");
      });
      return c.future;
    }
  
  String methodInputDartObject1(
                             //@JsTransform(JsProxyFactory.toDart[Test1])
                             Test1 t1, 
                             //@JsTransform(JsProxyFactory.toDart[Test2])
                             Test2 t2, int intP, String strP){
      return t1.method2(intP.toString(), strP).toString() + t2.method2(intP.toString(), strP).toString();    
  }
}
