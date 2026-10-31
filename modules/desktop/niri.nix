{ inputs, ... }:
{
  # ─── Compositor (System-level half) ──────────────────────────────────────
  # Registers the niri session with the display manager and sets up
  # xdg-desktop-portal (including the gnome/gtk FileChooser and the keyring
  # Secret portal).
  flake.nixosModules.niri = {
    programs.niri = {
      enable = true;
      useNautilus = true;
    };
  };

  # ─── Compositor (User-level half) ────────────────────────────────────────
  # Based on niri's own default config (`enableDefaultConfig`), so the whole
  # layout/input/binds/animation surface comes from upstream and stays current
  # across `nix flake update`.
  flake.homeModules.niri = { pkgs, lib, ... }: {
    wayland.windowManager.niri = {
      enable = true;

      # NixOS `programs.niri` already sets up xdg-desktop-portal system-wide,
      # so don't install a second, user-level portal config on top of it.
      portalPackage = null;

      # Prepend `include "<niri>/resources/default-config.kdl"` to the generated
      # file. Merges, so the settings below are layered on top of upstream's.
      enableDefaultConfig = true;

      settings = {
        # ─── GPU wiring ──────────────────────────────────────────────────────
        # The compositor must render on the iGPU: a mixed atomic commit across
        # card0/card1 hard-freezes this machine. Hardware cursor planes are also
        # unreliable across the mixed GPU pair.
        environment = {
          WLR_DRM_DEVICES = "/dev/dri/card1";
          __GLX_VENDOR_LIBRARY_NAME = "mesa";
          LIBVA_DRIVER_NAME = "radeonsi";
        };

        debug.disable-cursor-plane = { };

        # Pointer. The theme name has to match the fontconfig rule in gtk.nix and
        # the package in desktop.nix.
        cursor = {
          xcursor-theme = "Bibata-Modern-Ice";
          xcursor-size = 24;
        };

        # ─── Chrome ───────────────────────────────────────────────────────────
        layout.focus-ring = {
          width = 2;
          active-color = "#f9e2af";
          inactive-color = "#7c6f64";
        };

        # ─── Blur ────────────────────────────────────────────────────────────
        blur = {
          passes = 3;
          offset = 4;
          noise = 0.015;
          saturation = 1.7;
        };

        # ─── Transparency & Rules ─────────────────────────────────────────────
        _children = [
          {
            window-rule = {
              geometry-corner-radius = 10;
              clip-to-geometry = true;
            };
          }

          {
            window-rule = {
              match._props.is-focused = true;
              opacity = 0.8;
              background-effect.blur = true;
              draw-border-with-background = false;
            };
          }
          {
            window-rule = {
              match._props.is-focused = false;
              opacity = 0.9;
              background-effect.blur = false;
              draw-border-with-background = false;
            };
          }

          # ─── Panel ──────────────────────────────────────────────────────────
          {
            output = {
              _args = [ "eDP-1" ];
              mode = "1920x1080@144";
              scale = 1.2;
            };
          }

          # ─── Autostart ──────────────────────────────────────────────────────
          { spawn-at-startup = [ "gnome-keyring-daemon" "--start" "--components=secrets,pkcs11" ]; }
          { spawn-at-startup = [ "bash" "-c" "wl-paste --type text --watch cliphist store" ]; }
          { spawn-at-startup = [ "bash" "-c" "wl-paste --type image --watch cliphist store" ]; }
          { spawn-at-startup = [ "systemctl" "--user" "enable" "--now" "easyeffects" ]; }
          { spawn-at-startup = [ "serpantinumd" "start" ]; }

          # ─── Keybind overrides ──────────────────────────────────────────────
          {
            binds = {
              "Mod+Return" = {
                spawn = [ (lib.getExe pkgs.kitty) ];
              };
              "Mod+E" = {
                spawn = [ (lib.getExe pkgs.nautilus) ];
              };
              "Mod+A" = {
                spawn = [
                  "emacsclient"
                  "-c"
                  "-a"
                  ""
                ];
              };
            };
          }
        ];
      };
    };
  };
}
