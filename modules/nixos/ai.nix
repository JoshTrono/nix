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

      # Third-party cache, trusted only where this module is used. (It used to
      # be in nix-caches.nix, which trusted it on every host. Note that
      # nix-amd-ai is not currently declared in flake.nix's inputs.)
      nix.settings = {
        substituters = [ "https://nix-amd-ai.cachix.org" ];
        trusted-public-keys = [
          "nix-amd-ai.cachix.org-1:F4OU4vw/lV2oiG6SBHZ+nqjl4EFJuqI4X9A7pvaBmhQ="
        ];
      };

      environment.systemPackages = with pkgs; [
        opencode
      ];

      hardware.amd-npu = {
        enable = true;
        enableNPU = false; # default; set false for GPU-only hosts (see "Other hardware")
        enableFastFlowLM = false; # LLM inference on NPU (requires enableNPU)
        # fastflowlm.package = pkgs.fastflowlm;  # swap in an flm-compatible runtime (see below)
        enableLemonade = true; # OpenAI-compatible API server
        enableROCm = true; # ROCm GPU backends (llamacpp + sd-cpp)
        enableVulkan = true; # Vulkan GPU backends (llamacpp + whispercpp)
        enableImageGen = true; # default true; set false to drop sd-cpp from closure
        # rocmGpuTargets = ["gfx1103"];  # only to reach a GPU the shipped
        #                                # gfx1150+gfx1151 build doesn't cover
        lemonade.user = "${vars.username}";
      };

      users.users."${vars.username}".extraGroups = [
        "video"
        "render"
      ];

    };
}
