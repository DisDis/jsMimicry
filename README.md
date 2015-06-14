JsMimicry
===========

Allows the use of Dart classes and objects in javascript. Generates a special proxy classes.

Create javascript API for Dart become easier. 

Support:

 * Class inheritance ( with @JsProxy )
 * Named constructors
 * Method
 * Optional positional parameters
 * Optional named parameters
 * Input parameter transform
 * Result mutation
 * Future (via result mutator)
 * Field
 * Getter/Setter
 
Not support:

 * Factory
 * Operator


Try It Now
-----------
Add the js_mimicry package to your pubspec.yaml file:

```yaml
dependencies:
  js_mimicry: ">=0.2.0 <0.3.0"
```

Building and Deploying
----------------------

To build a deployable version of your app, add the js_mimicry transformers to your
pubspec.yaml file:

```yaml
transformers:
- js_mimicry
```

Sample
-----------
##Dart code
```dart
    class Test1{
      method1(p1,[p2]){/* code */}
      method2(p1,p2){/* code */}
    }
    
    class Test2 extends Test1{
      int method2(p1,p2){/* new logic */}
      String method3(Test1 obj){/* code */}
      Future<int> method4(){/* code */}
      Test1 method5({namedP1, namedP2}){/* code */}
      String method6(int value){/* code */}
    }
```

##Add annotation for class
```dart
    @JsProxy()
    class Test1{  // ... cut ...
    }

    @JsProxy()
    class Test2 extends Test1{ // ... cut ...
    }
```
    
##Add annotation for transform input parameter
```dart
    String method6(@JsTransform(ANY_TO_INT) int value){/* code */}

    static int ANY_TO_INT(Object v){
        if (v is String){
         return int.parse(v);
        }
        return v as int;
    }
```
    
##Add annotation for mutation result Future
```dart
    @JsMutator(insertParams:const ["resultCb","errorCb"],result:Test2.futureToCallbacks)
    Future<int> method4(){/* code */}
    
    static futureToCallbacks(Future result,js.JsFunction resultCb,[js.JsFunction errorCb]){
        if (errorCb!=null){
            result = result.catchError((err)=>errorCb.apply([err]));
        }
        result.then((o)=>resultCb.apply([o]));
        return result;
    }
```

##Add annotation for mutation result
```dart
    @JsMutator(result:ANY_TO_STRING)
    Test1 method5(){/* code */}

    static ANY_TO_STRING(v)=>v.toString();
```
    
### Import to javascript
```dart
    import 'dart:js' as js;
    import 'package:js_mimicry/annotation.dart';
    main(){
      // Create instance Test1
      js.context["dartInstanceTest1"] = JsProxyFactory.toJs(new Test1());
    }
```

### Uses in javascript
```dart
    // Create Test2 instance, call method5 with named parameters
    new Test2().method5({namedP1:"123"});
    // call Test1.method1 with optional parameters
    dartInstanceTest1.method1("1");
```

## JsProxyFactory methods
###JsObject toJs(DartClass obj)
Create proxy object for Test2 object.
###DartClass toDart(Type dartType, JsObject obj)
Convert javascript proxy to real Dart object.