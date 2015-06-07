library jsMimicry.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/src/dart_sdk.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:js_mimicry/generator.dart';
import 'package:source_maps/refactor.dart';
import 'package:source_span/src/file.dart';
import 'package:path/path.dart' as path;

class InjectJsProxyInitVisitor extends GeneralizingAstVisitor {
  final TextEditTransaction code;
  InjectJsProxyInitVisitor(this.code);
  @override
  visitMethodInvocation(MethodInvocation node) {
    //TODO: detect '${DartClassInfo.JsProxyFactory_CLASS}.init()';
//    if (node.methodName.toString() == "useGeneratedCode") {
//      var arg0 = node.argumentList.arguments[0];
//      code.edit(arg0.offset, arg0.offset, 'initSmoke()..addAll(');
//      code.edit(arg0.end, arg0.end, ')');
//    }
    return super.visitMethodInvocation(node);
  }
}

class JsMimicryTransformer extends Transformer with ResolverTransformer {
  final BarbackSettings settings;
  Transform _transform;
  AssetId _primaryInputId;

  final List<String> libraries = ['test'];
  JsMimicryTransformer.asPlugin(this.settings) {
    resolvers = new Resolvers(dartSdkDirectory);
  }

  Future<bool> _injectJsProxyConfig(Transform transform) async {
    String content = await transform.primaryInput.readAsString();
    CompilationUnit unit = parseCompilationUnit(content, suppressErrors: true);
    var id = transform.primaryInput.id;
    // TODO(sigmund): improve how we compute this url
    var url = id.path.startsWith('lib/') ? 'package:${id.package}/${id.path.substring(4)}' : id.path;
    var sourceFile = new SourceFile(content, url: url);
    var transaction = new TextEditTransaction(content, sourceFile);

    FunctionDeclaration mainDeclaration = null;
    for (var declaration in unit.declarations) {
      if (declaration is FunctionDeclaration && declaration.name.toString() == "main") {
        mainDeclaration = declaration;
        declaration.accept(new InjectJsProxyInitVisitor(transaction));
        break;
      }
    }
    if (mainDeclaration == null) {
      return false;
    }
    if (!transaction.hasEdits) {
      var str = ' ${GeneratorJsMimicry.NAME_jsProxyBootstrap}(); ${DartClassInfo.JsProxyFactory_CLASS}.init(); ';
      transaction.edit(mainDeclaration.end-1,mainDeclaration.end-1,str);
    }


      for (var directive in unit.directives) {
        if (directive is ImportDirective) {
          transaction.edit(directive.offset, directive.offset,
          'import "package:${id.package}/${jsProxyBootstrapFile(transform)}";\nimport "package:js_mimicry/annotation.dart";\n');
          break;
        }
      }
    var printer = transaction.commit();
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
    return true;
  }

  String jsProxyBootstrapFile(transform) => '${path.url.basenameWithoutExtension(transform.primaryInput.id.path)}_jsproxy_bootstrap.dart';

  @override
  Future applyResolver(Transform transform, Resolver resolver) async {
    _transform = transform;
    _primaryInputId = _transform.primaryInput.id;

    if (!(await _injectJsProxyConfig(transform))){
      return;
    }

    GeneratorJsMimicry generator = new GeneratorJsMimicry();
//    transform.logger.info("Js: $_primaryInputId");
    resolver.libraries.forEach((LibraryElement lib){
      if (lib.isInSdk){
        return;
      }
//      transform.logger.info("lib: ${lib.displayName}");
      var classes = lib.units.expand((u) => u.types);
      for (var clazz in classes) {

        var annotationE = clazz.metadata.firstWhere((ElementAnnotation item)=>item.element.enclosingElement.displayName == DartClassInfo.ANNOTATION_CLASS,orElse:()=>null);
        //clazz.metadata.forEach((ElementAnnotation item)=>print('name:$clazz ${item.element.enclosingElement.displayName}'));
        if (annotationE != null) {
          ClassDeclaration node = clazz.node;
          //asset:js_mimicry/test/test1.dart'
          var classAssetId = resolver.getSourceAssetId(clazz.library);
          generator.phase1(node,classAssetId);
        }
      }
    });
    StringBuffer sb = new StringBuffer();
    generator.generateProxyFile(sb);
    var bootstrapId = new AssetId(_primaryInputId.package, 'lib/${jsProxyBootstrapFile(transform)}');
    transform.addOutput(new Asset.fromString(bootstrapId,sb.toString()));
  }
}
