{ config, ... }: {
  flake.modules.homeManager.cortado = {
    imports = with config.flake.modules.homeManager; [
      cortado-packages
      ghostty
    ];
  };

  flake.modules.darwin.cortado = {
    imports = with config.flake.modules.darwin; [
      cortado-configuration
      distributed-builds
    ];
  };
}
