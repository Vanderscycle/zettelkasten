{
  description = "Encrypt work documents";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      src = pkgs.lib.cleanSource ./org-roam;
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };
      sopsKey = /home/henri/.config/sops/age/keys.txt;
    in
    {

      devShells.${system} = {
        # nix develop .#encrypt
        sops_shell = (
          import ./encrypt.nix {
            inherit pkgs;
            inherit inputs;
          }
        );
      };
      org_protected_b_encrypt = pkgs.stdenv.mkDerivation {
        name = "encrypt org/work files";
        src = ./.;
        buildPhase = ''
          export SOPS_AGE_KEY_FILE=${sopsKey}
          mkdir -p $out

          sops -e ${src}/org/work/work-log.org > $out/work-log.enc.org
          sops -e ${src}/org/work/todo.org > $out/todo.enc.org
          echo "encrypted"
        '';
        nativeBuildInputs = [
          pkgs.sops
        ];
        installPhase = ''
          mkdir -p $out
        '';
        configurePhase = "true";
      };

      org_protected_b_decrypt = pkgs.stdenv.mkDerivation {
        name = "decrypt org/work files";
        src = ./.;
        buildPhase = ''
          export SOPS_AGE_KEY_FILE=${sopsKey}
          mkdir -p $out
          sops -d ./org-roam/org/work/work-log.enc.org > $out/work-log.org
          sops -d ./org-roam/org/work/todo.enc.org > $out/todo.org

          if [ -d ./result ]; then
            cp result/todo.org ./org-roam/org/work/todo.org
            cp result/work-log.org ./org-roam/org/work/work-log.org
            echo "decrypted"
          fi
        '';
        nativeBuildInputs = [
          pkgs.sops
        ];

        installPhase = ''
          mkdir -p $out
        '';
      };
    };
}
