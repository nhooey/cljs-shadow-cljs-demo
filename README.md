# cljs-shadow-cljs-demo

Example ClojureScript `shadow-cljs` project packaged with Nix Flakes, using `clj-nix` and the `buildNpmPackage` function.

# Errors

Currently fails with:

```
$ nix develop

error:
       … while calling the 'derivationStrict' builtin

         at /builtin/derivation.nix:9:12: (source not available)

       … while evaluating derivation 'nix-shell'
         whose name attribute is located at /nix/store/i5zbq5by44gz4w1v0kwdcv2d8vacqhd1-source/pkgs/stdenv/generic/make-derivation.nix:468:13

       … while evaluating attribute '__impureHostDeps' of derivation 'nix-shell'

         at /nix/store/i5zbq5by44gz4w1v0kwdcv2d8vacqhd1-source/pkgs/stdenv/generic/make-derivation.nix:626:15:

          625|               );
          626|               __impureHostDeps =
             |               ^
          627|                 computedImpureHostDeps

       error: attribute 'aarch64-darwin' missing

       at /nix/store/0iradjngplq6dy6arh75mnwm2sv96kli-source/flake.nix:14:19:

           13|         pkgs = nixpkgs.legacyPackages.${system};
           14|         cljpkgs = clj-nix.lib.${system};
             |                   ^
           15|
```
