{ ... }:

{
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Removable media. GNOME used to pull gvfs/udisks2 in behind
  # services.desktopManager.gnome, so they went away with it. gvfs brings its
  # own DBus-activated volume monitors (udisks2, mtp, gphoto2, afc, goa) as user
  # units via systemd.packages, so USB drives automount under /run/media/$USER
  # with no extra wiring. udisks2, fuse and the MTP udev rules come along.
  services.gvfs.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;
}
