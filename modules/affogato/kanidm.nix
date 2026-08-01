{ config, ... }:
let
  meta = config.flake.meta;

  scopes = [
    "openid"
    "profile"
    "email"
    "groups"
  ];

  # kanidm oauth2 clients
  oauth2 = {
    headscale = {
      display = "Headscale";
      subdomain = "headscale";
      callback = "/oidc/callback";
      group = "headscale.access";
    };
    headplane = {
      display = "Headplane";
      subdomain = "headplane";
      callback = "/admin/oidc/callback";
      group = "headplane.admins";
    };
    vaultwarden = {
      display = "Vaultwarden";
      subdomain = "vault";
      callback = "/identity/connect/oidc-signin";
      group = "vaultwarden.access";
      enableLegacyCrypto = true;
    };
    forgejo = {
      display = "Forgejo";
      subdomain = "git";
      callback = "/user/oauth2/kanidm/callback";
      group = "forgejo.access";
    };
    pds = {
      display = "Tranquil PDS";
      subdomain = "pds";
      callback = "/oauth/sso/callback";
      group = "pds.access";
    };
    immich = {
      display = "Immich";
      subdomain = "immich";
      domain = meta.tailnetDomain;
      group = "immich.access";
      origins = [
        "https://immich.${meta.tailnetDomain}/auth/login"
        "https://immich.${meta.tailnetDomain}/user-settings"
        "app.immich:///oauth-callback"
      ];
    };
    open-webui = {
      display = "Open WebUI";
      subdomain = "chat";
      domain = meta.tailnetDomain;
      callback = "/oauth/oidc/callback";
      group = "open-webui.access";
    };
    litellm = {
      display = "LiteLLM";
      subdomain = "litellm";
      domain = meta.tailnetDomain;
      callback = "/sso/callback";
      group = "litellm.access";
      claimMaps.litellm_role = {
        joinType = "csv";
        valuesByGroup."litellm.access" = [ "proxy_admin" ];
      };
    };
  };

  mkKanidmSecret = file: {
    inherit file;
    owner = "kanidm";
    group = "kanidm";
    mode = "0440";
  };
in
{
  flake.modules.nixos.affogato-kanidm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      age.secrets = {
        kanidm-admin = mkKanidmSecret ../../secrets/kanidm-admin.age;
        kanidm-idm-admin = mkKanidmSecret ../../secrets/kanidm-idm-admin.age;
      }
      // lib.mapAttrs' (
        name: _:
        lib.nameValuePair "kanidm-oauth2-${name}" (mkKanidmSecret ../../secrets/kanidm-oauth2-${name}.age)
      ) oauth2;

      users.users.kanidm.extraGroups = [ "acme" ];

      services.kanidm = {
        package = pkgs.kanidmWithSecretProvisioning_1_10;

        server.enable = true;
        server.settings = {
          domain = meta.idpDomain;
          origin = meta.idpUrl;
          bindaddress = "127.0.0.1:8443";
          tls_chain = "/var/lib/acme/${meta.idpDomain}/fullchain.pem";
          tls_key = "/var/lib/acme/${meta.idpDomain}/key.pem";
          online_backup = {
            path = "/var/lib/kanidm/backups";
            schedule = "00 22 * * *";
            versions = 7;
          };
        };

        client.enable = true;
        client.settings.uri = meta.idpUrl;

        provision = {
          enable = true;
          adminPasswordFile = config.age.secrets.kanidm-admin.path;
          idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin.path;
          autoRemove = true;

          groups = lib.listToAttrs (map (c: lib.nameValuePair c.group { }) (lib.attrValues oauth2));

          persons.anish = {
            displayName = "Anish";
            mailAddresses = [ meta.email ];
            groups = map (c: c.group) (lib.attrValues oauth2);
          };

          systems.oauth2 = lib.mapAttrs (
            name: c:
            let
              dom = c.domain or meta.domain;
              base = "https://${c.subdomain}.${dom}";
            in
            {
              displayName = c.display;
              originUrl = c.origins or "${base}${c.callback}";
              originLanding = "${base}/";
              basicSecretFile = config.age.secrets."kanidm-oauth2-${name}".path;
              preferShortUsername = true;
              scopeMaps.${c.group} = scopes;
            }
            // builtins.intersectAttrs {
              enableLegacyCrypto = null;
              claimMaps = null;
            } c
          ) oauth2;
        };
      };

      security.acme.certs."${meta.idpDomain}".reloadServices = [ "kanidm.service" ];

      systemd.tmpfiles.rules = [
        "d /var/lib/kanidm/backups 0700 kanidm kanidm -"
      ];

      systemd.services.kanidm = {
        wants = [ "acme-${meta.idpDomain}.service" ];
        after = [ "acme-${meta.idpDomain}.service" ];
      };
    };
}
