import 'dart:io';
import 'package:analyzer/formatter.dart';
import 'package:analyzer/src/services/formatter_impl.dart';
import 'package:js_mimicry/generator.dart';

main(List<String> args) {/*
  if (args.length > 0) {
    var options = new FormatterOptions(codeTransforms: true);
    var formatter = new CodeJsProxier(options);
    var result = formatter.format(CodeKind.COMPILATION_UNIT, new File(/*args[0]*/"testObj.dart").readAsStringSync());
    new File(args[0] + ".new.dart").writeAsStringSync(result.source, mode: FileMode.WRITE);
  } else {
    print("Uses: gen <file.dart>");
  }*/
  var fileName = /*args[0]*/"../test/index.dart";
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

