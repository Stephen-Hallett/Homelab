{ pkgs-unstable, lib, config, ... }: {
  options = {
    nix-config.sunshine.enable = lib.mkEnableOption "enable sunshine";
  };

  config = lib.mkIf config.nix-config.sunshine.enable {
    environment.systemPackages = with pkgs-unstable; [ sunshine ];

    users.users.stephen.extraGroups = [ "video" "render" "input" ];

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      package = pkgs-unstable.sunshine;
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 47984 47989 47990 48010 ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 8000;
          to = 8010;
        }
      ];
    };

  };
}
