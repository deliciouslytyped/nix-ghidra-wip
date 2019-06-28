# Functions for constructing Ghidra packages

self: super: {
    config = {
      pkg_path = "lib/ghidra";
      ghidraDevPath = self.config.pkg_path + "/Extensions/Eclipse/GhidraDev/GhidraDev-2.0.0.zip";
      ghidraDevVersion = "2.0.0";
      launchers = [
          "ghidraRun" "support/analyzeHeadless" "support/buildGhidraJar"
          "support/convertStorage" "support/dumpGhidraThreads" "support/ghidraDebug"
          "support/pythonRun" "support/sleigh"
          ];
      #TODO look into using modules
      defaultOpts = import ../lib/defaultOpts.nix;
      tracing = false;
      };

    lib = {
      trace = str: val:
        if self.config.tracing then
          self.nixpkgs.lib.traceValFn (v: "${str}\n${self.nixpkgs.lib.generators.toPretty {} v}") val
        else
          val;

      # nix-shell -p nix-prefetch-github --run "nix-prefetch-github owner repo > ./plugins/json/theplugin.json"
      fetchGitHubJSON = {JSONfile, ...}@args:
        self.nixpkgs.fetchFromGitHub ({ inherit (self.nixpkgs.lib.importJSON JSONfile) owner repo rev sha256; } // (
          builtins.removeAttrs args [ "JSONfile" ]
          ));

      # { args ? defaultOpts.args, debug ? defaultOpts.debug }: # The signature
      mkRunline = self.callPackage ((import ../lib/mkRunline.nix) self.config.defaultOpts) {};

      poorMkGradle = self.callPackage ../lib/poorMkGradle.nix {};

      jdkWrapper = src: dst: ''
        makeWrapper "$out/${src}" "$out/${dst}" \
          --prefix PATH : '${self.nixpkgs.lib.makeBinPath [ self.jdk ]}' \
          --run '. ${self.jdk}/nix-support/setup-hook' #set JAVA_HOME
        '';

      writeCustomLauncher = name: content: ''
        cp -- "${self.nixpkgs.writeShellScriptBin name content}/bin/${name}" "$out/bin/.${name}"
        ${self.lib.jdkWrapper "bin/.${name}" "bin/${name}" }
        '';

      # hash-name -> name
      nameOf = i: with self.nixpkgs.lib;
        let dropHash = s: concatStringsSep "-" (tail (splitString "-" s)); in
          dropHash (removeSuffix ".zip" (builtins.baseNameOf i));

      unpackPlugin = pluginZip:
        self.nixpkgs.stdenv.mkDerivation {
          name = builtins.unsafeDiscardStringContext (self.lib.nameOf pluginZip);
          phases = [ "unpackPhase" "installPhase" ];
          buildInputs = [ self.nixpkgs.unzip ];
          src = pluginZip;
          installPhase = ''
            mkdir -p -- "$out"
            cp -r -- ./* "$out"
            '';
          };

      #TODO mk extracted plugin derivation and ln that? <--use multiple output?
      installPlugin = plugin: ''
        ln -s -- "${plugin}" "$out/${self.config.pkg_path}/Ghidra/Extensions/${self.lib.nameOf (builtins.baseNameOf plugin)}"
        '';
      };

    }
