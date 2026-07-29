{ inputs, config, ... }:
let
  meta = config.flake.meta;
in
{
  flake.modules.nixos.sunshine = { pkgs, ... }: {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # Wayland/Hyprland screen capture
      openFirewall = true;
      settings.key_rightalt_to_key_win = "enabled";
      settings.csrf_allowed_origins = "https://sunshine.${meta.tailnetDomain}";
      package = inputs.nixpkgs-sunshine.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sunshine;
    };

    services.webProxy.sites.sunshine = ''
      reverse_proxy https://127.0.0.1:47990 {
        transport http {
          tls_insecure_skip_verify
        }
      }
    '';

    # Discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true; # allows system to resolve .local addresses
      publish = {
        enable = true;
        userServices = true; # broadcasts sunshine
        addresses = true; # broadcasts this machine's IP
      };
    };

    # Input configuration
    hardware.uinput.enable = true;
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
    '';

    users.users.anish.extraGroups = [
      "input"
      "video"
      "render"
      "uinput"
    ];
  };

  flake.modules.darwin.sunshine = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.sunshine ];
  };
}
