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
      api.stephenhallett.nz {
        tls {
          dns cloudflare ${builtins.readFile config.sops.secrets.cloudflare.path}
        }

        handle_path /savings/* {
          reverse_proxy 100.74.152.81:8181
        }
        handle_path /bustimer/* {
          reverse_proxy 100.111.121.51:8081
        }
        handle_path /dailytracker/* {
          reverse_proxy 100.111.121.51:8082
        }
        handle_path /calories/* {
          reverse_proxy 100.74.152.81:4000
        }
      }
    '';
    };
  };
}
