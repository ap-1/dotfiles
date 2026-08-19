{ inputs, ... }:
{
  flake.modules.nixos.mocha-configuration = { pkgs, ... }: {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # AMD settings
    boot.kernelModules = [ "amdgpu" ];
    boot.kernelParams = [
      "amd_pstate=active"
      "amdgpu.dc=1"
    ];

    # CachyOS kernel (LTO, znver4-tuned)
    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

    # Btrfs optimizations
    fileSystems."/".options = [
      "subvol=@"
      "compress=zstd"
      "noatime"
    ];
    fileSystems."/home".options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
    ];

    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Steam
    };

    # Sunshine capture device
    services.sunshine.settings = {
      adapter_name = "/dev/dri/card1";
      output_name = "0";
    };

    # Lock screen
    security.pam.services.waylock = { };

    # Set your time zone.
    time.timeZone = "America/New_York";

    # Enable ly display manager
    services.displayManager.ly.enable = true;

    # Define user account.
    users.users.anish = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "media"
        "ydotool"
      ];
    };

    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        vulkan-loader
      ];
    };
    programs.hyprland.enable = true;

    environment.variables = {
      NIXOS_OZONE_WL = 1; # Configure Electron / CEF apps to use Wayland
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Enable the flatpak service
    services.flatpak.enable = true;

    # USB drive mounting
    services.udisks2.enable = true;

    system.stateVersion = "25.05";
  };
}
