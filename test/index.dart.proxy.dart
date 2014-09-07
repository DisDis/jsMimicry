library jsProxy;
/* AUTO-GENERATED FILE.  DO NOT MODIFY.*/

import 'dart:js' as js;

import 'test1.dart';

//--------------------------
//   Test1 -> dart.T1
//--------------------------
abstract class Test1Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    __prototypeReg = true;
    var context = js.context[r"dart"];
// Constructors
    context[r"T1"] = new js.JsFunction.withThis((that) {
      print(r"ctr:dart.T1");
      var obj = new Test1();
      that[r"_dartObj"] = obj;
    });
// Methods
    var proto = context[r"T1"]["prototype"];
    proto[r'method1'] = new js.JsFunction.withThis((that, p1, p2) {
      return ((that["_dartObj"] as Test1).method1(p1, p2));
    });
    proto[r'method2'] = new js.JsFunction.withThis((that, p1, p2) {
      return ((that["_dartObj"] as Test1).method2(p1, p2));
    });
// Constructor for method toJS
    context[r"T1_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:dart.T1_int");
      that[r"_dartObj"] = obj;
    });
// Constructors connect to prototype
    context[r"T1_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test1 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context[r"dart"]["T1_int"], [obj]);
  }

  static Test1 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test1) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test1;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   Test2 -> dart.T2
//--------------------------
abstract class Test2Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    Test1Proxy.jsRegistrationPrototype();
    __prototypeReg = true;
    var context = js.context[r"dart"];
// Constructors
    context[r"T2"] = new js.JsFunction.withThis((that) {
      print(r"ctr:dart.T2");
      var obj = new Test2();
      that[r"_dartObj"] = obj;
      js.context[r"dart"][r"T1_int"].callMethod('call', [that, obj]);

    });
    var F = new js.JsFunction.withThis((that) {});
    F["prototype"] = js.context[r"dart"][r"T1"]["prototype"];
    context[r"T2"]["prototype"] = new js.JsObject(F);
    context[r"T2"]["prototype"]["constructor"] = context[r"T2"];

// Methods
    var proto = context[r"T2"]["prototype"];
    proto[r'method2'] = new js.JsFunction.withThis((that, p1, p2) {
      return ((that["_dartObj"] as Test2).method2(p1, p2));
    });
// Constructor for method toJS
    context[r"T2_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:dart.T2_int");
      that[r"_dartObj"] = obj;
      js.context[r"dart"][r"T1_int"].callMethod('call', [that, obj]);

    });
// Constructors connect to prototype
    context[r"T2_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test2 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context[r"dart"]["T2_int"], [obj]);
  }

  static Test2 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test2) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test2;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   Test5 -> Test5
//--------------------------
abstract class Test5Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    __prototypeReg = true;
    var context = js.context;
// Constructors
    context[r"Test5"] = new js.JsFunction.withThis((that, finalField) {
      print(r"ctr:Test5");
      var obj = new Test5(finalField);
      that[r"_dartObj"] = obj;
    });
    context[r"Test5_namedCtr1"] =
        new js.JsFunction.withThis((that, finalField) {
      print(r"ctr:Test5_namedCtr1");
      var obj = new Test5.namedCtr1(finalField);
      that[r"_dartObj"] = obj;
    });
    context[r"Test5_namedCtr2"] =
        new js.JsFunction.withThis((that, finalField) {
      print(r"ctr:Test5_namedCtr2");
      var obj = new Test5.namedCtr2(finalField);
      that[r"_dartObj"] = obj;
    });
    context[r"Test5_namedCtr3"] = new js.JsFunction.withThis((that, t1) {
      t1 = Test1Proxy.toDart(t1);
      print(r"ctr:Test5_namedCtr3");
      var obj = new Test5.namedCtr3(t1);
      that[r"_dartObj"] = obj;
    });
// Methods
    var proto = context[r"Test5"]["prototype"];
    proto[r'methodTest5'] = new js.JsFunction.withThis((that, p1) {
      return ((that["_dartObj"] as Test5).methodTest5(p1));
    });
// Constructor for method toJS
    context[r"Test5_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:Test5_int");
      that[r"_dartObj"] = obj;
    });
// Constructors connect to prototype
    context[r"Test5_namedCtr1"]["prototype"] = proto;
    context[r"Test5_namedCtr2"]["prototype"] = proto;
    context[r"Test5_namedCtr3"]["prototype"] = proto;
    context[r"Test5_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test5 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context["Test5_int"], [obj]);
  }

  static Test5 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test5) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test5;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   Test6 -> Test6
//--------------------------
abstract class Test6Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    Test5Proxy.jsRegistrationPrototype();
    __prototypeReg = true;
    var context = js.context;
// Constructors
    context[r"Test6"] = new js.JsFunction.withThis((that, finalField) {
      print(r"ctr:Test6");
      var obj = new Test6(finalField);
      that[r"_dartObj"] = obj;
      js.context[r"Test5_int"].callMethod('call', [that, obj]);

    });
    var F = new js.JsFunction.withThis((that) {});
    F["prototype"] = js.context[r"Test5"]["prototype"];
    context[r"Test6"]["prototype"] = new js.JsObject(F);
    context[r"Test6"]["prototype"]["constructor"] = context[r"Test6"];

// Methods
    var proto = context[r"Test6"]["prototype"];
// Constructor for method toJS
    context[r"Test6_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:Test6_int");
      that[r"_dartObj"] = obj;
      js.context[r"Test5_int"].callMethod('call', [that, obj]);

    });
// Constructors connect to prototype
    context[r"Test6_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test6 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context["Test6_int"], [obj]);
  }

  static Test6 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test6) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test6;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   Test4 -> Test4
