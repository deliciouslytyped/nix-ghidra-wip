{scala, lib}:
  let
    # nix-shell -p nix-prefetch-github --run "nix-prefetch-github felberj gotools > gotools.json
    src = lib.fetchGitHubJSON { JSONfile = ./json/gotools.json; };
  in
  (lib.poorMkGradle "gotools" src)
