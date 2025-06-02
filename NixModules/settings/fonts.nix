{ pkgs, lib, config, ... }: {
  options = { nix-config.fonts.enable = lib.mkEnableOption "enable fonts"; };

  config = lib.mkIf config.nix-config.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.fantasque-sans-mono
      noto-fonts
      noto-fonts-emoji
      twemoji-color-font
      font-awesome
      powerline-fonts
      powerline-symbols
    ];
  };
}
