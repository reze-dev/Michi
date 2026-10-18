# Kitty, the terminal. A home-manager module, imported by home.nix.
#
# The binary itself is already in desktop.nix's systemPackages; enabling this
# module installs the same store path into the home profile and manages
# ~/.config/kitty through `programs.kitty`.
{
  programs.kitty = {
    enable = true;

    # Maple Mono ships one family per weight, exactly like the Victor Mono Nerd
    # Font it replaced, so the heavier face is selected by name:
    #
    #   fc-match "Maple Mono SemiBold" -> MapleMono-SemiBold.ttf "SemiBold"
    #
    # Alternatives: "Maple Mono Medium", "Maple Mono Light", or plain
    # "Maple Mono" for Regular. Bold text still uses the family's own Bold
    # face.
    #
    # Note `font.name` cannot carry a style: home-manager's font submodule
    # requires `name`, so an extra font_family in extraConfig would come
    # *after* this one and never win.
    font = {
      name = "Maple Mono SemiBold";
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