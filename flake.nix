{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elyprism = {
      url = "github:ElyPrismLauncher/Launcher";
      inputs.nixpkgs.follows =  "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak,  ... }: {
    nixosConfigurations.SKNix = nixpkgs.lib.nixosSystem {
      specialArgs = { inputs=self.inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        ./hardware-configuration.nix
        ./configuration.nix
        ./skeletonxd.nix
        ./miraruen.nix
      ];
    };
    nixosConfigurations.default = self.nixosConfigurations.SKNix;
  };
}
