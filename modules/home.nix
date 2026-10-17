{ pkgs, lib, ... }:

# Home-manager config for reze. Imported as a NixOS module from base.nix via
# `home-manager.users.reze`, so it is activated by nixos-rebuild.

{
  home.stateVersion = "26.11";

  # ─── Niri ───────────────────────────────────────────────────────────────
  # The config lives in `settings` as structured options rather than as a
  # writeText blob, so home-manager generates config.kdl and validates it with
  # `niri validate` on every build (checkConfig is on by default). A bad
  # translation fails the rebuild instead of bricking the session.
  #
  # Note that generated KDL is alphabetically ordered by attribute name and
  # carries no comments, so the section comments below live here in the Nix
  # source — this file is the source of truth, not the generated .kdl.
  wayland.windowManager.niri = {
    enable = true;

    # NixOS `programs.niri` already sets up xdg-desktop-portal system-wide
    # (including the gnome/gtk FileChooser and the keyring Secret portal), so
    # don't install a second, user-level portal config on top of it.
    portalPackage = null;

    # Rationale for the two odd-looking bits below, kept here because the
    # generated file cannot carry comments:
    #
    #   eDP-1 is the internal panel (1920x1080@144, 1.25), wired to the AMD
    #   iGPU (card1). The RTX 1650 Ti (card0) drives no outputs.
    #
    #   The compositor must render on the iGPU: a mixed atomic commit across
    #   card0/card1 hard-freezes this machine. Hardware cursor planes are also
    #   unreliable across the mixed GPU pair, hence debug.disable-cursor-plane.

    settings = {
      # ─── Repeated top-level nodes ─────────────────────────────────────────
      # `output` and `spawn-at-startup` both appear more than once, and Nix
      # attrsets cannot hold duplicate keys, so they go in a single _children.
      _children = [
        {
          output = {
            _args = [ "eDP-1" ];
            mode = "1920x1080@144";
            scale = 1.25;
          };
        }
        {
          spawn-at-startup = [
            "gnome-keyring-daemon"
            "--start"
            "--components=secrets,pkcs11"
          ];
        }
        { spawn-at-startup = [ "mako" ]; }
        # Not lib.getExe' — gvfs keeps this one in libexec, not bin.
        { spawn-at-startup = [ "${pkgs.gnome.gvfs}/libexec/gvfs-udisks2-volume-monitor" ]; }
        # Wallpaper daemon. awww has no config file in 0.12, so it is driven
        # purely by the client: starting the daemon restores the last wallpaper
        # from its cache, and `awww img` swaps it at runtime.
        { spawn-at-startup = [ (lib.getExe' pkgs.awww "awww-daemon") ]; }
    ];

      # ─── Environment ──────────────────────────────────────────────────────
      environment = {
        WLR_DRM_DEVICES = "/dev/dri/card1";
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
        LIBVA_DRIVER_NAME = "radeonsi";
      };

      # ─── Input ────────────────────────────────────────────────────────────
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = { };
          natural-scroll = { };
          dwt = { };
        };
      };

      # ─── Cursor ───────────────────────────────────────────────────────────
      cursor = {
        xcursor-theme = "Bibata-Modern-Ice";
        xcursor-size = 24;
      };

      # ─── Layout ───────────────────────────────────────────────────────────
      layout = {
        gaps = 16;
        center-focused-column = "never";
        always-center-single-column = { };
        # Repeated `proportion` nodes, so this one needs _children.
        preset-column-widths._children = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        border = {
          on = { };
          width = 4;
        };
        focus-ring.off = { };
      };

      prefer-no-csd = { };

      hotkey-overlay.skip-at-startup = { };

      debug.disable-cursor-plane = { };

      # ─── Keybinds ─────────────────────────────────────────────────────────
      binds = {
        "Mod+Return" = { spawn = [ (lib.getExe pkgs.kitty) ]; };
        "Mod+D" = { spawn = [ (lib.getExe pkgs.fuzzel) ]; };
        "Mod+E" = { spawn = [ (lib.getExe pkgs.nautilus) ]; };
        "Mod+Q" = { close-window = { }; };
        "Mod+Shift+E" = { quit = { }; };
        "Mod+V" = { toggle-window-floating = { }; };
      "Mod+F" = { maximize-column = { }; };
      "Mod+Shift+F" = { fullscreen-window = { }; };

        "Mod+Left" = { focus-column-left = { }; };
        "Mod+Right" = { focus-column-right = { }; };
        "Mod+Down" = { focus-window-down = { }; };
        "Mod+Up" = { focus-window-up = { }; };

        "Mod+Shift+Left" = { move-column-left = { }; };
        "Mod+Shift+Right" = { move-column-right = { }; };
        "Mod+Shift+Down" = { move-window-down = { }; };
        "Mod+Shift+Up" = { move-window-up = { }; };

        "Mod+BracketLeft" = { focus-workspace-down = { }; };
        "Mod+BracketRight" = { focus-workspace-up = { }; };

        "Mod+1" = { focus-workspace = 1; };
        "Mod+2" = { focus-workspace = 2; };
        "Mod+3" = { focus-workspace = 3; };
        "Mod+4" = { focus-workspace = 4; };
        "Mod+5" = { focus-workspace = 5; };
        "Mod+6" = { focus-workspace = 6; };
        "Mod+7" = { focus-workspace = 7; };
        "Mod+8" = { focus-workspace = 8; };
        "Mod+9" = { focus-workspace = 9; };

        "Mod+Shift+1" = { move-column-to-workspace = 1; };
        "Mod+Shift+2" = { move-column-to-workspace = 2; };
        "Mod+Shift+3" = { move-column-to-workspace = 3; };
        "Mod+Shift+4" = { move-column-to-workspace = 4; };
        "Mod+Shift+5" = { move-column-to-workspace = 5; };
        "Mod+Shift+6" = { move-column-to-workspace = 6; };
        "Mod+Shift+7" = { move-column-to-workspace = 7; };
        "Mod+Shift+8" = { move-column-to-workspace = 8; };
        "Mod+Shift+9" = { move-column-to-workspace = 9; };

        "Print" = { screenshot = { }; };
        "Mod+Print" = { screenshot-screen = { }; };
        "Shift+Print" = { screenshot-window = { }; };
      };
    };
  };
}
