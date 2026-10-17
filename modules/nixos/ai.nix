{
  flake.modules.nixos.ai =
    {
      inputs,
      vars,
      pkgs,
      ...
    }:
    {

      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        loadModels = [  ];
        environmentVariables = {
          # long contexts eat VRAM; lower this if the model spills to CPU
          OLLAMA_CONTEXT_LENGTH = "16384";
        };
      };

      # nixpkgs.config.permittedInsecurePackages = [
      #   "electron-41.10.7"
      # ];

      environment.systemPackages = with pkgs; [
        lmstudio

      ];

    };
}
