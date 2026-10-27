{inputs, ...}: {
  # ─── Secrets (Home Manager) ────────────────────────────────────────────────
  # The encrypted file lives in ./secrets/secrets.yaml. It is decrypted by
  # sops-nix as the user, using an age key that is deliberately kept outside
  # the repository at ~/.config/sops/age/keys.txt.
  #
  # Nothing here puts plaintext key material in the Nix store: sops-nix
  # decrypts into $XDG_RUNTIME_DIR and creates the symlinks below.
  flake.homeModules.secrets = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = ../../secrets/secrets.yaml;

      secrets = {
        ssh_id_ed25519 = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519";
          mode = "0400";
        };

        gpg_private_key = {
          path = "${config.programs.gpg.homedir}/sops-private-key.asc";
          mode = "0400";
        };
      };
    };

    # Public half of the SSH key. This is not a secret and is safe to keep
    # in the repository; it is what you upload to GitHub/GitLab.
    home.file.".ssh/id_ed25519.pub".source = ../../secrets/ssh-public-key.pub;

    home.activation.fixSshDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "$HOME/.ssh" ]; then
        ${pkgs.coreutils}/bin/chmod 700 "$HOME/.ssh"
      fi
    '';

    # Tools for editing and rotating the encrypted file.
    home.packages = [
      pkgs.sops
      pkgs.age
    ];

    # GnuPG is needed both for the import service below and by Git.
    programs.gpg.enable = true;

    # Import the signing key after sops-nix has decrypted it. The guard
    # makes this idempotent across logins and rebuilds.
    systemd.user.services.gpg-import = {
      Unit = {
        Description = "Import the PGP signing key managed by sops-nix";
        After = ["sops-nix.service"];
        Requires = ["sops-nix.service"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "gpg-import-sops-key" ''
          set -euo pipefail

          fpr=4D8CDBE36B014FABADD7318BE300D86785B7C3F4
          homedir=${lib.escapeShellArg (toString config.programs.gpg.homedir)}

          ${pkgs.coreutils}/bin/install -d -m 700 "$homedir"

          if ! ${pkgs.gnupg}/bin/gpg --homedir "$homedir" --batch \
            --list-secret-keys "$fpr" >/dev/null 2>&1; then
            ${pkgs.gnupg}/bin/gpg --homedir "$homedir" --batch \
              --import ${lib.escapeShellArg config.sops.secrets.gpg_private_key.path}
          fi
        ''}";
        RemainAfterExit = true;
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
