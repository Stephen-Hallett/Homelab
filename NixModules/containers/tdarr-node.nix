{ lib, config, ... }: {
  options = { nix-config.tdarr-node.enable = lib.mkEnableOption "enable tdarr-node"; };

  config = lib.mkIf config.nix-config.tdarr-node.enable {
    virtualisation.oci-containers.containers.tdarr-node = {
        autoStart = true;
        image = "ghcr.io/haveagitgat/tdarr_node:latest";
        environment = {
            PUID="1000";
            PGID="1000";
            UMASK_SET="0002";
            TZ="Pacific/Auckland";
            nodeID="homelab_hostmachine";
            serverIP="100.79.204.48";
            serverPort="8266";
        };
        volumes = [
            "/tank/mediastack/Data/tdarr/configs:/app/configs"
            "/tank/mediastack/Data/tdarr/logs:/app/logs"
            "/tank/mediastack/Data/tdarr_transcode_cache:/temp"
            "/tank/mediastack/Media/media:/data"
        ];
        devices = [
          "/dev/dri:/dev/dri"
        ];
        extraOptions = [
          "--device=/dev/dri:/dev/dri"
          "--group-add=video"
      ];
    };
  };
}
