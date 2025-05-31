{ pkgs, ... }: {
  imports = [ ./../Core/home.nix ];

  home = { packages = with pkgs; [ ]; };

  unix-packages = { alacritty.enable = false; };
  common-packages = { tmux.enable = true; };
}
