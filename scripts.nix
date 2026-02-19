{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  encrypt = pkgs.writeShellApplication {
    name = "encrypt";
    runtimeInputs = [ pkgs.sops ];
    text = ''
      export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

      # Ensure the key file exists before running
      if [ ! -f "$SOPS_AGE_KEY_FILE" ]; then
        echo "Error: Age key not found at $SOPS_AGE_KEY_FILE" >&2
        exit 1
      fi

      sops encrypt ./org/work/work-log.org > ./org/work/enc/work-log.enc.org
      sops encrypt ./org/home/contacts.org > ./org/home/enc/contacts.enc.org
      echo "Files encrypted successfully."
    '';
  };

  decrypt = pkgs.writeShellApplication {
    name = "decrypt";
    runtimeInputs = [ pkgs.sops ];
    text = ''
      export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

      sops decrypt ./org/work/enc/work-log.enc.org > ./org/work/work-log.org
      sops decrypt ./org/home/enc/contacts.enc.org > ./org/home/contacts.org
      echo "Files decrypted successfully."
    '';
  };
}
