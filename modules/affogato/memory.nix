{
  flake.modules.nixos.affogato-memory = { ... }: {
    boot.kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.zpool=zsmalloc"
      "zswap.max_pool_percent=25"
    ];

    boot.kernel.sysctl = {
      "vm.swappiness" = 60;
    };

    systemd.oomd.enable = true;

    nix.settings.max-jobs = 1;
    nix.settings.cores = 2;
  };
}
