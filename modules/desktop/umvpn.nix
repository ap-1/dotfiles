{ ... }:
let
  username = "apallati";

  umvpn =
    {
      pkgs,
      config,
      ...
    }:
    let
      src = pkgs.fetchzip {
        url = "https://codeberg.org/ScottyLabs/umvpn/archive/46c22299d27f9c22a3ef81686749fe3c9678e8d5fdf76865c4c6c8e82c37ae1d.tar.gz";
        hash = "sha256-uHDZDFiPtrteOWh162bixw1zYZvSGNVuAWU+8bQvPok=";
      };
      umvpnPkg = pkgs.callPackage "${src}/nix/package.nix" { };
    in
    {
      age.secrets.umvpn-password = {
        file = ../../secrets/umvpn-password.age;
        owner = "anish";
      };
      age.secrets.umvpn-passkey = {
        file = ../../secrets/umvpn-passkey.age;
        owner = "anish";
      };

      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "umvpn-connect";
          runtimeInputs = [
            umvpnPkg
            pkgs.openconnect
            pkgs.coreutils
          ];
          text = ''
            printf '%s\0%s\0%s\0' \
              ${username} \
              "$(cat ${config.age.secrets.umvpn-password.path})" \
              "$(cat ${config.age.secrets.umvpn-passkey.path})" \
              | umvpn-auth \
              | sudo env "PATH=$PATH" umvpn
          '';
        })
      ];
    };
in
{
  flake.modules.nixos.umvpn = umvpn;
  flake.modules.darwin.umvpn = umvpn;
}
