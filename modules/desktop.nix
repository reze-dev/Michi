{ pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Removable media. GNOME used to pull gvfs/udisks2 in behind
  # services.desktopManager.gnome, so they went away with it. gvfs enables
  # udisks2, fuse and its own dbus/systemd units, but nothing starts the
  # session-side volume monitor (niri runs no XDG autostart entries), which is
  # the half that actually automounts a USB drive under /run/media/$USER. Runs
  # per user after the graphical session so it rides the seat/DBus env.
  services.gvfs.enable = true;

  systemd.user.services.gvfs-udisks2-volume-monitor = {
    description = "GVfs UDisks2 volume monitor (removable media automount)";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.gnome.gvfs}/libexec/gvfs-udisks2-volume-monitor";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;
}
