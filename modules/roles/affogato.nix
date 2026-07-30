{ config, ... }: {
  flake.modules.nixos.affogato = {
    imports = with config.flake.modules.nixos; [
      affogato-configuration
      affogato-hardware-configuration
      affogato-disko
      affogato-persist
      affogato-web
      affogato-cloudflared
      affogato-kanidm
      affogato-headscale
      affogato-headplane
      affogato-vaultwarden
      affogato-forgejo
      affogato-atuin
      affogato-memory
      distributed-builds
      ncro
    ];
  };
}
