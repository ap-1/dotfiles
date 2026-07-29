{ ... }:
{
  flake.modules.nixos.moonlight = {
    programs.moonlight-qt = {
      enable = true;
      capSysNice = true;
    };
  };

  flake.modules.homeManager.moonlight =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.moonlight-qt ];
    };
}
