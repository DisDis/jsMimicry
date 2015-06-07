// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code transform for @observable. The core transformation is relatively
/// straightforward, and essentially like an editor refactoring.
library js_mimicry.transformer.jsInstance;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:source_maps/refactor.dart';
import 'package:source_span/source_span.dart';
import 'package:js_mimicry/generator.dart';

class JsInstanceTransformer extends Transformer {
  final bool releaseMode;
  //final bool injectBuildLogsInOutput;
  final List<String> _files;
  JsInstanceTransformer(
      {List<String> files, bool releaseMode, bool injectBuildLogsInOutput})
      : _files = files,
        releaseMode = releaseMode == true;
  JsInstanceTransformer.asPlugin(BarbackSettings settings)
      : _files = _readFiles(settings.configuration['files']),
        releaseMode = settings.mode ==
            BarbackMode.RELEASE
  ;

  static List<String> _readFiles(value) {
    if (value == null) return null;
    var files = [];
    bool error;
    if (value is List) {
      files = value;
      error = value.any((e) => e is! String);
    } else if (value is String) {
      files = [value];
      error = false;
    } else {
      error = true;
    }
    if (error) print('Invalid value for "files" in the observe transformer.');
    return files;
  }

  // TODO(nweiz): This should just take an AssetId when barback <0.13.0 support
  // is dropped.
  Future<bool> isPrimary(idOrAsset) {
    var id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value(id.extension == '.dart' &&
        (_files == null || _files.contains(id.path)));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      // Do a quick string check to determine if this is this file even
      // plausibly might need to be transformed. If not, we can avoid an
      // expensive parse.
      if (!jsProxyMatcher.hasMatch(content)) return null;

      var id = transform.primaryInput.id;
      // TODO(sigmund): improve how we compute this url
      var url = id.path.startsWith('lib/')
          ? 'package:${id.package}/${id.path.substring(4)}'
          : id.path;
      var sourceFile = new SourceFile(content, url: url);
      var logger =
          new BuildLogger(transform, convertErrorsToWarnings: !releaseMode);
      var transaction = _transformCompilationUnit(content, sourceFile, logger);
      if (!transaction.hasEdits) {
        transform.addOutput(transform.primaryInput);
      } else {
        var printer = transaction.commit();
        printer.build(url);
        transform.addOutput(new Asset.fromString(id, printer.text));
      }

    });
  }
}

TextEditTransaction _transformCompilationUnit(
    String inputCode, SourceFile sourceFile, BuildLogger logger) {
  var unit = parseCompilationUnit(inputCode, suppressErrors: true);
  var code = new TextEditTransaction(inputCode, sourceFile);

  for (var declaration in unit.declarations) {
    if (declaration is ClassDeclaration && _hasObservable(declaration)) {
      _transformClass(declaration, code, sourceFile, logger);
    }
  }
  return code;
}


bool _hasObservable(AnnotatedNode node) =>
    node.metadata.any(_isObservableAnnotation);

bool _isObservableAnnotation(Annotation node) =>
    _isAnnotationType(node, 'JsProxy');

bool _isAnnotationType(Annotation m, String name) => m.name.name == name;


void _transformClass(ClassDeclaration cls, TextEditTransaction code,
    SourceFile file, BuildLogger logger) {

  var implementJsProxyContainer = false;
  if (cls.implementsClause != null) {
    implementJsProxyContainer = cls.implementsClause.interfaces
        .any((item) => _getSimpleIdentifier(item.name) == DartClassInfo.JsProxyContainer_KEY);
  }
  if (!implementJsProxyContainer) {
    if (cls.implementsClause != null) {
      code.edit(cls.implementsClause.interfaces.first.end,
          cls.implementsClause.interfaces.first.end,
          ', ${DartClassInfo.JsProxyContainer_KEY} ');
    } else {
      int insertPos = cls.leftBracket.offset;
      code.edit(insertPos, insertPos, ' implements ${DartClassInfo.JsProxyContainer_KEY} ');
    }
    code.edit(cls.endToken.offset, cls.endToken.offset, """
    dynamic _${DartClassInfo.JS_INSTANCE_PROXY};
    dynamic get ${DartClassInfo.JS_INSTANCE_PROXY}{
       if (_${DartClassInfo.JS_INSTANCE_PROXY} == null){
         _${DartClassInfo.JS_INSTANCE_PROXY} = ${DartClassInfo.JsProxyFactory_CLASS}.toJS[${_getSimpleIdentifier(cls.name)}](this);
       }
       return _${DartClassInfo.JS_INSTANCE_PROXY};
    }
    set ${DartClassInfo.JS_INSTANCE_PROXY}(v)=>_${DartClassInfo.JS_INSTANCE_PROXY} = v;
    detachJsInstance(){
      if (_${DartClassInfo.JS_INSTANCE_PROXY}!=null){
        _${DartClassInfo.JS_INSTANCE_PROXY}["${DartClassInfo.DART_OBJ_KEY}"] = null;
        _${DartClassInfo.JS_INSTANCE_PROXY} = null;
      }
    }
    """);
  }
}

SimpleIdentifier _getSimpleIdentifier(Identifier id) =>
    id is PrefixedIdentifier ? id.identifier : id;

final jsProxyMatcher = new RegExp("@(JsProxy)");
