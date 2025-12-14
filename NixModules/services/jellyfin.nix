{
  pkgs-unstable,
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
      user = "stephen";
      group = "jellyfin";
      package = pkgs-unstable.jellyfin;
      # port 8096
    };
    environment.systemPackages = with pkgs-unstable; [
      jellyfin-web
      jellyfin-ffmpeg
    ];
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/jellyfin 0775 stephen jellyfin -"
    ];
  };
}