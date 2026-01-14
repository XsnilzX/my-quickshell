{
  description = "Entwicklungsumgebung Quickshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        quickshell
        curl
        codex
      ];

      shellHook = ''
        echo "✓ Entwicklungsumgebung geladen"
        echo "  Docker: $(docker --version)"
        echo "  Java: $(java -version 2>&1 | head -n 1)"
      '';
    };
  };
}
