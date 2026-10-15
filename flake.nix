{
  description = "reze's NixOS configuration";

  inputs = {
    # Host package set: flows with nixos-unstable. Everything in this repo
    # (kernel, mesa via hardware.graphics, devtools, nvf, fonts) builds from
    # this input, so it moves at unstable's pace.
    #
    # Caveat: Ryoku builds its own packages from a *separate* locked nixpkgs
    # (ryokuPackagesNixpkgs, inside the Ryoku flake). When this input drifts
    # far ahead of that lock you end up with two glibcs in one system closure,
    # which has been observed to break the Wayland compositors. If the desktop
    # ever freezes at login, align this rev with Ryoku's:
    #   nix flake metadata --json | jq -r '.locks.nodes |
    #     {host: .nixpkgs.locked.rev, ryoku: .ryokuPackagesNixpkgs.locked.rev}'
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pinned to an exact rev (0.73.6-beta.20, codename Onogoro). Tracked on
    # `main` before, which meant every `nix flake lock`/`update` silently
    # dragged Ryoku forward with it. Bump this deliberately; Ryoku's own
    # package universe (ryokuPackagesNixpkgs) is locked inside that flake and
    # independent of the host nixpkgs below.
    ryoku.url = "github:aethctl/Ryoku-on-NixOS/d98a606b3b4b82a856108e9daa161276c54036b9";
    # Era-matched to the pinned nixpkgs (nvf master now needs pnpm_12 which
    # does not exist in that rev).
    nvf.url = "github:notashelf/nvf/45ad22485d23";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      ryoku,
      self,
      nixpkgs,
      nvf,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Makima = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ryoku.nixosModules.default
          ./ryoku.nix
          nvf.nixosModules.default
          ./hosts/Makima
        ];
      };
    };
}
