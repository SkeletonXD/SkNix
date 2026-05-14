{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.SKNix = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
    nixosConfigurations.default = self.nixosConfigurations.SKNix;
  };
}
