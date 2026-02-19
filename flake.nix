{
  description = "A flake with externalized scripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Import the scripts and pass in pkgs
          myScripts = import ./scripts.nix { inherit pkgs; };
        in
        {
          # Bring the scripts into the packages output
          inherit (myScripts) encrypt decrypt;

          # Default package (what runs with just 'nix run')
          # nix run/nix run .#default
          default = myScripts.encrypt;
        }
      );

      # Optional: make them available in 'nix develop'
      devShells = eachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            self.packages.${system}.encrypt
            self.packages.${system}.decrypt
          ];
        };
      });
    };
}
