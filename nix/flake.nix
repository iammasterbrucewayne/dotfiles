{
  description = "Meow cross-platform flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    walls.url = "github:hubertetcetera/walls-catppuccin-mocha";
    walls.flake = false;  # repo doesn’t have a flake.nix
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, walls, ... }: let
    supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    lib = nixpkgs.lib;
    username = "simple";

    mkHomeConfig = pkgs: {
      home.username = lib.mkForce username;
      home.homeDirectory = lib.mkForce (
        if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
      );
      # Declaratively manage dotfiles (replaces stow)
      home.file = {
        ".zshrc".source = ../zshrc/.zshrc;
        ".config/nvim".source = ../nvim;
        ".config/tmux/tmux.conf".source = ../tmux/tmux.conf;
        ".config/tmux/tmux.reset.conf".source = ../tmux/tmux.reset.conf;
        ".config/ghostty/config".source = ../ghostty/config;
        ".config/ghostty/themes".source = ../ghostty/themes;
        ".config/aerospace/aerospace.toml".source = ../aerospace/aerospace.toml;
        ".hammerspoon".source = ../hammerspoon;
        ".config/sketchybar".source = ../sketchybar;
      };

      # Programs managed by Home Manager
      # programs.zsh.enable = true;
      # programs.tmux.enable = true;

      # User-level packages
      home.packages = with pkgs; [
        neovim
        tmux
        zoxide
        fzf
        stow
        nodejs
        nerd-fonts.jetbrains-mono
        vivaldi
        yazi
        lsd
      ];

      home.stateVersion = "25.05";
    };
  in {

    homeConfigurations = {
      "${username}@meow" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ (mkHomeConfig nixpkgs.legacyPackages.aarch64-darwin) ];
      };
      
      "${username}@linux-desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
        (mkHomeConfig nixpkgs.legacyPackages.x86_64-linux)
        ./modules/walls.nix
        ];
      };
    };
    darwinConfigurations."meow" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.${username} = {
          imports = [ (mkHomeConfig nixpkgs.legacyPackages.aarch64-darwin)
          ./modules/walls.nix ];
          };
        }
        {
          nixpkgs.hostPlatform = "aarch64-darwin";

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; [
            docker
            rustup
            # Add any other core system-level tools here
          ];

          # Homebrew casks for mac-only tools
          homebrew = {
            enable = true;
            taps = [ "nikitabobko/tap" ];
            casks = [
              "ghostty"
              "aerospace"
              "sf-symbols"
              "raycast"
              "vivaldi"
              "cleanshot"
              "1password"
              "superhuman"
              "beeper"
              "obsidian"
              "numi"
              "mullvad-vpn"
              "cyberduck"
              "macfuse"
              "veracrypt" # requires macfuse
              "stremio"
              "todoist-app"
              "betterdisplay"
              "fathom"
            ];
            # ensure casks land in /Applications (not ~/Applications or “Nix Apps”)
            caskArgs.appdir = "/Applications";
            onActivation = {
              autoUpdate = true;
              cleanup = "zap";
            };
            brews = [
            "dockutil"
            "1password-cli"
            ];
          };

          system.primaryUser = username;
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
        }
        {
          system.defaults.dock = {
            autohide = true;
            "show-recents" = false;
            tilesize = 64;
            persistent-apps = [
              { app = "/System/Applications/Apps.app"; }      # apps library
              { app = "/Applications/Vivaldi.app"; }
              { app = "/System/Applications/System Settings.app"; }
              { app = "/Applications/Ghostty.app"; }
            ];
          };
          security.pam.services.sudo_local.touchIdAuth = true;
          system.defaults.screencapture.location = "~/Pictures/screenshots";
        }
      ];
      specialArgs = { inherit inputs username mkHomeConfig; };
    };

    # Shared devShell for both macOS and Linux
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          neovim
          tmux
          rustup
          docker
          stow
          zoxide
          fzf
          nodejs
          pnpm
          tree
          jq
          xh
          nerd-fonts.jetbrains-mono
        ] ++ (if pkgs.stdenv.isLinux then [
          ghostty
        ] else []);

        shellHook = ''
          echo "🐧 Cross-platform shell ready on ${system}"
        '';
      };
    });
  };
}
