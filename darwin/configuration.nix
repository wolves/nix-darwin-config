{
  pkgs,
  config,
  ...
}: let
    username = "cstingl";
in {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.mkalias

    # pkgs.automake
    # pkgs.bison
    # pkgs.coreutils
    # pkgs.readline

    pkgs.alacritty
    pkgs.bat
    pkgs.bottom
    pkgs.curl
    pkgs.duf
    pkgs.exercism
    pkgs.eza
    pkgs.fd
    pkgs.fish
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.gnused
    pkgs.imagemagick
    pkgs.jq
    pkgs.just
    pkgs.pandoc
    pkgs.procs
    pkgs.ripgrep
    pkgs.starship
    pkgs.tealdeer
    pkgs.tmux
    pkgs.tree-sitter
    pkgs.wget
    pkgs.wireguard-tools
    pkgs.zathura
    pkgs.zlib
    pkgs.zoxide

    # pkgs.skimpdf
    pkgs.postman
    pkgs.qbittorrent
  ];

  users.users.cstingl = {
    name = username;
    home = "/Users/cstingl";
  };

  environment.shells = [
    pkgs.fish
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      "nikitabobko/tap/aerospace"
      "brave-browser@beta"
      "calibre"
      "cleanshot"
      "discord"
      "epic-games"
      "figma"
      "firefox@developer-edition"
      "logi-options+"
      "pocket-casts"
      "rapidapi"
      "raycast"
      "slack"
      "spotify"
      "steam"
      "syncthing"
      "todoist"
      "tor-browser"
      "visual-studio-code@insiders"
      "zoom"
    ];
    brews = [
      "automake"
      "bison"
      "coreutils"
      "readline"
      "openssl@3"
      "gdbm"
      "gnupg"
      "golang-migrate"
      "libffi"
      "libpq"
      "libyaml"
      "python-setuptools"
      "xz"
    ];
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
