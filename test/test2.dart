part of test;

@jsProxy("dart.T2")
class Test2 extends Test1{
  method2(p1,p2){
    print("Test2.method2 $p1, $p2");
    return p1+p2;
  }
}




