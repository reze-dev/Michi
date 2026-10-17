{ pkgs, lib, ... }:

# Niri, the session compositor. A home-manager module, imported by home.nix.
#
# Based on niri's own default config (`enableDefaultConfig`), so the whole
# layout/input/binds/animation surface comes from upstream and stays current
# across `nix flake update`. The `settings` below is only what upstream's
# default cannot know: this machine's panel and GPU wiring, the session
# autostarts, and the blur/transparency treatment.
#
# The system-level half lives in desktop.nix as `programs.niri` — that is what
# registers the session with SDDM and sets up xdg-desktop-portal.
#
# Generated KDL is alphabetically ordered and carries no comments, so the
# rationale for these overrides lives here rather than in the .kdl.
{
  wayland.windowManager.niri = {
    enable = true;

    # NixOS `programs.niri` already sets up xdg-desktop-portal system-wide
    # (including the gnome/gtk FileChooser and the keyring Secret portal), so
    # don't install a second, user-level portal config on top of it.
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

      # ─── Blur ────────────────────────────────────────────────────────────
      # Global blur tuning. niri's defaults are passes 3 / offset 3 / noise 0.02
      # / saturation 1.5; bumped slightly for a softer, less noisy result.
      # Windows still have to opt in via background-effect below.
      blur = {
        passes = 3;
        offset = 4;
        noise = 0.015;
        saturation = 1.7;
      };

      # ─── Transparency ─────────────────────────────────────────────────────
      # Two rules instead of one catch-all, keyed on focus state: the focused
      # pane is more transparent (0.8) so the wallpaper shows through most
      # where you are actually working, and unfocused panes sit back at 0.9 so
      # they stay legible in the background.
      #
      # `background-effect { blur true }` is what turns blur on per-window; the
      # global `blur` block above only sets the parameters.
      _children = [
        {
          window-rule = {
            # _props, not a plain attr: `match` takes its conditions as
            # properties (`match is-focused=true`), not child nodes.
            match._props.is-focused = true;
            opacity = 0.8;
            background-effect.blur = true;
          };
        }
        {
          window-rule = {
            # _props, not a plain attr: `match` takes its conditions as
            # properties (`match is-focused=false`), not child nodes.
            match._props.is-focused = false;
            opacity = 0.9;
            background-effect.blur = true;
          };
        }

        # ─── Panel ──────────────────────────────────────────────────────────
        # eDP-1 is the internal panel (1920x1080@144, 1.25), wired to the AMD
        # iGPU (card1). The RTX 1650 Ti (card0) drives no outputs.
        {
          output = {
            _args = [ "eDP-1" ];
            mode = "1920x1080@144";
            scale = 1.25;
          };
        }

        # ─── Autostart ──────────────────────────────────────────────────────
        # `output`, `spawn-at-startup`, `window-rule` and `binds` all appear
        # more than once across here and upstream's default, so they go in
        # _children: Nix attrsets cannot hold duplicate keys.
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
        # awww 0.12 has no config file; starting the daemon restores the last
        # wallpaper from its cache, and `awww img` swaps it at runtime.
        { spawn-at-startup = [ (lib.getExe' pkgs.awww "awww-daemon") ]; }

        # ─── Keybind overrides ──────────────────────────────────────────────
        # Upstream's default binds Mod+D to fuzzel, Mod+Q to close-window and
        # the arrow keys to focus/move columns, so those are left alone —
        # niri rejects duplicate keybinds outright ("duplicate keybind later
        # defined here"). These two keys are unbound in the default, which is
        # how kitty and nautilus keep their old shortcuts.
        {
          binds = {
            "Mod+Return" = { spawn = [ (lib.getExe pkgs.kitty) ]; };
            "Mod+E" = { spawn = [ (lib.getExe pkgs.nautilus) ]; };
          };
        }
      ];
    };
  };
}