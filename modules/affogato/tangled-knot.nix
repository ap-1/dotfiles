{ config, inputs, ... }:
let
  meta = config.flake.meta;
in
{
  flake.modules.nixos.affogato-tangled-knot = {
    imports = [ inputs.tangled.nixosModules.knot ];

    services.tangled.knot = {
      enable = true;
      stateDir = "/var/lib/tangled-knot";

      git = {
        # emitted as a systemd Environment= entry, so it cannot contain spaces
        userName = "anish.land";
        userEmail = meta.email;
      };

      server = {
        hostname = "knot.${meta.domain}";
        owner = meta.did;
        listenAddr = "127.0.0.1:5555";
        secureMode = true;
        logDids = false;
      };
    };
  };
}
