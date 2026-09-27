{
  description = "tools for working with our writeups";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = {
    nixpkgs,
    self,
    ...
  } @ input: let
    we = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${we};
    lib = nixpkgs.lib;
  in {
    devShells.${we}.default = pkgs.mkShell {
      packages = with pkgs; [
        typst
        typstyle
        tinymist
      ];
    };
  };
}
