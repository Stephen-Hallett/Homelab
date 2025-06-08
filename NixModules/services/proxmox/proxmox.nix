{ pkgs, lib, config, ... }: {
  imports = [./vms/caddy/vm.nix ./vms/testvm/vm.nix];

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
      prefixLength = 24;
    }];
    networking.interfaces.vmbr0.ipv4.routes = [
      {
        address      = "0.0.0.0";
        prefixLength = 0;
        via          = "192.168.1.1";
      }
    ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables"  = 0;
      "net.bridge.bridge-nf-call-ip6tables" = 0;
    };

    networking.firewall.allowedTCPPorts = [ 8006 ];
    networking.firewall.trustedInterfaces = [ "vmbr0" ];
    networking.firewall.extraCommands = ''
    iptables -A FORWARD -i vmbr0 -j ACCEPT
    iptables -A FORWARD -o vmbr0 -j ACCEPT
    '';
  };
}
