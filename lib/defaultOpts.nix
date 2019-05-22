# This is essentially for mkRunline, but if it becomes useful to have
# default arguments for something else, this is where they should go.
{
  debug = {
    enable = false;
    suspend = false;
    listener = "127.0.0.1:18001";
    };

  args = {
    name = "Ghidra";
    maxMemory = "";
    vmArgs = "";
    class = "ghidra.GhidraRun";
    extraArgs = "";
    enableUserShellArgs = true;

    #Convenience, see tests/headless-00.nix for an example.
    headless = {
      name = "Ghidra-Headless";
      class = "ghidra.app.util.headless.AnalyzeHeadless";
      };
    };
  }
