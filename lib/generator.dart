library jsMimicry.generator;
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/src/asset/asset_id.dart';

part 'src/generator_js_mimicry.dart';
part 'src/dart_method_info.dart';
part 'src/dart_class_info.dart';
part 'src/dart_class_visitor.dart';
part 'src/dart_method_mutator.dart';
part 'src/dart_property_info.dart';


class CollectorVisitor extends GeneralizingAstVisitor {
  final GeneratorJsMimicry generator;
  final String classPrefix;
  CollectorVisitor(this.generator, this.classPrefix);

  @override
  visitClassDeclaration(ClassDeclaration node) {
    String superClass;
    String className = node.name.toString();
    if (node.extendsClause != null) {
      superClass = node.extendsClause.superclass.toString();
    }
    generator.superClassByClass[className] = superClass;
      Annotation annotation;
      if (node.metadata != null) {
        annotation = node.metadata.firstWhere((ann) => ann.name.toString() == DartClassInfo.ANNOTATION_CLASS, orElse: () => null);
      }
      generator.classInfo[className] = new DartClassInfo(annotation, node, classPrefix);
    return super.visitClassDeclaration(node);
  }
}