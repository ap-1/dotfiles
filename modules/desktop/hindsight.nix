{ inputs, config, ... }:
let
  ports = config.flake.ports;
in
{
  flake.modules.nixos.hindsight =
    { config, pkgs, ... }:
    {
      imports = [ inputs.llm-pkgs.nixosModules.hindsight ];

      nixpkgs.overlays = [
        inputs.llm-pkgs.overlays.default
        (_: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (_: pyprev: {
              pandas-stubs = pyprev.pandas-stubs.overridePythonAttrs (old: {
                pytestFlags = (old.pytestFlags or [ ]) ++ [
                  "-W"
                  "ignore::pytest.PytestRemovedIn10Warning"
                ];
              });
            })
          ];
        })
      ];

      age.secrets.hindsight-env.file = ../../secrets/hindsight-env.age;

      services.postgresApps.hindsight.service = "hindsight";
      services.postgresql.extensions = ps: [ ps.pgvector ];

      systemd.services.hindsight-pgvector = {
        description = "Create the pgvector extension in the hindsight database";
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
        before = [ "hindsight.service" ];
        wantedBy = [ "hindsight.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          ExecStart = ''${config.services.postgresql.package}/bin/psql -d hindsight -c "CREATE EXTENSION IF NOT EXISTS vector"'';
        };
      };

      systemd.services.hindsight = {
        after = [ "hindsight-pgvector.service" ];
        requires = [ "hindsight-pgvector.service" ];
      };

      services.hindsight = {
        enable = true;
        package = pkgs.hindsight;
        ui.package = pkgs.hindsight-ui;
        settings = {
          HINDSIGHT_API_DATABASE_URL = config.services.postgresApps.hindsight.url;

          # embeddings via local llama-server openai-compatible endpoint
          HINDSIGHT_API_EMBEDDINGS_PROVIDER = "openai";
          HINDSIGHT_API_EMBEDDINGS_OPENAI_BASE_URL = "http://127.0.0.1:${toString ports.llama-server-embeddings}/v1";
          HINDSIGHT_API_EMBEDDINGS_OPENAI_MODEL = "bge-m3";
          HINDSIGHT_API_EMBEDDINGS_OPENAI_API_KEY = "none";

          HINDSIGHT_API_RERANKER_PROVIDER = "litellm";
          HINDSIGHT_API_RERANKER_BASE_URL = "http://127.0.0.1:${toString ports.llama-server-reranker}";

          # api key set via environmentFile
          HINDSIGHT_API_LLM_PROVIDER = "litellm";
          HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:4000";
          HINDSIGHT_API_AUDIT_LOG_ENABLED = "true";
        };
        environmentFile = config.age.secrets.hindsight-env.path;
      };

      services.webProxy.sites.hindsight = "reverse_proxy http://127.0.0.1:9999";
    };
}
