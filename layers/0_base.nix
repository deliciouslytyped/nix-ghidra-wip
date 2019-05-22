{pkgs, lib}:
extend': self: {
  # Don't pollute the namespace (for e.g. tab completion)
  inherit pkgs;

  # Thus we can take dependencies from both pkgs and Ghidra nevertheless.
  # Packages from ghidra take precedence on collision.
  callPackage = lib.callPackageWith ( self.pkgs // self );

  #inherit extend; #TODO this feels kind of sketchy #TODO this feels SUPER sketchy
  extend = a: self.rootTree (extend' a);

#  #TODO rename this
#  rootTree = root: root // { #TODO / #TODO is this scoped correctly
#    inherit (self) withPlugins extend; # For ergonomics and overrides
#    pkgs = self; # For access
#    };

  tracing = false;
  trace = str: val: 
    if self.tracing then
      lib.traceValFn (v: "${str}\n${lib.generators.toPretty {} v}") val
    else
      val;
  }
