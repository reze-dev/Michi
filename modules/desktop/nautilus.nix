{ ... }:
{
  # ─── Nautilus (System-level) ───────────────────────────────────────────────
  flake.nixosModules.nautilus = { pkgs, ... }: {
    # Trash, MTP devices (phones/cameras), and SMB/FTP network mounts all
    # rely on gvfs running as a session D-Bus service.
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      nautilus
      # Spacebar quick-preview
      sushi
      # Right-click → Extract / Compress
      file-roller
      # Video-file thumbnails in the icon view
      ffmpegthumbnailer
      # "Open terminal here" context-menu entry (terminal configured via
      # dconf in the home module below)
      nautilus-open-any-terminal
    ];

    # Nautilus discovers Python-based extensions through this merged path.
    environment.pathsToLink = [
      "/share/nautilus-python/extensions"
    ];
  };

  # ─── Nautilus (User-level) ─────────────────────────────────────────────────
  flake.homeModules.nautilus = { ... }: {
    dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal" = {
      terminal = "kitty";
    };
  };
}
