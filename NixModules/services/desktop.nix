{ pkgs, lib, config, ... }: {
  options = {
    nix-config.desktop.enable = lib.mkEnableOption "enable desktop";
  };

  config = lib.mkIf config.nix-config.desktop.enable {
    programs.uwsm.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      kitty
      xdg-desktop-portal-gtk
      xwayland
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
