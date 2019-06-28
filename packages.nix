# Construct the package set from some ad-hoc / slightly structured layers.
{lib, callPackage}:
let rooted = callPackage ./lib/extern/nix-rootedoverlay/rooted.nix {};
    inherit (rooted.lib) interface overlays;
in
  rooted.mkRoot {
    interface = interface.default (self: self.ghidra);
    layers = overlays.autoimport ./layers;
    }
