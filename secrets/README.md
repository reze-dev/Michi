# Secrets

`secrets.yaml` is encrypted with [sops](https://github.com/getsops/sops) and
the age key at `~/.config/sops/age/keys.txt`. The age key is intentionally
outside this repository; back it up somewhere safe (password manager or
offline media). Without it the encrypted file cannot be decrypted.

The repository contains only:

- `secrets.yaml` — encrypted SSH and PGP private keys
- `ssh-public-key.pub` — public SSH key (safe to share/upload)
- `gpg-public.asc` — public PGP key (safe to share/upload)

## Editing

```sh
sops secrets/secrets.yaml
```

This opens the decrypted file in `$EDITOR` and re-encrypts it on save.

## Adding a recipient / rotating the age key

Add the new public age key to `../.sops.yaml`, then:

```sh
sops updatekeys secrets/secrets.yaml
```

## Using the keys

After `nixos-rebuild switch` and a new login:

- `~/.ssh/id_ed25519` is a symlink managed by sops-nix
- the PGP key is imported by the `gpg-import` user service
- `git commit` signs automatically with the PGP key

Check the signing setup with:

```sh
git config --get user.signingkey
git log --show-signature -1
```

Upload `gpg-public.asc` to GitHub (Settings → SSH and GPG keys → New GPG key)
so commits show as verified.

## Backups

Keep copies of:

- `~/.config/sops/age/keys.txt` (required to decrypt this repository)
- the PGP revocation certificate in
  `~/.gnupg/openpgp-revocs.d/4D8CDBE36B014FABADD7318BE300D86785B7C3F4.rev`
