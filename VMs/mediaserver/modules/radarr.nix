{
  pkgs,
  lib,
  config,
  ...
}:
let
  radarrConfigDir = "/mnt/NFS-Storage/Data/nix-mediaserver/radarr";
in
{
  options = {
    media-modules.radarr.enable = lib.mkEnableOption "enable radarr";
  };

  config = lib.mkIf config.media-modules.radarr.enable {
    services.radarr = {
      enable = true;
      openFirewall = true;
      package = pkgs.radarr;
      dataDir = radarrConfigDir;
    };
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/radarr 0755 radarr radarr -"
    ];
  };
}