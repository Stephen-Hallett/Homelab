{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
  ];

  fileSystems."/home/stephen/Media" = {
    device = "192.168.1.152:/mnt/Mediastack";
    fsType = "nfs";
    options = [ "defaults" "noatime" "vers=3" "_netdev" ];
    neededForBoot = false;
  };

  systemd.tmpfiles.rules = [ 
    "d /home/stephen/Media 0755 root root -" 
  ];

  nix-config = {
    tailscale.enable = false;
    docker.enable = true;
  };

  environment.systemPackages = [ pkgs.docker ];

  networking.hostName = "tdarr";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.oci-containers.containers = {
    tdarr-node = {
      autoStart = true;
      image = "ghcr.io/haveagitgat/tdarr_node:latest";
      environment = {
        PUID=1000;
        PGID=1000;
        UMASK=0002;
        TZ="Pacific/Auckland";
        nodeID="homelab_node";
        serverIP="192.168.1.76";
        serverPort=8266;
      };
      volumes = [
        "/home/stephen/Media/Data/tdarr/configs:/app/configs"
        "/home/stephen/Media/Data/tdarr/logs:/app/logs"
        "/home/stephen/Media/Data/tdarr_transcode_cache:/temp"
        "/home/stephen/Media/Media/media:/data"
      ];
    };
  };
}