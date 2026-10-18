# GTK theming. A home-manager module, imported by home.nix.
#
# Nautilus deliberately is not added here — desktop.nix already has it in
# systemPackages, and listing it in two places just duplicates the store path.
{ pkgs, ... }:

let
  # Widget theme and icon theme. Both live in yaru-theme; change together or
  # they will drift.
  theme = "Yaru";
in
{
  # The dconf database gtk's settings get written into. dconf.settings is inert
  # without this — dconf.nix guards on `cfg.enable && databases != []`.
  dconf.enable = true;

  gtk = {
    enable = true;

    # No hand-written dconf.settings block is needed: home-manager derives the
    # org/gnome/desktop/interface entries from these two options itself
    # (gtk3.nix maps theme.name -> "gtk-theme", iconTheme.name ->
    # "icon-theme"), so writing them by hand would just duplicate them.
    theme = {
      name = theme;
      package = pkgs.yaru-theme;
    };

    iconTheme = {
      name = theme;
      package = pkgs.yaru-theme;
    };
  };
}