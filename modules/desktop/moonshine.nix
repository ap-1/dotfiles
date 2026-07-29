{ inputs, ... }:
{
  flake.modules.nixos.moonshine =
    { pkgs, ... }:
    let
      moonshine = inputs.nixpkgs-moonshine.legacyPackages.${pkgs.stdenv.hostPlatform.system}.moonshine;
      # shut down a running desktop Steam so the streamed instance becomes primary
      steamShutdown = [
        [
          "/run/current-system/sw/bin/bash"
          "-c"
          "if /run/current-system/sw/bin/pgrep -x steam >/dev/null; then /run/current-system/sw/bin/steam -shutdown; for ((i=0;i<15;i++)); do /run/current-system/sw/bin/pgrep -x steam >/dev/null || break; /run/current-system/sw/bin/sleep 1; done; fi"
        ]
      ];
    in
    {
      imports = [ inputs.moonshine.nixosModules.moonshine ];

      services.moonshine = {
        enable = true;
        openFirewall = true;
        user = "anish";
        uid = 1000;
        package = moonshine;

        settings = {
          name = "Moonshine";

          application_scanner = [
            {
              type = "steam";
              library = "$HOME/.local/share/Steam";
              command = [
                "/run/current-system/sw/bin/gamemoderun"
                "/run/current-system/sw/bin/steam"
                "-bigpicture"
                "steam://rungameid/{game_id}"
              ];
              pre_command = steamShutdown;
              stdout = "journal";
              stderr = "journal";
              launch_timeout_secs = 30;
            }
            {
              type = "lutris";
              command = [
                "/run/current-system/sw/bin/gamemoderun"
                "/etc/profiles/per-user/anish/bin/lutris"
                "lutris:rungame/{slug}"
              ];
              stdout = "journal";
              stderr = "journal";
              launch_timeout_secs = 30;
            }
          ];
        };
      };

      # sleep inhibitor
      users.users.anish.extraGroups = [ "moonshine" ];

      # GameStream mDNS discovery
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          userServices = true;
          addresses = true;
        };
      };
    };
}
