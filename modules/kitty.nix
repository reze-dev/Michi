# Kitty, the terminal. A home-manager module, imported by home.nix.
#
# The binary itself is already in desktop.nix's systemPackages; enabling this
# module installs the same store path into the home profile and manages
# ~/.config/kitty through `programs.kitty`.
{
  programs.kitty = {
    enable = true;

    # Plain "Maple Mono" resolves to MapleMono-Regular.ttf. Its heavier weights
    # are available as their own families if you want them later —
    # "Maple Mono Medium", "Maple Mono SemiBold", "Maple Mono Bold" — but the
    # default weight is fine here; only Victor Mono's Regular was thin enough
    # to warrant bumping.
    #
    # Note `font.name` cannot carry a style: home-manager's font submodule
    # requires `name`, so an extra font_family in extraConfig would come
    # *after* this one and never win.
    font = {
      name = "Maple Mono";
      size = 14;
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