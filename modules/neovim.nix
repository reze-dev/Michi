{ ... }:

{
  programs.nvf = {
    enable = true;
    defaultEditor = true;

    settings = {
      imports = [
        ../nvf/nvf.nix
      ];
    };
  };
}
