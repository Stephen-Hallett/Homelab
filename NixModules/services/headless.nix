{ pkgs, lib, config, ... }: {
  options = {
    nix-config.headless.enable = lib.mkEnableOption "enable headless";
  };

  config = lib.mkIf config.nix-config.headless.enable {
    services.xserver = {
      enable = true;
      videoDrivers = [ "dummy" ];
      autorun = true;

      displayManager.gdm.enable = true;
      displayManager.defaultSession = "gnome";

      displayManager.autoLogin.enable = true;
      displayManager.autoLogin.user = "sunshine"; # user must exists

      desktopManager.gnome.enable = true;

      virtualScreen = {
        x = 1920;
        y = 1080;
      };

      screenSection = ''
        Identifier  "Default Screen"
          Monitor     "Configured Monitor"
          Device      "Configured Video Device"
          DefaultDepth 24
          SubSection "Display"
            Depth 24
            Modes "1920x1080" "1280x800" "1024x768" "1920x1080" "1440x900"
          EndSubSection
        '';

      deviceSection = ''
        Identifier  "Configured Video Device"
        Driver      "dummy"
      '';

      monitorSection = ''
        Identifier  "Configured Monitor"
        HorizSync 5.0 - 1000.0
        VertRefresh 5.0 - 200.0
        ModeLine "1920x1080" 148.50 1920 2448 2492 2640 1080 1084 1089 1125 +Hsync +Vsync
      '';
    };

    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    services.xrdp.openFirewall = true;


    # Needed for 32-bit games
    hardware.graphics.enable32Bit = true;
    hardware.graphics.enable = true;

  };
}
