{
  pkgs,
  lib,
  config,
  ...
}:
let
  sonarrConfigDir = "/mnt/NFS-Storage/Data/nix-mediaserver/sonarr";
in
{
  options = {
    media-modules.sonarr.enable = lib.mkEnableOption "enable sonarr";
  };

  config = lib.mkIf config.media-modules.sonarr.enable {
    services.sonarr = {
      enable = true;
      openFirewall = true;
      package = pkgs.sonarr;
      dataDir = sonarrConfigDir;
    };
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/sonarr 0755 sonarr sonarr -"
    ];
  };
}