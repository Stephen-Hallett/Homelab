{
  description = "Homelab Nix Configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # NixOS
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-darwin
    , nix-homebrew, proxmox-nixos, ... }@inputs:
    let
      inherit (self) outputs;

      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable { config.allowUnfree = true; };
        inherit inputs personal;
      };

      extraSpecialArgs = {
        pkgs-unstable = import nixpkgs-unstable { config.allowUnfree = true; };
        inherit inputs personal default;
      };

      personal = {
        timeZone = "Pacific/Auckland";
        defaultLocale = "en_NZ.UTF-8";
        city = "Auckland";

        # Used for gitconfig
        gitUser = "Stephen-Hallett";
        gitEmail = "stevohallett@gmail.com";
      };

      default = { user = builtins.getEnv "USER"; };

      mkHomeConfig = machineModule: system:
        home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;
          pkgs = import nixpkgs { inherit system; };

          modules = [
            ./HomeManagerModules
            inputs.nixvim.homeManagerModules.nixvim
            machineModule
          ];
        };
    in {
      homeConfigurations = {
        "root@DietPi" = mkHomeConfig ./Hosts/Core/home.nix "aarch64-linux";
        "pi@raspberrypi" = mkHomeConfig ./Hosts/Core/home.nix "aarch64-linux";
        "stephen@media" = mkHomeConfig ./Hosts/VM/home.nix "aarch64-linux";
        "stephen@homelab" =
          mkHomeConfig ./Hosts/Homelab/home.nix "x86_64-linux";
      };

      nixosConfigurations = {
        homelab = nixpkgs.lib.nixosSystem rec {
          inherit specialArgs;
          modules = [
            proxmox-nixos.nixosModules.proxmox-ve
            ({ lib, pkgs, ... }: {
              nixpkgs.overlays = [ proxmox-nixos.overlays.x86_64-linux ];
            })

            ./Hosts/Homelab/configuration.nix
          ];
        };
      };
    };
}

