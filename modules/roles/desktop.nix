{
  config,
  inputs,
  ...
}:
{
  flake.modules.homeManager.desktop = {
    imports =
      (with config.flake.modules.homeManager; [
        zed-editor
        firefox
        spicetify
        discord
        desktop-packages
        moonlight
      ])
      ++ [
        inputs.omp-nix.homeManagerModules.omp
      ];

    oh-my-pi.enable = true;
  };

  flake.modules.nixos.desktop = {
    imports = with config.flake.modules.nixos; [
      firefox
      localsend
      desktop-packages
      hyprland
      immich
      stashapp
      suwayomi
      llamaServer
      litellm
      cliproxyapi
      hindsight
      postgres
      hardware-control
      sunshine
      moonlight
      games
      umvpn
    ];
  };

  flake.modules.darwin.desktop = {
    imports = with config.flake.modules.darwin; [
      firefox
      localsend
      desktop-packages
      sunshine
      umvpn
    ];
  };
}
