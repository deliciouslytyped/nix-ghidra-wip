# The base Ghidra packages (Ghidra and GhidraDev, ...)
self: super: {
  jdk = self.nixpkgs.jdk11;
  gradleGen = (self.nixpkgs.gradleGen.override {jdk = self.jdk;}).gradle_latest;

  #NOTE / WARN? python doesnt do this, why do i need this?
  #TODO is this ghidra.extend consistent with the ghidrapkgs.extend? ...it should be because its a reference?
  #TODO isnt this colliding with the normal extend?
#  ghidra = self.rootTree (self.callPackage ../lib/ghidra.nix {}); #TODO test if this expansion by self.extend actually works correct (does it take the scope of subsequent extends correctly?)
  ghidra = self.callPackage ../lib/ghidra.nix {};

  # For use with `eclipses.eclipseWithPlugins`, see tests/eclipse-00.nix
  ghidraDev = self.nixpkgs.eclipses.plugins.buildEclipseUpdateSite rec {
    name = "GhidraDev";
    version = self.config.ghidraDevVersion;

    sourceRoot = ".";

    src = self.ghidra + "/" + self.config.ghidraDevPath; 
    };
  }
