{ inputs, self, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    let
      inherit (inputs) home-manager nix-index-database;
    in
    {
      imports = [
        home-manager.nixosModules.default
        nix-index-database.nixosModules.default
      ];

      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        auto-optimise-store = true;
      };

      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        # NixOS is the only system on this machine, so there is nothing to probe
        # for. Leaving this on made every rebuild re-scan every partition (adding
        # ~20s) and kept resurrecting a stale entry for the old install.
        useOSProber = false;
      };
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.networkmanager.enable = true;

      time.timeZone = "Asia/Kolkata";

      i18n.defaultLocale = "en_IN";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_IN";
        LC_IDENTIFICATION = "en_IN";
        LC_MEASUREMENT = "en_IN";
        LC_MONETARY = "en_IN";
        LC_NAME = "en_IN";
        LC_NUMERIC = "en_IN";
        LC_PAPER = "en_IN";
        LC_TELEPHONE = "en_IN";
        LC_TIME = "en_IN";
      };

      users.users.reze = {
        isNormalUser = true;
        description = "reze";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        # yescrypt hash. A normal user with no password gets `!` written to shadow
        # on activation, which locks the account — SDDM autologin is off, so there
        # would be no way back in.
        #
        # The leading `$` is required: MCF format is `$y$j9T$<salt>$<hash>`. NixOS
        # validates this at eval time and warns "you will be locked out" without it,
        # because crypt(3) would not recognise a bare `y$...` prefix.
        hashedPassword = "$y$j9T$IY3QCh0ea6uFa8BgcmH4O/$wttU6G89UruBt8kDIIlsyb5tjDmtFr38rAbMc0rQKf0";
      };

      # ─── Home Manager ───────────────────────────────────────────────────────
      # Used as a NixOS module, so the home generation is built and activated as
      # part of nixos-rebuild rather than by a separate `home-manager switch`.
      # There is no `enable` option anymore — declaring `users` is what activates it.
      home-manager = {
        # Puts the home profile on reze's PATH via users.users.reze.packages.
        # This is what the old `useUserPkgs` (PATH prepending) was renamed to.
        useUserPackages = true;
        users.reze = {
          imports = builtins.attrValues self.homeModules ++ [
            # Gives Home Manager's nix-index Fish hook the prebuilt database,
            # matching the wrapper already configured by the NixOS module.
            nix-index-database.homeModules.default
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        wget
        git
        openconnect
        treefmt
      ];

      # Set system-wide rather than only in home-manager's session variables, so
      # GUI apps launched outside that environment also get truecolor.
      environment.variables.COLORTERM = "truecolor";

      fonts.packages = with pkgs; [
        inter
        maple-mono.truetype
        material-symbols
        nerd-fonts.jetbrains-mono
        nerd-fonts.recursive-mono
        nerd-fonts.symbols-only
      ];

      system.stateVersion = "26.11";
    };

  flake.homeModules.base = { pkgs, ... }: {
    home.stateVersion = "26.11";

    # User packages with no home-manager module of their own.
    home.packages = with pkgs; [
      # For the `tmux -u` alias in fish.nix.
      tmux
      # Lightweight GUI editor for quick edits — nix config, JSON, /etc files.
      gnome-text-editor
    ];

    # Emacs — pure-GTK build for native Wayland. The daemon starts on login via
    # the systemd user service (services.emacs.enable) so `emacsclient` connects
    # instantly. Bound to Mod+A in niri.nix.
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };
    services.emacs = {
      enable = true;
      defaultEditor = true;
    };
  };
}
