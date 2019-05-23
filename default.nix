{callPackage ? (import <nixpkgs> {}).callPackage }:
  callPackage ./packages.nix {}
