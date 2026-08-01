{
  flake.modules.nixos.affogato-postgres = { pkgs, ... }: {
    services.postgresql.package = pkgs.postgresql_18;
    services.postgresqlBackup.enable = true;
  };
}
