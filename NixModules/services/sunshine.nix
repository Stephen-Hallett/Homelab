{ pkgs, lib, config, ... }: {
  options = {
    nix-config.sunshine.enable = lib.mkEnableOption "enable sunshine";
  };

  config = lib.mkIf config.nix-config.sunshine.enable {
    environment.systemPackages = with pkgs; [ sunshine ];
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
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
