part of jsMimicry.generator;

class GeneratorJsMimicry {
  final File entryPoint;
  Set<String> pass1Job = new Set();
  Set<String> pass2Job = new Set();
  List<String> jobs = [];
  Map<String, String> superClassByClass = {};
  Map<String, String> filenameByClass = {};
  Set<String> proxyGenClassList = new Set();
  Map<String, DartClassInfo> classInfo = {};
  Map<String, String> libraryFilenameByFilename = {};
  GeneratorJsMimicry(File this.entryPoint) {
    var absPath = path.absolute(entryPoint.path);
    jobs.add(absPath);
    _phase1();
    _phase2();

    classInfo.forEach((className, info) {
      if (info.superClazz != null) {
        var parenClassInfo = classInfo[info.superClazz.dartClassName];
        if (parenClassInfo != null) {
          info.superClazz = parenClassInfo.clazz;
        }
      }
    });
  }

  generateProxyFile(StringBuffer sb, String outputFileName) {
    outputFileName = path.normalize(path.absolute(path.dirname(outputFileName)));
    sb.writeln("library jsProxy;");
    sb.writeln(r"/* AUTO-GENERATED FILE.  DO NOT MODIFY.*/");
    sb.writeln("");
    sb.writeln("import 'dart:js' as js;");
    sb.writeln("");
    Set<String> files = new Set();
    proxyGenClassList.forEach((v) {
      var tmp = filenameByClass[v];
      if (tmp == null){
        print("Skip '$v'");
        return;
      }
      var filePath = path.relative(libraryFilenameByFilename[tmp], from: outputFileName);
      files.add(filePath);
    });
    files.forEach((filePath) {
      sb.writeln("import '$filePath';");
    });
    classInfo.forEach((k, v) {
      sb.writeln("");
      sb.writeln("//--------------------------");
      sb.writeln("//   ${v.clazz.dartClassName} -> ${v.clazz.jsPath}");
      sb.writeln("//--------------------------");
      v.generateProxyClass(sb);
    });
  }

  void _phase2() {
    pass1Job.clear();

    proxyGenClassList.toList().forEach((className) {
      String parent;
      while ((parent = superClassByClass[className]) != null) {
        proxyGenClassList.add(parent);
        var tmp = filenameByClass[parent];
        if (tmp!=null){
          pass2Job.add(tmp);
        }
        className = parent;
      }
    });
    jobs.addAll(pass2Job);
    pass2Job.clear();
    while (jobs.length > 0) {
      var target = jobs.removeAt(0);
      if (pass2Job.contains(target) || !new File(target).existsSync()) {
        continue;
      }
      var ast = parseDartFile(target);
      ast.accept(new ProxyCollectorVisitor(this));
    }
  }

  void _phase1() {
    while (jobs.length > 0) {
      var target = jobs.removeAt(0);
      if (pass1Job.contains(target) || !new File(target).existsSync()) {
        continue;
      }
      pass1Job.add(target);
      print("Parsing '$target'");
      var ast = parseDartFile(target);
      var collector = new CollectorVisitor(this, target);
      ast.accept(collector);
    }
  }
}
