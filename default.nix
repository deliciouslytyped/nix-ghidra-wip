#Uncommon knowledge: you can just nix-build this without any args, see nix-instantiate
{callPackage ? (import ./lib/nixpkgs-pinned.nix).callPackage }: {
  ghidra = callPackage ./packages.nix {};
  }
