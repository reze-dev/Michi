{ ... }:
{
  flake.homeModules.gtk = # GTK theming. A home-manager module, imported by home.nix.
#
# Nautilus deliberately is not added here — nautilus.nix owns it and its
# extensions as a separate submodule.
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

  # Written straight into ~/.config/fontconfig/conf.d/ rather than through
  # home-manager's `fontconfig` module, which is not enabled here — turning it
  # on would make home-manager own $FONTCONFIG_PATH and shadow the system
  # fontconfig that NixOS sets up in base.nix. fontconfig reads
  # $XDG_CONFIG_HOME/fontconfig/conf.d/ on its own, so this works without that.
  #
  # The theme files themselves come from desktop.nix's systemPackages entry —
  # fonts.packages would not do, since cursor lookup walks XDG_DATA_DIRS/icons
  # rather than fontconfig <dir> entries.
  xdg.configFile."fontconfig/conf.d/60-bibata-cursor.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <match target="pattern">
        <test qual="any" name="family">
          <string>cursor</string>
        </test>
        <edit name="family" mode="assign" binding="same">
          <string>Bibata-Modern-Ice</string>
        </edit>
      </match>
    </fontconfig>
  '';
};
}
