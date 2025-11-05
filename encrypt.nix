{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  name = "local dev shell to encrypt ";
  nativeBuildInputs = with pkgs; [
    sops
  ];

  # nix-shell encrypt.nix
  shellHook = ''
    ${pkgs.neofetch}/bin/neofetch
    echo -e "You are now in a dev shell in $(pwd)" | ${pkgs.lolcat}/bin/lolcat

    echo "Available commands:"
    echo "  encrypt - encrypt files"
    echo "  decrypt - decrypt files"

    export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
    encrypt(){
      sops encrypt ./org/work/work-log.org > ./org/work/enc/work-log.enc.org
    }

    decrypt(){
      sops decrypt ./org/work/enc/work-log.enc.org > ./org/work/work-log.org
    }
  '';
}
