library jsMimicry.annotation;

/**
 * Indicator from proxy
 */
class jsProxy {
  const jsProxy([String path]);
}

/**
 * Method mutator
 */
class jsMutator {
  const jsMutator({List<String> insertParams,Function result});
}

/**
 * Transform parameter
 */
class jsTransform{
  const jsTransform(Function transformer);
}
