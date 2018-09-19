library jsmimicry_generator;

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' ;
import 'package:build_resolvers/build_resolvers.dart';
import 'package:js_mimicry/generator.dart';
import 'package:js_mimicry/src/type_provider_helper.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart' show concat;
import 'package:source_gen/source_gen.dart';

Logger _logger = new Logger('js_mimicry_generator');

class CheckJsProxyVisitor extends GeneralizingAstVisitor<dynamic> {
  bool hasBootstrap = false;
  bool hasInit = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.toString().contains(GeneratorJsMimicry.NAME_jsProxyBootstrap)) {
      hasBootstrap = true;
    }
    if (node.toString().contains('${DartClassInfo.NAME_PROXY_FACTORY}.init')) {
      hasInit = true;
    }

    return super.visitMethodInvocation(node);
  }
}

class JsMimicryGenerator extends Generator {

  static int _count = 0;
  static final _resolvers = new AnalyzerResolvers();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    bool hasSufficientFunctions = false;
    for (var element in library.allElements) {
      if (element is! FunctionElement) {
        continue;
      }
      // ignore: CAST_TO_NON_TYPE
      final functionElement = element as FunctionElement;
      if (!functionElement.isEntryPoint) {
        continue;
      }

      _logger.info('Now parsing: ${buildStep.inputId}, time:${new DateTime
          .now()} #$_count');
      _count++;

      final visitor = new CheckJsProxyVisitor();

      functionElement.computeNode().accept<dynamic>(visitor);

      final Iterable<String> errors = concat([
        checkImportGen(element),
        checkBootstrap(visitor),
        checkInit(visitor),
        checkImport(element)
      ]);

      if (errors.isNotEmpty) {
        // ignore: only_throw_errors
        throw _makeError(errors);
      }

      hasSufficientFunctions = true;
    }

    if (hasSufficientFunctions) {
      final _resolver = await _resolvers.get(buildStep);

      final a = await generateCode(_resolver);
      _resolver.release();
      buildStep.writeAsString(
          buildStep.inputId.changeExtension('.js.g.dart'), a);
    }
    return null;
  }

  Iterable<String> checkImport(Element classElement) {
    final expectedCode = "import 'package:js_mimicry/annotation.dart'";
    return classElement.library.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>["add Import: '$expectedCode'"];
  }

  Iterable<String> checkInit(CheckJsProxyVisitor visitor) {
    return visitor.hasInit
        ? <String>[]
        : <String>["add '${DartClassInfo.NAME_PROXY_FACTORY}.init();' to main()"];
  }

  Iterable<String> checkBootstrap(CheckJsProxyVisitor visitor) {
    return visitor.hasBootstrap
        ? <String>[]
        : <String>["added '${GeneratorJsMimicry.NAME_jsProxyBootstrap}();' to main()"];
  }

  Iterable<String> checkImportGen(Element classElement) {
    final fileName =
    classElement.library.source.shortName.replaceAll('.dart', '');
    final expectedCode = "import '$fileName.js.g.dart';";
    return classElement.library.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>['add Import: $expectedCode'];
  }

  InvalidGenerationSourceError _makeError(Iterable<String> todos) {
    final message = new StringBuffer(
        'Please make the following changes to use jsMimicry_generator:\n');
    for (var i = 0; i != todos.length; ++i) {
      message.write('\n${i + 1}. ${todos.elementAt(i)}');
    }

    return new InvalidGenerationSourceError(message.toString());
  }

  Future<String> generateCode(Resolver resolver) async{
    final mimicryResolver = new MimicryResolver(resolver);
    final TypeProviderHelper typeProviderHelper = await TypeProviderHelper.initInstance(resolver);
    final GeneratorJsMimicry generator = new GeneratorJsMimicry(mimicryResolver, typeProviderHelper);
    await resolver.libraries.forEach((LibraryElement lib){
      if (lib.isInSdk){
        return;
      }
      final classes = lib.units.expand((u) => u.types);
      for (var clazz in classes) {
        final annotationE = GeneratorJsMimicry.getAnnotationFromElement(clazz);
        if (annotationE != null) {
          generator.phase1(clazz);
        }
      }
    });

    return generator.generateProxyFile();
  }
}

