import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:build/build.dart';

class TypeProviderHelper {
  InterfaceType _iterableType;
  InterfaceType _mapType;
  InterfaceType _stringType;
  InterfaceType _boolType;
  InterfaceType _intType;
  InterfaceType _objectType;
  InterfaceType get iterableType => _iterableType;
  InterfaceType get mapType => _mapType;
  InterfaceType get intType => _intType;
  InterfaceType get stringType => _stringType;
  InterfaceType get boolType => _boolType;
  InterfaceType get objectType => _objectType;


  static const String coreLibraryName = 'dart.core';
  static const String jsLibraryName = 'dart.js';
  static const String htmlLibraryName = 'dart.html';
  static TypeProviderHelper _typeProviderHelperInstance;

  Namespace _coreNamespace;

  static Future<TypeProviderHelper> initInstance(Resolver resolver) async {
    if (_typeProviderHelperInstance == null) {
      _typeProviderHelperInstance = new TypeProviderHelper(await resolver.findLibraryByName(coreLibraryName));
    }

    return _typeProviderHelperInstance;
  }

  static TypeProviderHelper getInstance(Resolver resolver) {
    assert(_typeProviderHelperInstance != null, 'First you need to init TypeProviderHelper instance. Call TypeProviderHelper.initInstance(resolver); function');
    return _typeProviderHelperInstance;
  }

  TypeProviderHelper(LibraryElement coreLibrary) {
    assert(coreLibrary != null);
    assert(coreLibrary.name == coreLibraryName);
    _coreNamespace =
        new NamespaceBuilder().createPublicNamespaceForLibrary(coreLibrary);

    _iterableType = _getType(_coreNamespace, "Iterable");
    _mapType = _getType(_coreNamespace, "Map");
    _stringType = _getType(_coreNamespace, "String");
    _boolType = _getType(_coreNamespace, "bool");
    _objectType = _getType(_coreNamespace, "Object");
    _intType = _getType(_coreNamespace, "int");
  }

  bool isIterableType(DartType type) {
    if (type is ParameterizedType && type.typeArguments.length == 1) {
      return isOfType(type, iterableType.instantiate(type.typeArguments));
    }
    return false;
  }

  bool isMapType(DartType type) {
    if (type is ParameterizedType && type.typeArguments.length == 2) {
      return isOfType(type, mapType.instantiate(type.typeArguments));
    }
    return false;
  }

  bool isOfType(DartType checkingType, DartType referenceType) {
    return checkingType.isAssignableTo(referenceType);
  }

  InterfaceType _getType(Namespace namespace, String typeName) {
    Element element = namespace.get(typeName);
    if (element == null) {
      throw new ArgumentError("No definition of type $typeName");
    }
    return (element as ClassElement).type;
  }
}