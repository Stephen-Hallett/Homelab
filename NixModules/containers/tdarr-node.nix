{ lib, config, ... }: {
  options = { nix-config.tdarr-node.enable = lib.mkEnableOption "enable tdarr-node"; };

  config = lib.mkIf config.nix-config.tdarr-node.enable {
    virtualisation.oci-containers.containers.tdarr-node = {
        autoStart = true;
        image = "ghcr.io/haveagitgat/tdarr_node:2.31.02";
        environment = {
            PUID="1000";
            PGID="1000";
            UMASK="0002";
            TZ="Pacific/Auckland";
            nodeID="homelab_hostmachine";
            serverIP="192.168.1.76";
            serverPort="8266";
        };
        volumes = [
            "/mnt/NFS-Storage/Data/tdarr/configs:/app/configs"
            "/mnt/NFS-Storage/Data/tdarr/logs:/app/logs"
            "/mnt/NFS-Storage/Data/tdarr_transcode_cache:/temp"
            "/mnt/NFS-Storage/Media/media:/data"
        ];
        devices = [
          "/dev/dri:/dev/dri"
        ];
    };
  };
}
