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
      # work
      sops encrypt ./org/work/work-log.org > ./org/work/enc/work-log.enc.org
      # home
      sops encrypt ./org/home/contacts.org > ./org/home/enc/contacts.enc.org
      sops encrypt ./org/home/meetings.org > ./org/home/enc/meetings.enc.org

      exit 0
    }


    decrypt(){
      # work
      sops decrypt ./org/work/enc/work-log.enc.org > ./org/work/work-log.org
      # home
      sops decrypt ./org/home/enc/contacts.enc.org > /org/home/contacts.org
      sops encrypt  ./org/home/enc/meetings.enc.org > ./org/home/meetings.org

      exit 0
    }
  '';
}
