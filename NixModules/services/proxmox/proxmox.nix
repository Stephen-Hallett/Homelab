{ pkgs, lib, config, ... }: {
  imports = [./vms/caddy.nix];

  options = {
    nix-config.proxmox.enable = lib.mkEnableOption "enable proxmox";
  };

  config = lib.mkIf config.nix-config.proxmox.enable {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.72";
    };
    networking.bridges.vmbr0.interfaces = [ "enp34s0" ];
    networking.interfaces.vmbr0.ipv4.addresses = [{
      address = "192.168.1.72";
      prefixLength = 16;
    }];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];

    networking.firewall.allowedTCPPorts = [ 8006 ];
  };
}
