{
  description = "Entwicklungsumgebung Quickshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    goather = {
      url = "github:XsnilzX/goather";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    goather,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    goatherPackage =
      if goather.packages.${system} ? default
      then goather.packages.${system}.default
      else goather.defaultPackage.${system};
  in {
    packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
      pname = "my-quickshell";
      version = "0.1.0";
      src = ./.;

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/my-quickshell"
        cp -r src "$out/share/my-quickshell/"
        runHook postInstall
      '';
    };

    homeManagerModules.default = import ./nix/home-manager.nix {
      inherit self;
      inherit goather;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        quickshell
        curl
        opencode
      ] ++ [
        goatherPackage
      ];
    };
  };
}
