{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
    ./modules
    ./../../NixModules/services/tailscale.nix
  ];

  media-modules = {
    jellyfin.enable = true;
};

  nix-config = {
    tailscale.enable = true;
  };

  networking.hostName = "mediaserver";

  fileSystems."/mnt/NFS-Storage" = {
    device = "192.168.1.152:/mnt/Mediastack";
    fsType = "nfs";
    options = [ "defaults" "noatime" "vers=3" "_netdev" ];
    neededForBoot = false;
  };

  systemd.tmpfiles.rules = [ 
    "d /mnt/NFS-Storage 0755 root root -" 
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}