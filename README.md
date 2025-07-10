# cljs-shadow-cljs-demo

Example ClojureScript `shadow-cljs` project packaged with Nix Flakes, using `clj-nix` and the `buildNpmPackage` function.

# Errors

Currently fails with:

```
$ nix develop --option eval-cache false
warning: Git tree '/Users/nhooey/git/github/nhooey/cljs-shadow-cljs-demo' is dirty
error: attribute 'currentSystem' missing

       at /nix/store/kx92sy1aa13bnh65f26f1fqbzq8x0i3z-source/flake.nix:12:16:

           11|     let
           12|       system = builtins.currentSystem; # This will be "aarch64-darwin" for you
             |                ^
           13|       pkgs = nixpkgs.legacyPackages.${system};

```
