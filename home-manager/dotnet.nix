{ pkgs, ... }:
let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_10_0
  ];
in
{
  home.packages = [
    dotnet
    pkgs.android-tools
    pkgs.jetbrains.rider
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
  };
}
