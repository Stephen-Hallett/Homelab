{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
    ./../../NixModules/services/tailscale.nix
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
    user = "caddy";
    email = "stevohallett@gmail.com";
    package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
    };
    extraConfig = ''
      (cloudflare) {
          tls {
              dns cloudflare ${builtins.readFile config.sops.secrets.cloudflare.path}
          }
      }

      # proxmox
      proxmox.hosted.stephenhallett.nz {
          reverse_proxy https://100.76.206.4:8006 {
              transport http {
                  tls_insecure_skip_verify
              }
          }
      }

      # code-server
      code.hosted.stephenhallett.nz {
          reverse_proxy http://100.76.206.4:4200
          import cloudflare
      }

      # Sunshine
      sunshine.hosted.stephenhallett.nz {
          reverse_proxy https://100.76.206.4:47990 {
            transport http {
                tls_insecure_skip_verify
            }
          }
      }

      # qbittorrent
      qbittorrent.hosted.stephenhallett.nz {
          reverse_proxy http://192.168.1.76:8200
          import cloudflare
      }

      # homarr
      homarr.hosted.stephenhallett.nz {
          reverse_proxy http://192.168.1.76:3200
          import cloudflare
      }

      # tdarr
      tdarr.hosted.stephenhallett.nz {
          reverse_proxy http://192.168.1.76:8265
          import cloudflare
      }

      # nextcloud
      nextcloud.hosted.stephenhallett.nz {
          reverse_proxy http://100.76.206.4:1000
          import cloudflare
      }

      # immich
      immich.hosted.stephenhallett.nz {
          reverse_proxy http://100.76.206.4:2283
          import cloudflare
      }

      # jenkins
      jenkins.hosted.stephenhallett.nz {
          reverse_proxy http://100.76.206.4:8181
          import cloudflare
      }

      scopus-check.hosted.stephenhallett.nz {
        reverse_proxy http://100.74.152.81:8080
        import cloudflare
      }

      savingsapi.hosted.stephenhallett.nz {
        reverse_proxy http://100.74.152.81:8181
        import cloudflare
      }
    '';
  };
}