{ lib, config, pkgs, ... }: {
  options = { nix-config.docker.enable = lib.mkEnableOption "enable docker"; };

  config = lib.mkIf config.nix-config.docker.enable {
    virtualisation.docker.enable = true;
    virtualisation.podman.enable = true;

    environment.systemPackages = with pkgs; [
        docker-compose
    ];
    users.users.stephen.extraGroups = [ "docker" ];
  };
}
