# Construct the package set from some ad-hoc / slightly structured layers.
{lib, callPackage}:
let
  api = self: {
    root = self.ghidra;
    withPackages = scope: root: selector: root.override (old: { plugins = (old.plugins or []) ++ (selector scope); });
    };
in
  (callPackage ./lib/extern/nix-rootedoverlay/overlay.nix {}) {
    layers = map import [
      ./layers/1_util.nix # Functions for constructing Ghidra packages
      ./layers/2_base_packages.nix # The base Ghidra packages (Ghidra and GhidraDev, ...)
      ./layers/3_packages.nix # Plugin packages
      ];
    inherit api;
    }
