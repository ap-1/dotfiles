{ ... }:
let
  # nettle has no PQC so use openssl
  sqPqcOverlay = _: prev: {
    sequoia-sq = prev.sequoia-sq.overrideAttrs (old: {
      cargoBuildNoDefaultFeatures = true;
      cargoBuildFeatures = [ "crypto-openssl" ];
      cargoCheckNoDefaultFeatures = true;
      cargoCheckFeatures = [ "crypto-openssl" ];
      checkFlags = (old.checkFlags or [ ]) ++ [
        "--skip=sq_encrypt_cert_designators"
        "--skip=sq_key_revoke"
        "--skip=sq_key_subkey_password_3"
        "--skip=sq_key_subkey_delete"
        "--skip=sq_cert_lint::all_bad"
      ];
    });
  };

  # crypto-rust backend and a bumped lock pull sequoia-openpgp 2.4, so gpg-sq handles pqc keys
  chameleonPqcOverlay = _: prev: {
    sequoia-chameleon-gnupg = prev.sequoia-chameleon-gnupg.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.capnproto ];
      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = ./Cargo.lock;
      };
      postPatch = (old.postPatch or "") + ''
        cp ${./Cargo.lock} Cargo.lock
      '';
      cargoBuildNoDefaultFeatures = true;
      cargoBuildFeatures = [
        "sequoia-openpgp/crypto-rust"
        "sequoia-openpgp/allow-experimental-crypto"
        "sequoia-openpgp/allow-variable-time-crypto"
      ];
    });
  };
in
{
  flake.modules.nixos.gpg.nixpkgs.overlays = [ sqPqcOverlay chameleonPqcOverlay ];
  flake.modules.darwin.gpg.nixpkgs.overlays = [ sqPqcOverlay chameleonPqcOverlay ];

  flake.modules.homeManager.gpg =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sequoia-sq
        sequoia-chameleon-gnupg
      ];

      services.gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        defaultCacheTtl = 86400;
        maxCacheTtl = 86400;
        pinentry.package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
      };
    };
}
