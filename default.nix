{callPackage ? (import ./lib/nixpkgs-pinned.nix).callPackage }: {
  ghidra = callPackage ./packages.nix {};
  }
