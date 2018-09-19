part of jsMimicry.generator;

class DartPropertyInfo{
  final String name;
  final bool isFinal;
  bool isWritable;
  DartPropertyInfo(this.name,{this.isFinal:false, this.isWritable:false});

  factory DartPropertyInfo.field(VariableDeclaration vitem) {
    return new DartPropertyInfo(vitem.name.toString(),isFinal: vitem.isFinal, isWritable: !vitem.isFinal);
  }

  void getCode(StringBuffer sb, JsClass clazz){
    sb.writeln("//    property '$name'");
    sb.writeln("js.context['Object'].callMethod('defineProperty',<dynamic>[proto,'$name', new js.JsObject.jsify({");
    if (isWritable){
      sb.writeln("""'set': new js.JsFunction.withThis((dynamic that, dynamic value) {
      value = _toDart(value);
      (that['${DartClassInfo.DART_OBJ_KEY}'] as ${clazz.importDartClassName}).${name} = value;
      }),""");
    }
    sb.writeln("""'get': new js.JsFunction.withThis((dynamic that){
    final dynamic result = ((that['${DartClassInfo.DART_OBJ_KEY}'] as ${clazz.importDartClassName}).${name});
    return _toJs<dynamic>(result);
    }),""");

    sb.writeln("'enumerable': true");
    sb.writeln("})]);");
  }
}
