{ pkgs, lib, config, ... }: {
  options = {
    nix-config.jenkins.enable = lib.mkEnableOption "enable jenkins";
  };

  config = lib.mkIf config.nix-config.jenkins.enable {
    environment.systemPackages = with pkgs; [ ];
    services.jenkins = {
      enable = true;
      port = 8181;
    };
  };
}