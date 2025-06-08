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

    # NixOS Anywhere
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, proxmox-nixos, disko, sops-nix, ...
    }@inputs:
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

        # For first time running nixos-anywhere run the following to generate a config
        #nix run nixpkgs#nixos-anywhere -- --flake /home/stephen/Homelab#vm --generate-hardware-config nixos-generate-config ./Hosts/VM/hardware-configuration.nix root@IP_ADDRESS
        vm = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            proxmox-nixos.nixosModules.proxmox-ve
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./Hosts/VM/configuration.nix
          ];
        };

        # sudo nixos-rebuild switch --target-host stephen@192.168.1.79 --use-remote-sudo --impure --flake ~/Homelab#caddy
        caddy = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            proxmox-nixos.nixosModules.proxmox-ve
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./NixModules/services/proxmox/vms/caddy/configuration.nix
          ];
        };

        testvm = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            proxmox-nixos.nixosModules.proxmox-ve
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./NixModules/services/proxmox/vms/testvm/configuration.nix
          ];
        };
      };
    };
}

