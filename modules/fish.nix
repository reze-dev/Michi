# Fish, the shell. A home-manager module, imported by home.nix.
#
# Enabling `programs.fish` puts fish on PATH, which is also what makes the
# `shell = "fish"` in kitty.nix (and the shell integrations there) actually
# work — fish was not installed anywhere before this.
{ config, pkgs, ... }:

# Rosé Pine's official fish theme, pinned by rev. Vendored rather than fetched
# at runtime: fish reads themes from ~/.config/fish/themes/*.theme (per
# fish-doc), so dropping the file there lets `fish_config theme choose` find
# it locally instead of downloading on every shell start.
let
  rose-pine-fish = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "fish";
    rev = "127a990e5ad4688118c950123787fb0686afa4c8";
    sha256 = "3heI6nhItw5WfKGQT1FRQKfv+lONyn+DzwYjYqJjzLE=";
  };
in
{
  xdg.configFile."fish/themes/Rosé Pine Auto.theme".source =
    "${rose-pine-fish}/themes/Rosé Pine Auto.theme";

  # ─── Search tooling ──────────────────────────────────────────────────────
  # fd and ripgrep back the fzf widgets below. eza comes from programs.eza.
  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  # ─── Environment ─────────────────────────────────────────────────────────
  home.sessionVariables = {
    COLORTERM = "truecolor";
    # Empty log format keeps direnv silent instead of printing a diff every
    # time an environment loads.
    DIRENV_LOG_FORMAT = "";
    GOPATH = "${config.home.homeDirectory}/go";
    # col comes from util-linux, which is already in the system profile.
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.config/emacs/bin"
    "$HOME/.local/share/coursier/bin"
  ];

  # ─── Colourised man pages ────────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  # ─── eza ─────────────────────────────────────────────────────────────────
  # enableFishIntegration sets up ls/ll/la/tree aliases.
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
  };

  # ─── fzf ─────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";

    # Ctrl-T: files, with a bat preview. The flat fileWidgetCommand /
    # fileWidgetOptions names were renamed upstream; they now nest.
    fileWidget = {
      command = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      options = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    # Alt-C: directories, with an eza tree preview.
    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [
        "--preview 'eza --tree --color=always --icons=always {} | head -200'"
      ];
    };
  };

  # ─── zoxide ──────────────────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # ─── direnv ──────────────────────────────────────────────────────────────
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    # Caches nix environments so loading them is instant.
    nix-direnv.enable = true;
  };

  # ─── starship ────────────────────────────────────────────────────────────
  # enableTransience is what makes the prompt disappear during long-running
  # commands, and what calls starship_transient_prompt_func below.
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
  };

  # ─── nix-index ───────────────────────────────────────────────────────────
  # Tells you which nixpkgs attribute provides a command you just mistyped.
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  # ─── Fish ────────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;

    plugins = with pkgs.fishPlugins; [
      { name = "autopair"; src = autopair.src; }
      { name = "sponge"; src = sponge.src; }
      { name = "puffer"; src = puffer.src; }
      { name = "done"; src = done.src; }
    ];

    interactiveShellInit = ''
      # Disable greeting in memory (avoids disk writes on every startup)
      set -g fish_greeting

      # Resolved from the vendored file above, so no network needed.
      fish_config theme choose "Rosé Pine Auto"

      # Keep sponge from deleting failed commands immediately until session ends
      set -g sponge_purge_only_on_exit true
    '';

    functions = {
      # Called by starship's transient prompt (programs.starship.enableTransience).
      starship_transient_prompt_func = "starship module character";

      # mkdir and cd in one step.
      mkcd = ''
        mkdir -p $argv[1]; and cd $argv[1]
      '';

      # `bak filename.txt` -> `filename.txt.bak`
      bak = ''
        cp -r $argv[1] "$argv[1].bak"
      '';
    };

    shellAliases = {
      cat = "bat";
      # Custom eza flags not covered by programs.eza.
      lo = "eza -l -o --icons=auto";
      # NOTE: tmux is not installed on this system, so this alias only works
      # once it is. Use `command tmux` if you would rather it stay quiet.
      tmux = "tmux -u";
    };

    shellAbbrs = {
      v = "nvim";
      vim = "nvim";

      # Git
      g = "git";
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";

      # Nix
      nrs = "sudo nixos-rebuild switch --flake .";
      # NOTE: Home Manager is a NixOS module here, so standalone
      # `home-manager switch` does not apply — `nrs` is the one that works.
      hms = "home-manager switch --flake .";
      ns = "nix-shell -p";
    };
  };
}