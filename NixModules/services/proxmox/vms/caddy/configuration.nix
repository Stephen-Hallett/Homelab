{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../../../../Hosts/VM/configuration.nix
    ./../../../tailscale.nix
  ];

  nix-config = {
    tailscale.enable = true;
  };

  networking.hostName = "caddy";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = [ pkgs.caddy ];

  services.caddy = {
    enable = true;
    email = "stevohallett@gmail.com";
    configFile = ./Caddyfile;
    # environmentFile = "/run/secrets/caddy.env"; # Needs to be created manually in the VM
    package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
    };
  };
}