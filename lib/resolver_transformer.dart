library js_mimicry.transformer.resolver;

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
    return super.visitMethodInvocation(node);
  }
}

class JsMimicryResolverTransformer extends Transformer with ResolverTransformer {
  final BarbackSettings settings;
  Transform _transform;
  AssetId _primaryInputId;

  final List<String> libraries = ['test'];
  JsMimicryResolverTransformer.asPlugin(this.settings) {
    resolvers = new Resolvers.fromMock(mockSdkSources);
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
      transaction.edit(mainDeclaration.functionExpression.body.offset+1,mainDeclaration.functionExpression.body.offset+1,' ${GeneratorJsMimicry.NAME_jsProxyBootstrap}(); ');
      transaction.edit(mainDeclaration.end-1,mainDeclaration.end-1,' ${DartClassInfo.NAME_PROXY_FACTORY}.init(); ');
    }


    for (var directive in unit.directives) {
      if (directive is ImportDirective) {
        transaction.edit(directive.offset, directive.offset,
        'import "package:${id.package}/${jsProxyBootstrapFile(transform)}";import "package:js_mimicry/annotation.dart";');
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

    GeneratorJsMimicry generator = new GeneratorJsMimicry(resolver);
    resolver.libraries.forEach((LibraryElement lib){
      if (lib.isInSdk){
        return;
      }
      var classes = lib.units.expand((u) => u.types);
      for (var clazz in classes) {
        var annotationE = GeneratorJsMimicry.getAnnotationFromElement(clazz);
        if (annotationE != null) {
          generator.phase1(clazz);
        }
      }
    });
    StringBuffer sb = new StringBuffer();
    generator.generateProxyFile(sb);
    var bootstrapId = new AssetId(_primaryInputId.package, 'lib/${jsProxyBootstrapFile(transform)}');
    transform.addOutput(new Asset.fromString(bootstrapId,sb.toString()));
  }
}