//--------------------------
abstract class Test4Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    Test3Proxy.jsRegistrationPrototype();
    __prototypeReg = true;
    var context = js.context;
// Constructors
    context[r"Test4"] = new js.JsFunction.withThis((that) {
      print(r"ctr:Test4");
      var obj = new Test4();
      that[r"_dartObj"] = obj;
      js.context[r"Test3_int"].callMethod('call', [that, obj]);

    });
    var F = new js.JsFunction.withThis((that) {});
    F["prototype"] = js.context[r"Test3"]["prototype"];
    context[r"Test4"]["prototype"] = new js.JsObject(F);
    context[r"Test4"]["prototype"]["constructor"] = context[r"Test4"];

// Methods
    var proto = context[r"Test4"]["prototype"];
    proto[r'methodTest4'] = new js.JsFunction.withThis((that, p1) {
      return ((that["_dartObj"] as Test4).methodTest4(p1));
    });
// Constructor for method toJS
    context[r"Test4_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:Test4_int");
      that[r"_dartObj"] = obj;
      js.context[r"Test3_int"].callMethod('call', [that, obj]);

    });
// Constructors connect to prototype
    context[r"Test4_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test4 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context["Test4_int"], [obj]);
  }

  static Test4 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test4) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test4;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   TestMimicry1 -> TestMimicry1
//--------------------------
abstract class TestMimicry1Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    __prototypeReg = true;
    var context = js.context;
// Constructors
    context[r"TestMimicry1"] = new js.JsFunction.withThis((that) {
      print(r"ctr:TestMimicry1");
      var obj = new TestMimicry1();
      that[r"_dartObj"] = obj;
    });
// Methods
    var proto = context[r"TestMimicry1"]["prototype"];
    proto[r'method1'] = new js.JsFunction.withThis((that, p1) {
      return ((that["_dartObj"] as TestMimicry1).method1(p1));
    });
    proto[r'method2'] = new js.JsFunction.withThis((that, p2) {
      return ((that["_dartObj"] as TestMimicry1).method2(p2));
    });
    proto[r'method3'] = new js.JsFunction.withThis((that, p1, [p2]) {
      return ((that["_dartObj"] as TestMimicry1).method3(p1, p2));
    });
    proto[r'method4'] =
        new js.JsFunction.withThis((that, p1, [_input_map_params = const {}]) {
      return ((that["_dartObj"] as TestMimicry1).method4(
          p1,
          p2: _input_map_params['p2'],
          p3: _input_map_params['p3']));
    });
    proto[r'methodWithoutParams'] = new js.JsFunction.withThis((that) {
      return ((that["_dartObj"] as TestMimicry1).methodWithoutParams());
    });
    proto[r'methodLongWork1'] =
        new js.JsFunction.withThis((that, resultCb, errorCb, p1) {
      return TestMimicry1.futureToCallbacks(
          ((that["_dartObj"] as TestMimicry1).methodLongWork1(p1)),
          resultCb,
          errorCb);
    });
    proto[r'methodLongWork2'] =
        new js.JsFunction.withThis((that, resultCb, errorCb, p1) {
      return TestMimicry1.futureToCallbacks(
          ((that["_dartObj"] as TestMimicry1).methodLongWork2(p1)),
          resultCb,
          errorCb);
    });
    proto[r'methodInputDartObject1'] =
        new js.JsFunction.withThis((that, t1, t2, intP, strP) {
      t1 = Test1Proxy.toDart(t1);
      t2 = Test2Proxy.toDart(t2);
      return ((that["_dartObj"] as TestMimicry1).methodInputDartObject1(
          t1,
          t2,
          intP,
          strP));
    });
// Constructor for method toJS
    context[r"TestMimicry1_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:TestMimicry1_int");
      that[r"_dartObj"] = obj;
    });
// Constructors connect to prototype
    context[r"TestMimicry1_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(TestMimicry1 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context["TestMimicry1_int"], [obj]);
  }

  static TestMimicry1 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is TestMimicry1) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as TestMimicry1;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}

//--------------------------
//   Test3 -> Test3
//--------------------------
abstract class Test3Proxy {
  static bool __prototypeReg = false;

  static void jsRegistrationPrototype() {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/

    if (__prototypeReg) {
      return;
    }
    __prototypeReg = true;
    var context = js.context;
// Constructors
    context[r"Test3"] = new js.JsFunction.withThis((that) {
      print(r"ctr:Test3");
      var obj = new Test3();
      that[r"_dartObj"] = obj;
    });
// Methods
    var proto = context[r"Test3"]["prototype"];
    proto[r'methodTest3'] = new js.JsFunction.withThis((that, p1) {
      return ((that["_dartObj"] as Test3).methodTest3(p1));
    });
// Constructor for method toJS
    context[r"Test3_int"] = new js.JsFunction.withThis((that, obj) {
      print(r"ctr:Test3_int");
      that[r"_dartObj"] = obj;
    });
// Constructors connect to prototype
    context[r"Test3_int"]["prototype"] = proto;
  }

  static js.JsObject toJS(Test3 obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    jsRegistrationPrototype();
    return new js.JsObject(js.context["Test3_int"], [obj]);
  }

  static Test3 toDart(obj) {
    /* AUTO-GENERATED METHOD.  DO NOT MODIFY.*/
    if (obj == null) {
      return null;
    } else if (obj is Test3) {
      return obj;
    } else if (obj is js.JsObject) {
      return obj[r"_dartObj"] as Test3;
    } else {
      throw new Exception('Unknown $obj');
    }
  }
}
