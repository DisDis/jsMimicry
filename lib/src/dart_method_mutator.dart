part of jsMimicry.generator;

class DartMethodMutator{
  List<String> insertParams = const [];
  String resultMutator;
  
  List<DartMethodParameter> changeInputParameters(List<DartMethodParameter> parameters) {
    if (insertParams == null || insertParams.length==0){
      return parameters;
    }
    List<DartMethodParameter> result = [];
    insertParams.forEach((iparam){
      result.add(new DartMethodParameter(iparam, ParameterKind.REQUIRED,null,true));
    });
    result.addAll(parameters);
    return result;
  }
  
  String changeResult(String result) {
    if (resultMutator == null){
      return result;
    }
    return """${resultMutator}(${result}${insertParams.length==0?'':','+insertParams.join(',')})""";
  }
}
