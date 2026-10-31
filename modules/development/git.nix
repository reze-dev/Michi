{ ... }: {
  # ─── Git (User-level) ──────────────────────────────────────────────────────
  # Global Git configuration. The signing key is the PGP key managed by
  # modules/secrets/secrets.nix; the gpg-import service makes it available.
  flake.homeModules.git = { ... }: {
    programs.git = {
      enable = true;

      signing = {
        key = "4D8CDBE36B014FABADD7318BE300D86785B7C3F4";
        signByDefault = true;
        format = "openpgp";
      };

      settings = {
        user = {
          name = "reze-dev";
          email = "25588579+reze-dev@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
    };
  };
}
