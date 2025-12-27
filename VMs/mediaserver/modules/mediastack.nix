{
  pkgs,
  lib,
  config,
  ...
}:
let
  DataDir = "/tank/Data";
  MediaDir = "/tank/Media";
  dockerDir = "mediastack";
  theme = "dracula";
in
{
  options = {
    media-modules.mediastack.enable = lib.mkEnableOption "enable mediastack";
  };

  config = lib.mkIf config.media-modules.mediastack.enable {
    environment.etc."${dockerDir}/compose.yaml".text =
      /*
      yaml
      */
      ''
        networks:
          mediastack:
            name: mediastack
            driver: bridge
            ipam:
              driver: default
              config:
              - subnet: ''${DOCKER_SUBNET}
                gateway: ''${DOCKER_GATEWAY}

        services:
        # ========================== VPN ==========================
          gluetun:
            image: qmcgaw/gluetun:latest
            container_name: gluetun
            restart: always
            cap_add:
              - NET_ADMIN
            devices:
              - /dev/net/tun:/dev/net/tun
            ports:
              - 8888:8888/tcp                         # Gluetun Local Network HTTP proxy
              - 8388:8388/tcp                         # Gluetun Local Network Shadowsocks
              - 8388:8388/udp                         # Gluetun Local Network Shadowsocks
              - 8320:8320                             # Gluetun Status Port
              - 8080:8080                             # WebUI Portal: SABnzbd
              - 8200:8200                             # WebUI Portal: qBittorrent
              - 6881:6881                             # Transmission Torrent Port

            volumes:
              - ${DataDir}/gluetun:/gluetun
            environment:
              - PUID=1000
              - PGID=1000
              - UMASK=0002
              - TZ=Pacific/Auckland
              - VPN_SERVICE_PROVIDER=nordvpn
              - OPENVPN_USER=''${VPN_USER}
              - OPENVPN_PASSWORD=''${VPN_PASSWORD}
              - SERVER_REGIONS="Asia Pacific"
              - FIREWALL_OUTBOUND_SUBNETS=''${LOCAL_SUBNET}
              - HTTP_CONTROL_SERVER_ADDRESS=:8320
              - VPN_TYPE=openvpn
              - HTTPPROXY=on
              - SHADOWSOCKS=on
            networks:
              - mediastack

          qbittorrent:
            image: lscr.io/linuxserver/qbittorrent:latest
            container_name: qbittorrent
            restart: unless-stopped
            depends_on:
              gluetun:
                condition: service_healthy
                restart: true
            volumes:
              - ${MediaDir}:/data
              - ${DataDir}/qbittorrent:/config
            environment:
              - PUID=1000
              - PGID=1000
              - UMASK=0002
              - TZ=Pacific/Auckland
              - WEBUI_PORT=8200
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:qbittorrent
              - TP_THEME=${theme}
            network_mode: "service:gluetun"

          sabnzbd:
            image: lscr.io/linuxserver/sabnzbd:latest
            container_name: sabnzbd
            restart: unless-stopped
            depends_on:
              gluetun:
                condition: service_healthy
                restart: true
            volumes:
              - ${MediaDir}:/data
              - ${DataDir}/sabnzbd:/config
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Pacific/Auckland
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:sabnzbd
              - TP_THEME=${theme}
            network_mode: "service:gluetun"
          
          prowlarr:
            image: lscr.io/linuxserver/prowlarr:develop
            container_name: prowlarr
            restart: unless-stopped
            volumes:
              - ${DataDir}/prowlarr:/config
            ports:
              - "9696:9696"
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Pacific/Auckland
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:prowlarr
              - TP_THEME=${theme}
            networks:
              - mediastack
          
          sonarr:
            image: lscr.io/linuxserver/sonarr:latest
            container_name: sonarr
            restart: unless-stopped
            volumes:
              - ${DataDir}/sonarr:/config
              - ${MediaDir}:/data
            ports:
              - "8989:8989"
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Pacific/Auckland
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:sonarr
              - TP_THEME=${theme}
            networks:
              - mediastack

          radarr:
            image: lscr.io/linuxserver/radarr:latest
            container_name: radarr
            restart: unless-stopped
            volumes:
              - ${DataDir}/radarr:/config
              - ${MediaDir}:/data
            ports:
              - "7878:7878"
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Pacific/Auckland
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:radarr
              - TP_THEME=${theme}
            networks:
              - mediastack
          
          bazarr:
            image: lscr.io/linuxserver/bazarr:v1.5.3-ls328
            container_name: bazarr
            restart: unless-stopped
            volumes:
              - ${DataDir}/bazarr:/config
              - ${MediaDir}/media/movies:/movies
              - ${MediaDir}/media/tv:/tv
            ports:
              - "6767:6767"
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Pacific/Auckland
              - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:bazarr
              - TP_THEME=${theme}
            networks:
              - mediastack
      '';

    # Create an environment file that loads all secrets
    systemd.services.mediastack-env = {
      description = "Generate mediastack environment file";
      wantedBy = [ "multi-user.target" ];
      before = [ "mediastack.service" ];
      
      script = ''
        cat > /run/mediastack.env <<EOF
        DOCKER_SUBNET=$(cat ${config.sops.secrets."mediastack/docker_subnet".path})
        DOCKER_GATEWAY=$(cat ${config.sops.secrets."mediastack/docker_gateway".path})
        VPN_USER=$(cat ${config.sops.secrets."mediastack/vpn_user".path})
        VPN_PASSWORD=$(cat ${config.sops.secrets."mediastack/vpn_password".path})
        LOCAL_SUBNET=$(cat ${config.sops.secrets."mediastack/local_subnet".path})
        EOF
        chmod 600 /run/mediastack.env
      '';
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
 
    systemd.services.mediastack = {
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket" "mediastack-env.service"];
      requires = ["mediastack-env.service"];
      path = [pkgs.docker];
      script = ''
        set -a
        source /run/mediastack.env
        set +a
        docker compose -f /etc/${dockerDir}/compose.yaml up --force-recreate -d
      '';
      restartTriggers = [
        config.environment.etc."${dockerDir}/compose.yaml".source
      ];
    };
  };
}