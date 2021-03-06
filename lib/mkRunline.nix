# The strange application order is so that this can be a .lib function
# (with a self.callPackage inside and partially applied over defaultOpts)
defaultOpts: { lib, config, pkgs }: { ghidra, args ? defaultOpts.args, debug ? defaultOpts.debug }:
    let
      inherit (pkgs.lib) optionalString concatMapStrings escapeShellArg;
      inherit (lib) trace;
      inherit (trace "debug args:" (defaultOpts.debug // debug)) enable suspend listener;
      inherit (trace "args:" (defaultOpts.args // args)) name class maxMemory vmArgs extraArgs enableUserShellArgs;
    in
    let
      nonEmpty = l: builtins.length l != 0;
      nonEmptyS = s: s != "";
      withArgs = cmd: args: cmd + (concatMapStrings (s: " ${s}") args);
      opt = optionalString;
      e = escapeShellArg;
    in
    let
      debugAddrEnv = "DEBUG_ADDRESS=${e listener}"; 
      envVars = builtins.filter nonEmptyS [ (opt enable debugAddrEnv) ]; 
    in ''
      #TODO cannibalized from ghidra launchers
      SCRIPT_FILE="$(readlink -f "$0" 2>/dev/null || readlink "$0" 2>/dev/null || echo "$0")"
      SCRIPT_DIR="''${SCRIPT_FILE%/*}"

      envVars=(${opt (nonEmpty envVars) (withArgs "env" envVars) }) # https://github.com/koalaman/shellcheck/wiki/SC2086
      launcher="${ghidra}/${config.pkg_path}/support/launch.sh" #TODO this hardcode might be a problem if you ever get ln-ed plugins to work
      launchMode="${
        if enable
          then "debug${opt suspend "-suspend"}"
          else "fg"
          }";
      name=${e name}
      maxMemory=${e maxMemory}
      vmArgs="${vmArgs}" # Note this is unescaped
      class=${e class}
      extraArgs=(${extraArgs}) # Note this is unescaped

      "''${envVars[@]}" "$launcher" "$launchMode" "$name" "$maxMemory" "$vmArgs" "$class" \
        "''${extraArgs[@]}" ${opt enableUserShellArgs ''"$@"''}
      ''
