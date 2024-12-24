{
  description = "WLVS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-aerospace-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";

      # NOTE: The below 2 lines are only required on nixos-unstable,
      # if you're on stable, they may break your build
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  let
    username = "cstingl";
    configuration = { pkgs, config, ... }: {

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
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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
          while read src; do
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
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#bird
    darwinConfigurations."bird" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.cstingl = import ./home-manager/home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "cstingl";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              "nikitabobko/homebrew-tap" = inputs.homebrew-aerospace-tap;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;

            # Automatically migrate existing Homebrew installations
            # autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."bird".pkgs;
  };
}
