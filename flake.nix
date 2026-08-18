{
  description = "Flashpoint runnable as a Nix package";

  nixConfig = {
    extra-substituters = [
      "https://weshford.cachix.org"
    ];
    extra-trusted-public-keys = [
      "weshford.cachix.org-1:AjjaEh2rtC/MRpoXY18gHcXr3KJqk7sUTigRsi23DSY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          flakepoint = pkgs.callPackage ./package.nix { };
        in
        {
          inherit flakepoint;
          default = flakepoint;
        });

      apps = forAllSystems (system: {
        flakepoint = {
          type = "app";
          program = "${self.packages.${system}.flakepoint}/bin/flakepoint";
          meta = {
            description = "Flashpoint Archive Launcher";
          };
        };
        default = self.apps.${system}.flakepoint;
      });

      overlays.default = final: prev: {
        flakepoint = final.callPackage ./package.nix { };
      };

      nixosModules.flakepoint = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.flakepoint;
        in
        {
          options.programs.flakepoint = {
            enable = lib.mkEnableOption "Flashpoint Archive (Flakepoint)";
            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.flakepoint;
              description = "The flakepoint package to install.";
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];
          };
        };

      nixosModules.default = self.nixosModules.flakepoint;

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.flakepoint ];
          };
        });
    };
}
