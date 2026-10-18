# Removable storage: USB drives and Android phones over MTP.
{ pkgs, ... }:

{
  # One switch covers both: gvfs enables udisks2 (the block-device layer) and
  # pulls in libmtp's udev rules, which is what makes an Android phone show up
  # as an MTP device. Nautilus is already in the system profile, so the phone
  # appears there and in the GTK file chooser.
  #
  # Note the phone itself has to be set to File transfer / MTP mode — in
  # Charging-only mode there is nothing for udisks2 to see.
  services.gvfs.enable = true;

  # udiskie-mount -a mounts every handleable device as it appears, which is
  # the automount behaviour. This is the headless half of udiskie, so it needs
  # no status-notifier host — see the tray note below.
  #
  # Mountpoints land under /run/media/$USER, which is tmpfs-backed and so
  # self-cleaning. services.udisks2.mountOnMedia (which would use /media and
  # need its own stale-mountpoint cleanup) is deliberately left off.
  systemd.user.services.udiskie-mount = {
    description = "udiskie automounter";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie-mount -a";
      Restart = "always";
      RestartSec = 2;
    };
  };

  # If a tray icon is wanted later, add `udiskie` (not udiskie-mount — running
  # both means two things racing to mount the same device):
  #
  #   systemd.user.services.udiskie = {
  #     description = "udiskie tray";
  #     wantedBy = [ "graphical-session.target" ];
  #     serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie";
  #   };
  #
  # udiskie is an AppIndicator client, so something has to implement the
  # StatusNotifier protocol or the icon silently never appears. There is no
  # such host running here.
}