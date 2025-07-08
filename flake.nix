{
  description = "A clj-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs = { self, nixpkgs, flake-utils, clj-nix }:

    flake-utils.lib.eachDefaultSystem (system: {

      packages = {

        default = clj-nix.lib.mkCljApp {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            {
              projectSrc = ./.;
              name = "cljs-shadow-cljs-demo";
              main-ns = "demo.core";

              nativeImage.enable = true;
              # customJdk.enable = true;
            }
          ];
        };

      };
    });
}
