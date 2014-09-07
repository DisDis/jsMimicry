library jsMimicry.generator;
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/formatter.dart';
import 'package:analyzer/src/services/formatter_impl.dart';
import 'package:analyzer/src/generated/source.dart';

part 'src/generator_js_mimicry.dart';
part 'src/dart_method_info.dart';
part 'src/dart_class_info.dart';
part 'src/dart_class_visitor.dart';
part 'src/dart_method_mutator.dart';



class ProxyCollectorVisitor extends GeneralizingAstVisitor {
  final GeneratorJsMimicry generator;
  ProxyCollectorVisitor(this.generator);
  @override
  visitClassDeclaration(ClassDeclaration node) {
    String className = node.name.toString();
    if (generator.proxyGenClassList.contains(className)) {
      Annotation annotation;
      if (node.metadata != null) {
        annotation = node.metadata.firstWhere((ann) => ann.name.toString() == DartClassInfo.ANNOTATION_CLASS, orElse: () => null);
      }
      generator.classInfo[node.name.toString()] = new DartClassInfo(annotation, node);
    }
    return super.visitClassDeclaration(node);
  }
}

class CollectorVisitor extends GeneralizingAstVisitor {
  final GeneratorJsMimicry generator;
  final String startPath;
  final String fileName;
  CollectorVisitor(this.generator, fileName)
      : this.startPath = path.dirname(fileName),
        this.fileName = fileName;
  @override
  visitImportDirective(ImportDirective node) {
    var fName = (node.uri as SimpleStringLiteral).value;
    fName = path.normalize(path.absolute(startPath, fName));
    generator.jobs.add(fName);
    generator.libraryFilenameByFilename[fName] = fName;
    return super.visitImportDirective(node);
  }

  @override
  visitPartDirective(PartDirective node) {
    var fName = (node.uri as SimpleStringLiteral).value;
    fName = path.normalize(path.absolute(startPath, fName));
    generator.jobs.add(fName);
    generator.libraryFilenameByFilename[fName] = fileName;
    super.visitPartDirective(node);
  }

  @override
  visitClassDeclaration(ClassDeclaration node) {
    String superClass;
    String className = node.name.toString();
    if (node.extendsClause != null) {
      superClass = node.extendsClause.superclass.toString();
    }
    generator.superClassByClass[className] = superClass;
    generator.filenameByClass[className] = fileName;
    return super.visitClassDeclaration(node);
  }

  @override
  visitAnnotation(Annotation node) {
    //jsMutator:MethodDeclaration
    if (node.name.toString() == DartClassInfo.ANNOTATION_CLASS && node.parent is ClassDeclaration) {
      var nodeClass = node.parent as ClassDeclaration;
      String dartClassName = nodeClass.name.toString();
      generator.proxyGenClassList.add(dartClassName);
      generator.pass2Job.add(fileName);
    }

    super.visitAnnotation(node);
  }
}


class SpecialSourceVisitor extends SourceVisitor {
  Map<AstNode, DartClassInfo> proxyCollect = {};
  SpecialSourceVisitor(FormatterOptions options, LineInfo lineInfo, String source, Selection preSelection) : super(options, lineInfo, source, preSelection);
  @override
  visitAnnotation(Annotation node) {
    //jsMutator:MethodDeclaration
    if (node.name.toString() == DartClassInfo.ANNOTATION_CLASS && node.parent is ClassDeclaration) {
      proxyCollect[node.parent] = new DartClassInfo(node, node.parent as ClassDeclaration);
    }

    super.visitAnnotation(node);
  }


  @override
  visitMethodDeclaration(MethodDeclaration node) {
    DartClassInfo classInfo = proxyCollect[node.parent];
    if (classInfo == null) {
      super.visitMethodDeclaration(node);
    }
    if (!node.isStatic && node.name.toString() == DartClassInfo.NAME_TO_JS_METHOD) {
      append('static bool ${DartClassInfo.NAME_PROTOTYPE_FLAG} = false;');
      var astClone = new AstCloner();
      FunctionBody fb = classInfo.toJSBody(node.body);
      node = new MethodDeclaration(astClone.cloneNode(node.documentationComment), astClone.cloneNodeList(node.metadata), node.externalKeyword, node.modifierKeyword, astClone.cloneNode(node.returnType), node.propertyKeyword, node.operatorKeyword, astClone.cloneNode(node.name), astClone.cloneNode(node.parameters), fb);
    }
    if (node.isStatic && node.name.toString() == DartClassInfo.NAME_REG_PROTOTYPE_METHOD) {
      var astClone = new AstCloner();
      FunctionBody fb = classInfo.jsRegistrationPrototypeBody(node.body);
      node = new MethodDeclaration(astClone.cloneNode(node.documentationComment), astClone.cloneNodeList(node.metadata), node.externalKeyword, node.modifierKeyword, astClone.cloneNode(node.returnType), node.propertyKeyword, node.operatorKeyword, astClone.cloneNode(node.name), astClone.cloneNode(node.parameters), fb);
    }
    super.visitMethodDeclaration(node);
  }
}
