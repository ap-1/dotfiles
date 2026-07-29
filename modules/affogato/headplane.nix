{ config, ... }:
let
  meta = config.flake.meta;
in
{
  flake.modules.nixos.affogato-headplane = { config, ... }: {
    age.secrets.headplane-cookie-secret = {
      file = ../../secrets/headplane-cookie-secret.age;
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "0440";
    };

    age.secrets.headscale-api-key = {
      file = ../../secrets/headscale-api-key.age;
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "0440";
    };

    age.secrets.headplane-oauth2-secret = {
      file = ../../secrets/kanidm-oauth2-headplane.age;
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "0440";
    };

    services.headplane = {
      enable = true;
      settings = {
        server = {
          base_url = "https://headplane.${meta.domain}";
          cookie_secret_path = config.age.secrets.headplane-cookie-secret.path;
        };

        integration.proc.enabled = true;

        headscale.api_key_path = config.age.secrets.headscale-api-key.path;

        oidc = {
          issuer = "${meta.idpUrl}/oauth2/openid/headplane";
          client_id = "headplane";
          client_secret_path = config.age.secrets.headplane-oauth2-secret.path;
          disable_api_key_login = true;
          use_pkce = true;
        };
      };
    };
  };
}
