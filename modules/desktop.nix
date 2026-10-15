{ pkgs, lib, ... }:

let
  # Vanilla compositor configs, generated here so they are reproducible and
  # version-controlled. Symlinked into /home/reze/.config at activation.
  hyprlandConf = pkgs.writeText "hyprland.conf" ''
    # ─── Monitor ────────────────────────────────────────────────────────────
    # eDP-1 is the internal panel (1920x1080@144, 1.25 scale). It is wired to
    # the AMD iGPU (card1); the RTX 1650 Ti (card0) drives no outputs.
    monitor = eDP-1, 1920x1080@144, 0x0, 1.25

    # ─── NVIDIA / hybrid GPU ────────────────────────────────────────────────
    # The compositor must render on the iGPU: a mixed atomic commit across
    # card0/card1 hard-freezes this machine. Hyprland reads env from its own
    # config, this is the value that actually decides the render device.
    env = AQ_DRM_DEVICES,/dev/dri/card1
    env = __GLX_VENDOR_LIBRARY_NAME,mesa
    env = LIBVA_DRIVER_NAME,radeonsi

    # Hardware cursor planes are unreliable across a mixed GPU pair (Niri needs
    # debug{disable-cursor-plane} for the same reason). Composite in software.
    cursor {
        no_hardware_cursors = true
    }

    # ─── Autostart ──────────────────────────────────────────────────────────
    exec-once = gnome-keyring-daemon --start --components=secrets,pkcs11
    exec-once = mako
    exec-once = ${pkgs.gnome.gvfs}/libexec/gvfs-udisks2-volume-monitor

    # ─── Variables ──────────────────────────────────────────────────────────
    $terminal = ${pkgs.kitty}/bin/kitty
    $fileManager = ${pkgs.nautilus}/bin/nautilus
    $menu = ${pkgs.fuzzel}/bin/fuzzel

    # ─── Environment ────────────────────────────────────────────────────────
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = XDG_SESSION_TYPE,wayland
    env = MOZ_ENABLE_WAYLAND,1
    env = NIXOS_OZONE_WL,1

    # ─── Look ───────────────────────────────────────────────────────────────
    general {
        gaps_in = 4
        gaps_out = 8
        border_size = 2
        col.active_border = rgba(cdd6f4ee) rgba(89b4faee) 45deg
        col.inactive_border = rgba(595959aa)
        resize_on_border = true
        allow_tearing = false
        layout = dwindle
    }

    decoration {
        rounding = 8

        blur {
            enabled = true
            size = 3
            passes = 1
        }

        shadow {
            enabled = true
            range = 12
            render_power = 2
            color = rgba(00000044)
        }
    }

    animations {
        enabled = true
        bezier = easeOutQuint, 0.23, 1, 0.32, 1
        animation = windows, 1, 4, easeOutQuint
        animation = windowsOut, 1, 4, default, popin 80%
        animation = fade, 1, 4, default
        animation = workspaces, 1, 3, default
    }

    dwindle {
        pseudotile = true
        preserve_split = true
    }

    # ─── Input ──────────────────────────────────────────────────────────────
    input {
        kb_layout = us
        follow_mouse = 1
        touchpad {
            natural_scroll = true
            disable_while_typing = true
        }
    }

    gestures {
        workspace_swipe = true
    }

    misc {
        force_default_wallpaper = -1
        disable_hyprland_logo = true
    }

    # ─── Keybinds ───────────────────────────────────────────────────────────
    bind = SUPER, Return, exec, $terminal
    bind = SUPER, D, exec, $menu
    bind = SUPER, E, exec, $fileManager
    bind = SUPER, Q, killactive,
    bind = SUPER SHIFT, Q, exit,
    bind = SUPER, V, togglefloating,
    bind = SUPER, F, fullscreen,
    bind = SUPER, P, pseudo,
    bind = SUPER, J, togglesplit,
    bind = SUPER, left, movefocus, l
    bind = SUPER, right, movefocus, r
    bind = SUPER, up, movefocus, u
    bind = SUPER, down, movefocus, d
    bind = SUPER SHIFT, left, movewindow, l
    bind = SUPER SHIFT, right, movewindow, r
    bind = SUPER SHIFT, up, movewindow, u
    bind = SUPER SHIFT, down, movewindow, d
    bind = SUPER, bracketleft, workspace, e-1
    bind = SUPER, bracketright, workspace, e+1
    bind = SUPER SHIFT, bracketleft, movetoworkspace, e-1
    bind = SUPER SHIFT, bracketright, movetoworkspace, e+1
    bind = SUPER, mouse_down, workspace, e+1
    bind = SUPER, mouse_up, workspace, e-1
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10
    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10
  '';

  niriConf = pkgs.writeText "niri-config.kdl" ''
    // ─── Output ──────────────────────────────────────────────────────────────
    // eDP-1 is the internal panel (1920x1080@144, 1.25 scale), wired to the AMD
    // iGPU (card1). The RTX 1650 Ti (card0) drives no outputs.
    output "eDP-1" {
        mode "1920x1080@144"
        scale 1.25
    }

    // ─── Environment ─────────────────────────────────────────────────────────
    // The compositor must render on the iGPU: a mixed atomic commit across
    // card0/card1 hard-freezes this machine.
    environment {
        AQ_DRM_DEVICES "/dev/dri/card1"
        WLR_DRM_DEVICES "/dev/dri/card1"
        __GLX_VENDOR_LIBRARY_NAME "mesa"
        LIBVA_DRIVER_NAME "radeonsi"
    }

    // ─── Input ───────────────────────────────────────────────────────────────
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
            dwt
        }
    }

    // ─── Cursor ──────────────────────────────────────────────────────────────
    cursor {
        xcursor-theme "Bibata-Modern-Ice"
        xcursor-size 24
    }

    // Hardware cursor planes are unreliable across a mixed GPU pair; composite
    // the cursor instead.
    debug {
        disable-cursor-plane
    }

    // ─── Layout ──────────────────────────────────────────────────────────────
    layout {
        gaps 16

        center-focused-column "never"
        always-center-single-column

        preset-column-widths {
            proportion 0.33333;
            proportion 0.5;
            proportion 0.66667;
        }

        border {
            on
            width 4
        }

        focus-ring {
            off
        }
    }

    prefer-no-csd

    hotkey-overlay {
        skip-at-startup
    }

    // ─── Startup ─────────────────────────────────────────────────────────────
    spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets,pkcs11"
    spawn-at-startup "mako"
    spawn-at-startup "${pkgs.gnome.gvfs}/libexec/gvfs-udisks2-volume-monitor"

    // ─── Keybinds ────────────────────────────────────────────────────────────
    binds {
        Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
        Mod+D { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
        Mod+E { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }
        Mod+V { toggle-window-floating; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }

        Mod+BracketLeft  { focus-workspace-down; }
        Mod+BracketRight { focus-workspace-up; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Print { screenshot; }
        Mod+Print { screenshot-screen; }
        Shift+Print { screenshot-window; }
    }
  '';
in
{
  # ─── Display manager ─────────────────────────────────────────────────────
  # Ryoku used to own this (SDDM via mkDefault). Declared explicitly now so
  # it no longer depends on the Ryoku flake. Both compositor sessions show up
  # in the greeter; Niri is preselected.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  # ─── Compositors (vanilla, from nixpkgs) ─────────────────────────────────
  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
  };

  programs.niri = {
    enable = true;
    # Portal needs one of gnome/gtk for the FileChooser; gnome also brings the
    # keyring Secret portal we were getting from Ryoku.
    useNautilus = true;
  };

  # Ryoku shipped these; without it they have to be explicit. kitty (terminal),
  # fuzzel (launcher) and mako (notifications) are what the generated configs
  # above actually invoke.
  environment.systemPackages = with pkgs; [
    kitty
    fuzzel
    mako
    nautilus
    wl-clipboard
    brightnessctl
    playerctl
  ];

  # ─── Generated configs ───────────────────────────────────────────────────
  # Replaces the Ryoku-written ~/.config/{hypr,niri} trees. Store symlinks, so
  # an edit here is the only way to change them.
  system.activationScripts.compositor-configs = {
    text = ''
      if [ -d /home/reze ]; then
        mkdir -p /home/reze/.config/hypr /home/reze/.config/niri
        ln -sfn ${hyprlandConf} /home/reze/.config/hypr/hyprland.conf
        ln -sfn ${niriConf} /home/reze/.config/niri/config.kdl
        chown -h reze:users /home/reze/.config/hypr /home/reze/.config/hypr/hyprland.conf
        chown -h reze:users /home/reze/.config/niri /home/reze/.config/niri/config.kdl
      fi
    '';
    deps = [ "users" ];
  };
}
