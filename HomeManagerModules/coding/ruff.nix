{ pkgs, pkgs-unstable, lib, config, ... }:

let
  ruffToml = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/Stephen-Hallett/dotfiles/main/nix-config/HomeManagerModules/coding/ruff/ruff.toml";
  };
in {
  options = {
    core-packages.ruff.enable = lib.mkEnableOption "enable core-packages.ruff";
  };

  config = lib.mkIf config.core-packages.ruff.enable {
    programs.ruff = {
      enable = true;
      package = pkgs-unstable.ruff;
      settings = pkgs.lib.importTOML ruffToml;
    };
  };
}
