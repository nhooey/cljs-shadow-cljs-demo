{
  description = "A ClojureScript project with shadow-cljs, packaged with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs = { self, nixpkgs, flake-utils, clj-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cljpkgs = clj-nix.lib.${system};

        projectName = "cljs-shadow-demo";
        projectVersion = "0.1.0";

        npmDeps = pkgs.callPackage (import ./nix/npm-deps.nix) {
          src = ./.;
        };

        cljDeps = cljpkgs.mkDeps {
          src = ./.;
          deps = ./deps.edn;
          # Ensure shadow-cljs is available on the classpath for clj-nix
          # This should match the version in deps.edn
          clojureDeps = {
            "thheller/shadow-cljs" = "2.28.22";
          };
        };

      in
      {
        packages.default = with pkgs; stdenv.mkDerivation {
          pname = projectName;
          version = projectVersion;
          src = ./.;

          buildInputs = with pkgs; [
            nodejs_20
            jdk21
          ];

          nativeBuildInputs = with pkgs; [
            clojure
            npm
          ];

          buildPhase = ''
            export HOME=$(mktemp -d)

            ln -s ${npmDeps}/lib/node_modules ./node_modules

            mkdir -p .clojure
            ln -s ${cljDeps.depsCache} .clojure/deps

            echo "Building ClojureScript project with shadow-cljs..."
            ${cljpkgs.clojure-env}/bin/clojure -M -m shadow.cljs.devtools.cli release app
          '';

          installPhase = ''
            mkdir -p $out/bin $out/share/${projectName}
            cp -r public $out/share/${projectName}/public
            cp -r resources/public/js $out/share/${projectName}/public/js
          '';

          # passthru.devShell is correct here for a single devShell within the derivation.
          # The devShells.default below is for the top-level flake output.
          passthru = {
            devShell = with pkgs; mkShell {
              inputsFrom = [ npmDeps cljDeps ];
              buildInputs = with pkgs; [
                nodejs_20
                jdk21
                clojure
                npm
              ];
              shellHook = ''
                echo "Welcome to the ClojureScript development shell!"
                echo "You can run 'npx shadow-cljs watch app' to start development server."
                echo "Or 'clojure -M -m shadow.cljs.devtools.cli watch app'"
                export CLJ_JAVA_OPTS="-Dclojure.core.async.pool-size=10"
              '';
            };
          };
        };
        # This is the correct top-level devShells output for eachDefaultSystem
        devShells.default = with pkgs; mkShell {
          inputsFrom = [ npmDeps cljDeps ];
          buildInputs = with pkgs; [
            nodejs_20
            jdk21
            clojure
            npm
          ];
          shellHook = ''
            echo "Welcome to the ClojureScript development shell!"
            echo "You can run 'npx shadow-cljs watch app' to start development server."
            echo "Or 'clojure -M -m shadow.cljs.devtools.cli watch app'"
            export CLJ_JAVA_OPTS="-Dclojure.core.async.pool-size=10"
          '';
        };
      }
    );
}
