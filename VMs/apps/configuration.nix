{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
  ];

  nix-config = {
    tailscale.enable = true;
    docker.enable = true;
  };

  environment.systemPackages = [ pkgs.docker ];

  networking.hostName = "apps";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.oci-containers.containers = {
    scopus-check = {
      autoStart = true;
      image = "ghcr.io/stephen-hallett/scopus-check:latest";
      ports = [ "8080:8080" ];
    };
  };
}