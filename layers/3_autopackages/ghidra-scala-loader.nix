{pkgs, lib}:
  let
    scala = pkgs.scala_2_11;

    # nix-shell -p nix-prefetch-github --run "nix-prefetch-github edmcman ghidra-scala-loader > gotools.json
    src = lib.fetchGitHubJSON { JSONfile = ./json/ghidra-scala-loader.json; };
  in
  (lib.poorMkGradle "ghidra-scala-loader" src).overrideAttrs (a: {
    removeJars = ''
      pushd lib
      rm -- *
      popd
      '';
    addJars = ''
      pushd lib
      unpacked=$(mktemp -d)
      pushd -- $unpacked
      cp -- ${scala.src} .
      tar axvf "$(basename -- *)"
      mv -- scala-*/* .
      popd
      cp -- "$unpacked/lib/scala-compiler.jar" ./scala-compiler-2.11.12.jar
      cp -- "$unpacked/lib/scala-library.jar" ./scala-library-2.11.12.jar
      cp -- "$unpacked/lib/scala-reflect.jar" ./scala-reflect-2.11.12.jar
      popd
      '';
    })
