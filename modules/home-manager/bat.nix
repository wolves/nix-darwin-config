{
  pkgs,
    ...
}: {
  programs.bat = {
    enable = true;
    config = { theme = "kanagawa"; };
    themes = {
      kanagawa = {
        src =
          pkgs.fetchFromGitHub
          {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "e5f7b8a804360f0a48e40d0083a97193ee4fcc87";
            sha256 = "sha256-FnwqqF/jtCgfmjIIR70xx8kL5oAqonrbDEGNw0sixoA=";
          };
        file = "extras/kanagawa.tmTheme";
      };
    };
  };

}
