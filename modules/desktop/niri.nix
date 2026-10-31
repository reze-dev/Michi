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
              # Terminal (your kitty — kept)
              "Mod+Return" = {
                spawn = [ (lib.getExe pkgs.kitty) ];
              };

              # File manager (kept — direct access)
              "Mod+E" = {
                spawn = [ (lib.getExe pkgs.nautilus) ];
              };

              # Shell modules
              "Mod+D" = {
                spawn = [ "serpantinum" "msg" "toggle" "launcher" ];
              };
              "Mod+B" = {
                spawn = [ "serpantinum" "msg" "toggle" "system" ];
              };
              "Mod+C" = {
                spawn = [ "serpantinum" "msg" "toggle" "clipboard" ];
              };
              "Mod+M" = {
                spawn = [ "serpantinum" "msg" "toggle" "music" ];
              };
              "Mod+W" = {
                spawn = [ "serpantinum" "msg" "toggle" "wallpaper" ];
              };
              "Mod+S" = {
                spawn = [ "serpantinum" "msg" "toggle" "calendar" ];
              };
              "Mod+N" = {
                spawn = [ "serpantinum" "msg" "toggle" "network" ];
              };
              "Mod+V" = {
                spawn = [ "serpantinum" "msg" "toggle" "volume" ];
              };
              "Mod+H" = {
                spawn = [ "serpantinum" "msg" "toggle" "settings" ];
              };
              "Mod+A" = {
                spawn = [ "serpantinum" "msg" "toggle" "autohide" ];
              };

              # Workspace routing (through serpantinum)
              "Mod+1" = {
                spawn = [ "serpantinum" "msg" "workspace" "1" ];
              };
              "Mod+2" = {
                spawn = [ "serpantinum" "msg" "workspace" "2" ];
              };
              "Mod+3" = {
                spawn = [ "serpantinum" "msg" "workspace" "3" ];
              };
              "Mod+4" = {
                spawn = [ "serpantinum" "msg" "workspace" "4" ];
              };
              "Mod+5" = {
                spawn = [ "serpantinum" "msg" "workspace" "5" ];
              };
              "Mod+6" = {
                spawn = [ "serpantinum" "msg" "workspace" "6" ];
              };
              "Mod+7" = {
                spawn = [ "serpantinum" "msg" "workspace" "7" ];
              };
              "Mod+8" = {
                spawn = [ "serpantinum" "msg" "workspace" "8" ];
              };
              "Mod+9" = {
                spawn = [ "serpantinum" "msg" "workspace" "9" ];
              };
              "Mod+Shift+1" = {
                spawn = [ "serpantinum" "msg" "workspace" "1" "move" ];
              };
              "Mod+Shift+2" = {
                spawn = [ "serpantinum" "msg" "workspace" "2" "move" ];
              };
              "Mod+Shift+3" = {
                spawn = [ "serpantinum" "msg" "workspace" "3" "move" ];
              };
              "Mod+Shift+4" = {
                spawn = [ "serpantinum" "msg" "workspace" "4" "move" ];
              };
              "Mod+Shift+5" = {
                spawn = [ "serpantinum" "msg" "workspace" "5" "move" ];
              };
              "Mod+Shift+6" = {
                spawn = [ "serpantinum" "msg" "workspace" "6" "move" ];
              };
              "Mod+Shift+7" = {
                spawn = [ "serpantinum" "msg" "workspace" "7" "move" ];
              };
              "Mod+Shift+8" = {
                spawn = [ "serpantinum" "msg" "workspace" "8" "move" ];
              };
              "Mod+Shift+9" = {
                spawn = [ "serpantinum" "msg" "workspace" "9" "move" ];
              };

              # Utilities
              "Mod+L" = {
                spawn = [ "serpantinum" "lock" ];
              };
              "Mod+R" = {
                spawn = [ "serpantinum" "reload" ];
              };
              "Print" = {
                spawn = [ "serpantinum" "screenshot" ];
              };

              # Brightness / volume keys
              "XF86MonBrightnessDown" = {
                spawn = [ "serpantinum" "msg" "brightness" "lower" ];
              };
              "XF86MonBrightnessUp" = {
                spawn = [ "serpantinum" "msg" "brightness" "upper" ];
              };
              "XF86AudioLowerVolume" = {
                spawn = [ "serpantinum" "msg" "volume" "lower" ];
              };
              "XF86AudioRaiseVolume" = {
                spawn = [ "serpantinum" "msg" "volume" "raise" ];
              };
              "XF86AudioMute" = {
                spawn = [ "serpantinum" "msg" "volume" "mute" ];
              };
            };
          }
        ];
      };
    };
  };
}
