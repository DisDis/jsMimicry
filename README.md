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

##Dart code (sample 'entry_point.dart'):
    // entry_point.dart
    /* imports */
    
    class Test1{
      method1(p1,[p2]){/* code */}
      method2(p1,p2){/* code */}
    }
    
    class Test2 extends Test1{
      int method2(p1,p2){/* new logic */}
      String method3(Test1 obj){/* code */}
      Future<int> method4(){/* code */}
      Test1 method5({namedP1, namedP2}){/* code */}
    }

##Add annotation for class
    @JsProxy()
    class Test2 extends Test1{
    // ... cut ...
    }
    
##Add annotation for transform input parameter
    String method3(@JsTransform(Test1Proxy.toDart) Test1 obj){/* code */}
    
##Add annotation for mutation result Future
    @JsMutator(insertParams:const ["resultCb","errorCb"],result:Test2.futureToCallbacks)
    Future<int> method4(){/* code */}
    
    static futureToCallbacks(Future result,js.JsFunction resultCb,[js.JsFunction errorCb]){
        if (errorCb!=null){
            result = result.catchError((err)=>errorCb.apply([err]));
        }
        result.then((o)=>resultCb.apply([o]));
        return result;
    }

##Add annotation for mutation result instance object
    @JsMutator(result:Test1Proxy.toJS)
    Test1 method5(){/* code */}

##Create generator Js Proxy for your entry point dart file
    //Create dart file in bin folder
    import 'dart:io';
    import 'package:analyzer/formatter.dart';
    import 'package:analyzer/src/services/formatter_impl.dart';
    import 'package:js_mimicry/generator.dart';
    
    main(List<String> args) {
        var fileName = "entry_point.dart";
        var gen = new GeneratorJsMimicry(new File(fileName));
        StringBuffer sb = new StringBuffer();
        gen.generateProxyFile(sb,fileName);
        CodeFormatter cf = new CodeFormatter();
        new File(fileName + ".proxy.dart").writeAsStringSync(
          cf.format(CodeKind.COMPILATION_UNIT,
          sb.toString()
          ).source
          , mode: FileMode.WRITE);
    }
Output: entry_point.dart.proxy.dart
Include entry_point.dart.proxy.dart in import.

## Result sample code:
    // entry_point.dart
    import 'package:js_mimicry/annotation.dart';
    import 'entry_point.dart.proxy.dart'
    
    class Test1{
      method1(p1,[p2]){/* code */}
      method2(p1,p2){/* code */}
    }
    
    @JsProxy()
    class Test2 extends Test1{
      int method2(p1,p2){/* new logic */}
      String method3(@JsTransform(Test1Proxy.toDart) Test1 obj)
      @JsMutator(insertParams:const ["resultCb","errorCb"],result:Test2.futureToCallbacks)
      Future<int> method4(){/* code */}
      @JsMutator(result:Test1Proxy.toJS)
      Test1 method5({namedP1, namedP2}){/* code */}
      
      static futureToCallbacks(Future result,js.JsFunction resultCb,[js.JsFunction errorCb]){
        if (errorCb!=null){
            result = result.catchError((err)=>errorCb.apply([err]));
        }
        result.then((o)=>resultCb.apply([o]));
        return result;
      }
    }
    
### Import to javascript
    import 'dart:js' as js;
    main(){
      // Export Test2 class to JS
      Test2Proxy.jsRegistrationPrototype();
      // Create instance Test1
      js.context["dartInstanceTest1"] = Test1Proxy.toJS(new Test1()); 
    }
### Uses in javascript
    // Create Test2 instance, call method5 with named parameters
    new Test2().method5({namedP1:"123"});
    // call Test1.method1 with optional parameters
    dartInstanceTest1.method1("1");

## Proxy methods
###JsObject toJS(<i>DartClass</i> obj)
Create proxy object for Test2 object.
###jsRegistrationPrototype()
Creates a special a new functions on the side javascript.
###<i>DartClass</i> toDart(JsObject obj)
Convert javascript proxy to real Dart object.