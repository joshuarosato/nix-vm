{
  description = "Minimal Flake-based NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      nix-index-database,
      treefmt-nix,
      ...
    }@inputs:
    let
      # Define the system architecture once, so we don't have to repeat it
      system = "x86_64-linux";

      # Define pkgs here so it can be used by both nixosSystem and the formatter
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.default
          { programs.nix-index-database.comma.enable = true; }
        ];
      };

      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix"; # Tells treefmt where the root of the project is
        programs.nixfmt.enable = true; # Enables the official Nix formatter
      };
    };
}
