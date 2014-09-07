part of jsMimicry.generator;

class DartClassVisitor extends GeneralizingAstVisitor {
  final DartClassInfo jsProxyInfo;
  DartClassVisitor(DartClassInfo this.jsProxyInfo) {
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isAbstract && !node.isGetter && !node.isOperator && !node.isSetter && !node.isStatic 
        //&& node.name.toString() != DartClassInfo.NAME_TO_JS_METHOD 
        && !node.name.toString().startsWith("_")) {
      DartMethodMutator dmm = null;
      if (node.metadata != null) {
        node.metadata.forEach((annotation) {
          if (annotation.name.toString() == DartClassInfo.ANNOTATION_METHOD) {
            dmm = new DartMethodMutator();
            if (annotation.arguments != null) {
              annotation.arguments.arguments.forEach((arg) {
                if (arg is! NamedExpression) {
                  return;
                }
                var argN = arg as NamedExpression;
                if (argN.name.label.toString() == "insertParams") {
                  var list = (argN.expression as ListLiteral).elements;
                  dmm.insertParams = list.map((v)=>v.value.toString()).toList(growable:false);
                }
                if (argN.name.label.toString() == "result") {
                  dmm.resultMutator = argN.expression.toString();
                }
              });
            }
          }
        });
      }
      var mi = jsProxyInfo.addMethod(node);
      mi.mutator = dmm;
    }

    super.visitMethodDeclaration(node);
  }
}
