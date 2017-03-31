library jsmimicry_generator;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' ;
import 'package:source_gen/source_gen.dart';
import 'package:js_mimicry/generator.dart';
import 'package:package_resolver/package_resolver.dart';
import 'package:code_transformers/resolver.dart' as code_transformers;
import 'package:barback/barback.dart' as barback;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'dart:io';

class CheckJsProxyVisitor extends GeneralizingAstVisitor {
  bool hasBootstrap = false;
  bool hasInit = false;
  CheckJsProxyVisitor();
  @override
  visitMethodInvocation(MethodInvocation node) {
    if (node.toString().indexOf(GeneratorJsMimicry.NAME_jsProxyBootstrap)!= -1) {
      hasBootstrap = true;
    }
    if (node.toString().indexOf("${DartClassInfo.NAME_PROXY_FACTORY}.init") != -1) {
      hasInit = true;
    }
    return super.visitMethodInvocation(node);
  }
}

class JsMimicryGenerator extends Generator {

  static int _count = 0;
    static code_transformers.Resolvers _resolvers = new code_transformers.Resolvers(code_transformers.dartSdkDirectory,useSharedSources:true);

  @override
  Future<String> generate(Element element, BuildStep buildStep) async {
     if (element is! FunctionElement) {
       return null;
     }
     // ignore: CAST_TO_NON_TYPE
     final functionElement = element as FunctionElement;
     if (!functionElement.isEntryPoint){
       return null;
     }

     buildStep.logger.info("Now parsing: ${buildStep.input.id}, time:${new DateTime.now()} #$_count");
     _count++;

     var visitor = new CheckJsProxyVisitor();

     functionElement.computeNode().accept(visitor);

    final errors = new List<String>()
       ..addAll(checkImportGen(element))
       ..addAll(checkBootstrap(visitor))
       ..addAll(checkInit(visitor))
       ..addAll(checkImport(element));

    if (errors.isNotEmpty) {
      throw _makeError(errors);
    }

    var _resolver = await _resolvers.get(new ResolverTransform(buildStep),[new barback.AssetId(buildStep.input.id.package,buildStep.input.id.path)]);

    var a = new Asset(buildStep.input.id.changeExtension('.js.g.dart'),await generateCode(_resolver));
    _resolver.release();
    buildStep.writeAsString(a);
    return null;
  }

  checkImport(Element classElement) {
    final expectedCode = "import 'package:js_mimicry/annotation.dart'";
    return classElement.library.source.contents.data.contains(expectedCode)
        ? <String>[]
        : <String>["add Import: '$expectedCode'"];
  }

  checkInit(CheckJsProxyVisitor visitor) {
    return visitor.hasInit
      ? <String>[]
      : <String>["add '${DartClassInfo.NAME_PROXY_FACTORY}.init();' to main()"];
  }

  checkBootstrap(CheckJsProxyVisitor visitor) {
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

  Future<String> generateCode(code_transformers.Resolver resolver) async{
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
    return sb.toString();
  }
}

// Resolver transform is used for model generator resolver.
class ResolverTransform implements barback.Transform{
  final BuildStep buildStep;
  ResolverTransform(this.buildStep);
  @override
  void addOutput(barback.Asset output) {
    return null;
  }

  @override
  void consumePrimary() {
    return null;
  }

  @override
  Future<barback.Asset> getInput(barback.AssetId id) {
    return null;
  }

  @override
  Future<bool> hasInput(barback.AssetId id) {
    return null;
  }

  @override
  // ignore: RETURN_OF_INVALID_TYPE
  barback.TransformLogger get logger => buildStep.logger;

  @override
  barback.Asset get primaryInput =>
      /// We need this fake asset for Resolvers.get method.
  new barback.Asset.fromString(new barback.AssetId("", ""), "");

  @override
  Stream<List<int>> readInput(barback.AssetId id) {
    return null;
  }

  @override
  Future<String> readInputAsString(barback.AssetId assetId, {Encoding encoding}) async{
    var current = await PackageResolver.loadConfig(new Uri.file('.packages'));
    String packagePath = await current.packagePath(assetId.package);
    String filename = path.join(packagePath, assetId.path);
    return new File(filename).readAsString();
  }
}
