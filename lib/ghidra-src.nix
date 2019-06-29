# https://github.com/NationalSecurityAgency/ghidra/blob/master/DevGuide.md

# plugins is a list of extracted plugin derivations to symlink into <ghidraroot>/Ghidra/Extensions.
# This is entirely sufficient for ghidra to operate.
{
  #stdenv, fetchurl, unzip, makeWrapper, autoPatchelfHook, # Utilities
  #jdk, pam, # Deps
  #lib, config, plugins ? [], extraLaunchers ? {}, # Ghidra
  #pkgs
  stdenv, fetchFromGitHub
  gradleGen
  bison, flex
  #gcc
  }:

#Following the manual dep download instructions
let
in

let
  inherit (pkgs.lib) concatMapStrings concatStrings mapAttrsToList;
  inherit (lib) jdkWrapper installPlugin unpackPlugin writeCustomLauncher fetchGitHubJSON;
in

  stdenv.mkDerivation rec {
    name = "ghidra-${version}-bin";
    version = "9.0.4";

    # nix-shell -p nix-prefetch-github --run "nix-prefetch-github felberj gotools > gotools.json
    src = lib.fetchGitHubJSON { JSONfile = ./ghidra-src.json; };

    buildInputs = [
      #git, bash
      gradleGen bison flex
      #TODO dex2jar
      # AXMLPrinter2 ...what?
      # HFS Explorer
      # Yet Another Java Service Wrapper. "only to build ghidra package"

      #for dev?:
      # Eclipse - It must support JDK 11. Eclipse 2018-12 or later should work. Other IDEs may work, but we have not tested them.   

      #TODO plugin stuff
      # Eclipse PDE - Environment for developing the GhidraDev plugin. 
      # Eclipse CDT. We use version 8.6.0 - Build dependency for the GhidraDev plugin. 
      # PyDev. We use version 6.3.1 - Build dependency for the GhidraDev plugin. 

      #oh boy 
      # There are many, many others automatically downloaded by Gradle from Maven Central and Bintray JCenter when building and/or setting up the development environment. If you need these offline, a reasonable course of action is to set up a development environment online, perhaps perform a build, and then scrape Gradle's cache.
      ];

    #nativeBuildInputs = [
    #  makeWrapper
    #  autoPatchelfHook
    #  unzip
    #  ];

    ## For autoPatchelf
    #buildInputs = [
    #  stdenv.cc.cc.lib
    #  pam
    #  ];

    #dontStrip = true;

    #installPhase = ''
    #  mkdir -p -- "$out/${config.pkg_path}"
    #  cp -a -- * "$out/${config.pkg_path}"
    #  '';

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
