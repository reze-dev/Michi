# Fish, the shell. A home-manager module, imported by home.nix.
#
# Enabling `programs.fish` puts fish on PATH, which is also what makes the
# `shell = "fish"` in kitty.nix (and the shell integrations there) actually
# work — fish was not installed anywhere before this.
{ pkgs, ... }:
{
  # Search and pager tooling. fd and ripgrep back the fzf widgets below.
  home.packages = with pkgs; [
    fd
    ripgrep
    # Used by fzf's Alt+C directory preview.
    eza
  ];

  # ─── Colourised man pages ────────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  # ─── fzf ─────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";

    # Ctrl-T: files, with a bat preview.
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

    # NOTE: `fish_config theme choose` downloads the theme from the fish-shell
    # themes repo on the first run of each shell, so it needs the network and
    # will fail on a cold/offline start. Home-manager has no fish `themes`
    # option, so there is no nix-managed alternative in-tree; if that becomes
    # annoying the theme can be vendored into xdg.configFile instead.
    interactiveShellInit = ''
      set -g fish_greeting
      fish_config theme choose "Rosé Pine Auto"

      # Keep sponge from deleting failed commands immediately until session ends
      set -g sponge_purge_only_on_exit true
    '';

    functions = {
      # Only takes effect once starship is installed *and* `starship init fish`
      # is added to interactiveShellInit — neither is true yet.
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
      hms = "home-manager switch --flake .";
      ns = "nix-shell -p";
    };
  };
}