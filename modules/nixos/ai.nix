{
  flake.modules.nixos.ai =
    {
      inputs,
      vars,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nix-amd-ai.nixosModules.default ];

      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        loadModels = [ "qwen3:8b" ];
        environmentVariables = {
          # long contexts eat VRAM; lower this if the model spills to CPU
          OLLAMA_CONTEXT_LENGTH = "16384";
        };
      };

      nixpkgs.config.permittedInsecurePackages = [
        "electron-41.10.7"
      ];

      environment.systemPackages = [
        pkgs.opencode
        inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
      ];

      environment.etc."opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options.baseURL = "http://localhost:11434/v1";
          models."qwen3:8b".name = "Qwen3 8B";
        };
        model = "ollama/qwen3:8b";
      };
      environment.sessionVariables.OPENCODE_CONFIG = "/etc/opencode/opencode.json";
      # hardware.amd-npu = {
      #   enable = true;
      #   enableNPU = false; # default; set false for GPU-only hosts (see "Other hardware")
      #   enableFastFlowLM = false; # LLM inference on NPU (requires enableNPU)
      #   # fastflowlm.package = pkgs.fastflowlm;  # swap in an flm-compatible runtime (see below)
      #   enableLemonade = true; # OpenAI-compatible API server
      #   enableROCm = true; # ROCm GPU backends (llamacpp + sd-cpp)
      #   enableVulkan = true; # Vulkan GPU backends (llamacpp + whispercpp)
      #   enableImageGen = true; # default true; set false to drop sd-cpp from closure
      #   # rocmGpuTargets = ["gfx1103"];  # only to reach a GPU the shipped
      #   #                                # gfx1150+gfx1151 build doesn't cover
      #   lemonade.user = "${vars.username}";
      # };

      # users.users."${vars.username}".extraGroups = [
      #   "video"
      #   "render"
      # ];
    };
}
