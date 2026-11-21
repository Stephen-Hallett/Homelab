{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
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

        api.hosted.stephenhallett.nz/savings {
            reverse_proxy http://100.74.152.81:8181
            import cloudflare
        }

        api.hosted.stephenhallett.nz/bustimer {
            reverse_proxy http://100.111.121.51:8081
            import cloudflare
        }

        api.hosted.stephenhallett.nz/dailytracker {
            reverse_proxy http://100.111.121.51:8082
            import cloudflare
        }

        api.hosted.stephenhallett.nz/calories {
            reverse_proxy http://100.74.152.81:4000
            import cloudflare
        }
        '';
    };
  };
}
