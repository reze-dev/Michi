# Kitty, the terminal. A home-manager module, imported by home.nix.
#
# The binary itself is already in desktop.nix's systemPackages; enabling this
# module installs the same store path into the home profile and manages
# ~/.config/kitty through `programs.kitty`.
{
  programs.kitty = {
    enable = true;

    # Family name is "VictorMono Nerd Font" — no space between "Victor" and
    # "Mono". That is what nerd-fonts.victor-mono registers (alias
    # "VictorMono NF"), so a spaced-out name silently falls back to another
    # font. Size is in points.
    font = {
      name = "VictorMono Nerd Font";
      size = 13;
    };

    # A kitty-themes theme name, without the .conf suffix.
    themeFile = "rose-pine";

    shellIntegration = {
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    settings = {
      background_opacity = 0.85;
      confirm_os_window_close = 0;
      shell = "fish";
    };

    # No font_family line here on purpose: kitty treats `font_family` as
    # additive, so repeating the family already set via `font.name` puts a
    # duplicate into the fallback list. Style selection is better done through
    # `font.features` if a specific weight is wanted.
    extraConfig = ''
      hide_window_decorations yes
    '';
  };
}