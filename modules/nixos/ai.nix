{ config, lib, pkgs, inputs, vars, ... }:
{
  imports = [ inputs.nix-amd-ai.nixosModules.default ];
  environment.systemPackages = with pkgs; [
    gaia
    opencode
  ];

  hardware.amd-npu = {
    enable = true;
    enableNPU = true; # default; set false for GPU-only hosts (see "Other hardware")
    enableFastFlowLM = true; # LLM inference on NPU (requires enableNPU)
    # fastflowlm.package = pkgs.fastflowlm;  # swap in an flm-compatible runtime (see below)
    enableLemonade = true; # OpenAI-compatible API server
    enableROCm = true; # ROCm GPU backends (llamacpp + sd-cpp)
    enableVulkan = true; # Vulkan GPU backends (llamacpp + whispercpp)
    enableImageGen = true; # default true; set false to drop sd-cpp from closure
    # rocmGpuTargets = ["gfx1103"];  # only to reach a GPU that doesn't cover gfx1150+gfx1151 build
    lemonade.user = "${vars.username}";
  };

  users.users."${vars.username}".extraGroups = [
    "video"
    "render"
  ];
}
