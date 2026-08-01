{
  flake.ports = {
    llama-server-chat = 11434;
    llama-server-embeddings = 11435;
    llama-server-reranker = 11436;
  };

  flake.services = {
    # caddy virtual host at <name>.<domain> with A/AAAA dns records
    public = {
      headscale = "reverse_proxy http://127.0.0.1:8080";
      pds = "reverse_proxy http://127.0.0.1:3002";
      knot = "reverse_proxy http://127.0.0.1:5555";
    };

    # cloudflare tunnel ingress at <name>.<domain>; value is the localhost url
    tunnel = {
      idp = "https://127.0.0.1:8443";
      headplane = "http://127.0.0.1:3000";
      vault = "http://127.0.0.1:8222";
      git = "http://127.0.0.1:3001";
    };

    # headscale dns alias <name>.<tailnetDomain> -> the named host
    tailnet = {
      immich = "mocha";
      stash = "mocha";
      suwayomi = "mocha";
      pdf = "mocha";
      chat = "mocha";
      hindsight = "mocha";
      litellm = "mocha";
      fans = "mocha";
      sunshine = "mocha";
    };
  };
}
