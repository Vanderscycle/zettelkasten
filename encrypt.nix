{
  inputs,
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  name = "local dev shell";
  nativeBuildInputs = with pkgs; [
    sops
  ];

  shellHook = ''
    ${pkgs.neofetch}/bin/neofetch
    echo -e "You are now in a dev shell in $(pwd)" | ${pkgs.lolcat}/bin/lolcat

    echo "Available commands:"
    echo "  encrypt - Create local Kubernetes cluster"
    echo "  decrypt - Generate Kubernetes secrets"
    encrypt(){
      sops -e ./org-roam/org/work/work-log.org > ./org-roam/org/work/work-log.enc.org
      sops -e ./org-roam/org/work/todo.org > ./org-roam/org/work/todo.enc.org
    }

    decrypt(){
      sops -d ./org-roam/org/work/work-log.enc.org > ./org-roam/org/work/work-log.org
      sops -d ./org-roam/org/work/todo.enc.org >     ./org-roam/org/work/todo.org
    }
  '';
}
