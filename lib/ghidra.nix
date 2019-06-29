# plugins is a list of extracted plugin derivations to symlink into <ghidraroot>/Ghidra/Extensions.
# This is entirely sufficient for ghidra to operate.
{
  stdenv, fetchurl, unzip, makeWrapper, autoPatchelfHook, # Utilities
  jdk, pam, # Deps
  lib, config, plugins ? [], extraLaunchers ? {}, # Ghidra
  pkgs
  }:

let
  inherit (pkgs.lib) concatMapStrings concatStrings mapAttrsToList;
  inherit (lib) jdkWrapper installPlugin unpackPlugin writeCustomLauncher;
in

  stdenv.mkDerivation rec {
    name = "ghidra-${version}-bin";
    version = "9.0.4";

    src = fetchurl {
      url = "https://ghidra-sre.org/ghidra_9.0.4_PUBLIC_20190516.zip";
      sha256 = "1gqqxk57hswwgr97qisqivcfgjdxjipfdshyh4r76dyrfpa0q3d5";
      };

    nativeBuildInputs = [
      makeWrapper
      autoPatchelfHook
      unzip
      ];

    # For autoPatchelf
    buildInputs = [
      stdenv.cc.cc.lib
      pam
      ];

    dontStrip = true;

    installPhase = ''
      mkdir -p -- "$out/${config.pkg_path}"
      cp -a -- * "$out/${config.pkg_path}"
      '';

    postFixup = ''
      mkdir -p -- "$out/bin"
      # Make wrappers
      ${concatMapStrings (l: jdkWrapper "${config.pkg_path}/${l}" "bin/${builtins.baseNameOf l}") config.launchers}
      ${concatStrings (mapAttrsToList writeCustomLauncher extraLaunchers)}
      # Install plugins
      ${concatMapStrings (p: installPlugin (unpackPlugin p)) plugins}
      '';

    meta = with lib; {
      description = "A software reverse engineering (SRE) suite of tools developed by NSA's Research Directorate in support of the Cybersecurity mission";
      homepage = "https://ghidra-sre.org/";
      platforms = [ "x86_64-linux" ];
      license = licenses.asl20;
      maintainers = [ maintainers.ck3d ];
      };
    }
