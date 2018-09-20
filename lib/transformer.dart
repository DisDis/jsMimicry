library jsMimicry.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:js_mimicry/instance_transformer.dart';
import 'package:js_mimicry/resolver_transformer.dart';


class JsMimicryTransformerGroup implements TransformerGroup {
  final Iterable<Iterable> phases;

  JsMimicryTransformerGroup(BarbackSettings settings)
  : phases = createDeployPhases(settings);

  JsMimicryTransformerGroup.asPlugin(BarbackSettings settings)
  : this(settings);
}

List<List<Transformer>> createDeployPhases(BarbackSettings settings) {
  var phases = [];

  phases.addAll([
    [new JsInstanceTransformer.asPlugin(settings)],
    [new JsMimicryResolverTransformer.asPlugin(settings)]
  ]);
  return phases;
}




