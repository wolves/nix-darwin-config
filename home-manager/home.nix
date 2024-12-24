{
  config,
  pkgs,
  ...
}: let
  homeManagerModules = import ../modules/home-manager;
in {
  programs.home-manager.enable = true;

  home.username = "cstingl";
  home.homeDirectory = "/Users/cstingl";

  home.stateVersion = "24.05";

  imports = with homeManagerModules; [
    bat
    nushell
  ];

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
  ];
}
