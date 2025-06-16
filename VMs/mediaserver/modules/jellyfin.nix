{
  pkgs,
  lib,
  config,
  ...
}:
let
  jellyfinConfigDir = "/mnt/NFS-Storage/Data/nix-mediaserver/jellyfin";
  jellyfinMediaDir = "/mnt/NFS-Storage/Media";
in
{
  options = {
    media-modules.jellyfin.enable = lib.mkEnableOption "enable jellyfin";
  };

  config = lib.mkIf config.media-modules.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = jellyfinConfigDir;
    };
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/jellyfin 0755 jellyfin jellyfin -"
    ];
  };
}