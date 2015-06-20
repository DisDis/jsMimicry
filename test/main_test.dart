@TestOn("vm")
library jsMimicry.test;
import "dart:async";
import 'dart:js';

import "package:test/test.dart";
import "package:js_mimicry/annotation.dart";
import "package:js_mimicry/test/test_lib1.dart";
const String DART_OBJ_KEY = "_dartObj";

JsObject getObjectByPath(String path) {
  var part = path.split('.');
  var result = context;
  part.forEach((p) => result = result[p]);
  return result;
}

initTest() {
  group("Simple", () {
    test("SimpleClass1", () {
      var link = getObjectByPath("SimpleClass1");
      expect(link.runtimeType, equals(JsFunction));
      JsFunction ctor = link as JsFunction;
      var obj = new JsObject(ctor);
      expect(obj, isNotNull);
      expect(obj.instanceof(ctor), isTrue);
      expect(obj.instanceof(getObjectByPath("SimpleClass3")), isFalse);
      var dartObj = obj[DART_OBJ_KEY] as JsProxyContainer;
      expect(dartObj, isNotNull);
      expect(dartObj.JS_INSTANCE_PROXY, equals(obj));
      expect(dartObj.JS_INSTANCE_PROXY, dartObj.JS_INSTANCE_PROXY);
      var dartObj2 = new SimpleClass1() as JsProxyContainer;
      expect(dartObj2, isNotNull);
      expect(dartObj2.hasJsInstance, isFalse);
      var jsObj2 = dartObj2.JS_INSTANCE_PROXY;
      expect(jsObj2, isNotNull);
      expect(jsObj2, equals(dartObj2.JS_INSTANCE_PROXY));
      expect(dartObj2.hasJsInstance, isTrue);
      dartObj2.detachJsInstance();
      expect(dartObj2.hasJsInstance, isFalse);
      expect(jsObj2[DART_OBJ_KEY], isNull);
      expect(jsObj2, isNot(equals(dartObj2.JS_INSTANCE_PROXY)));
    });
    test("SimpleClass2WithNS", () {
      var link = getObjectByPath("dart.SimpleClass2WithNS");
      expect(link.runtimeType, equals(JsFunction));
      JsFunction ctor = link as JsFunction;
      var obj = new JsObject(ctor);
      expect(obj, isNotNull);
      expect(obj.instanceof(ctor), isTrue);
      var dartObj = obj[DART_OBJ_KEY] as JsProxyContainer;
      expect(dartObj, isNotNull);
      expect(dartObj.JS_INSTANCE_PROXY, obj);
    });
    test("SimpleClass3 - method w/o args", () {
      var link = getObjectByPath("SimpleClass3");
      JsFunction ctor = link as JsFunction;
      var obj = new JsObject(ctor);
      var dartObj = new SimpleClass3();
      expect(obj, isNotNull);
      expect(obj.instanceof(ctor), isTrue);
      expect(obj.callMethod("method1woArgs"), equals(dartObj.method1woArgs()));
      expect(obj.callMethod("method2woArgs"), equals(dartObj.method2woArgs()));
      expect(obj.callMethod("method3woArgs"), equals(dartObj.method3woArgs()));
      expect(obj.callMethod("method4woArgs"), equals(dartObj.method4woArgs()));
    });
    test("SimpleClass4 - constructor w/o args", () {
      var obj = new JsObject(getObjectByPath("SimpleClass4_public1") as JsFunction);
      expect(obj, isNotNull);
      obj = new JsObject(getObjectByPath("SimpleClass4") as JsFunction);
      expect(obj, isNotNull);
      expect(getObjectByPath("SimpleClass4_internal"), isNull);
    });

    test("SimpleClass5 - property", () {
      var obj = new JsObject(getObjectByPath("SimpleClass5") as JsFunction);
      expect(obj, isNotNull);
      var objDart = new SimpleClass5();
      //propertyString1ReadOnly()
      expect(obj["propertyString1ReadOnly"], equals(objDart.propertyString1ReadOnly));
      expect(obj["propertyInt1ReadOnly"], equals(objDart.propertyInt1ReadOnly));
      obj["propertyString1ReadOnly"] = "TEST";
      expect(obj["propertyString1ReadOnly"], equals(objDart.propertyString1ReadOnly));
      obj["propertyInt1ReadOnly"] = 1;
      expect(obj["propertyInt1ReadOnly"], equals(objDart.propertyInt1ReadOnly));
      expect(obj["_privateProperty2"], isNull);
      expect(obj["propertyString2"], equals(objDart.propertyString2));
      obj["propertyString2"] = objDart.propertyString2 = "TEST_STR";
      expect(obj["propertyString2"], equals(objDart.propertyString2));
      expect(obj.callMethod('getPropertyString2'), equals(objDart.getPropertyString2()));
    });

    test("SimpleClass6 - inheritance", () {
      var ctor = getObjectByPath("SimpleClass6") as JsFunction;
      var obj = new JsObject(ctor);
      expect(obj, isNotNull);
      expect(obj.instanceof(ctor), isTrue);
      expect(obj.instanceof(getObjectByPath("SimpleClass5")), isTrue);
      expect(obj.instanceof(getObjectByPath("SimpleClass1")), isFalse);
    });

    test("SimpleClass6 - inheritance method/property", () {
      var ctor = getObjectByPath("SimpleClass6") as JsFunction;
      var obj = new JsObject(ctor);
      var objDart = new SimpleClass6();
      expect(obj["propertyString1ReadOnly"], equals(objDart.propertyString1ReadOnly));
      expect(obj.callMethod("getPropertyString2"), equals(objDart.getPropertyString2()));
      expect(obj["propertyString2"], equals(objDart.propertyString2));

      expect(obj["propertyString3"], equals(objDart.propertyString3));
      obj["propertyString3"] = "123";
      objDart.propertyString3 = "123";
      expect(obj["propertyString3"], equals(objDart.propertyString3));
      expect(obj.callMethod("getPropertyString3"), equals(objDart.getPropertyString3()));
    });

  });
}

main(){
  context["dart"] = new JsObject.jsify({});
  initTest();
}