{
  description = "Encrypt work documents";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        home = builtins.getEnv "HOME";
        sopsKey = "${home}/.config/sops/age/keys.txt";

        # nix build ".#org_protected_b_encrypt" --impure
        org_protected_b_encrypt = pkgs.stdenv.mkDerivation {
          name = "encrypt-org-work";
          src = ./.;
          buildPhase = ''
            export SOPS_AGE_KEY_FILE=${sopsKey}
            mkdir -p $out

            for FILE in ./org/work/*.org; do
              FILENAME=$(basename -- "$FILE" .org)
              ENCRYPTED_NAME="$FILENAME.enc.yaml"
              sops --output-type yaml -e "$FILE" > "./org/work/$ENCRYPTED_NAME"
            done
          '';
          nativeBuildInputs = [ pkgs.sops ];
          installPhase = "mkdir -p $out";
          configurePhase = "true";
        };

        # nix build ".#org_protected_b_decrypt" --impure
        org_protected_b_decrypt = pkgs.stdenv.mkDerivation {
          name = "decrypt-org-work";
          src = ./.;
          buildPhase = ''
            export SOPS_AGE_KEY_FILE=${sopsKey}
            mkdir -p $out
            sops -d ./org/work/work-log.enc.org > $out/work-log.org
            sops -d ./org/work/todo.enc.org > $out/todo.org

            if [ -d ./result ]; then
              cp result/todo.org ./org-roam/org/work/todo.org
              cp result/work-log.org ./org-roam/org/work/work-log.org
            fi
          '';
          nativeBuildInputs = [ pkgs.sops ];
          installPhase = "mkdir -p $out";
        };
      in
      {
        packages = {
          inherit org_protected_b_encrypt org_protected_b_decrypt;
          default = org_protected_b_encrypt;
        };
      }
    );
}
