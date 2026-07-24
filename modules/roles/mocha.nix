{ config, ... }: {
  flake.modules.homeManager.mocha = {
    imports = with config.flake.modules.homeManager; [
      filechooser
      flatpak
      theme
      hyprland
      waybar
      games
    ];
  };

  flake.modules.nixos.mocha = {
    imports = with config.flake.modules.nixos; [
      mocha-configuration
      mocha-hardware-configuration
      mocha-networking
      mocha-memory
      media-server
      ncro
      distributed-builds
    ];
  };
}
