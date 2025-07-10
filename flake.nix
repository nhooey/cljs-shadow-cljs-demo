{
  description = "A ClojureScript project with shadow-cljs, packaged with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix"; # Main branch
  };

  outputs = { self, nixpkgs, flake-utils, clj-nix }:
    let
      system = builtins.currentSystem; # This will be "aarch64-darwin" for you
      pkgs = nixpkgs.legacyPackages.${system};
      cljpkgs = clj-nix.lib.${system};

      projectName = "cljs-shadow-demo";
      projectVersion = "0.1.0";

      npmDeps = pkgs.callPackages (import ./nix/npm-deps.nix) {
        src = ./.;
      };

      # Define the Clojure/ClojureScript application derivation using mkCljBin
      # This function internally handles deps.edn and classpath
      cljApp = cljpkgs.mkCljBin {
        # Required attributes for mkCljBin
        projectSrc = ./.;
        name = "${projectName}"; # Name for the Clojure app
        version = projectVersion;
        main-ns = "cljs-shadow-cljs-demo.core"; # Replace with your actual main namespace in deps.edn
        # (Optional) You can specify buildCommand if you need a custom build step
        # buildCommand = "clj -T:build uber"; # Example: if you have a build task

        # clojureDeps are typically managed by deps.edn, but can be provided here
        # clj-nix will automatically resolve dependencies from deps.edn and deps-lock.json
        # The shadow-cljs dependency is handled via deps.edn and the deps-lock.json.
        # You shouldn't need to specify clojureDeps here unless you're adding something
        # not in your project's deps.edn.
        # However, to ensure shadow-cljs is available on classpath during build,
        # it needs to be in your project's deps.edn.
      };

    in
    {
      packages.${system}.default = with pkgs; stdenv.mkDerivation {
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
          cljApp # Add the cljApp derivation to nativeBuildInputs to get its environment
        ];

        buildPhase = ''
          export HOME=$(mktemp -d)

          # Link npm dependencies
          ln -s ${npmDeps}/lib/node_modules ./node_modules

          # clj-nix's mkCljBin should provide a pre-prepared classpath.
          # You might not need to manually link .clojure/deps if cljApp manages it.
          # However, shadow-cljs often needs the full classpath, so let's use cljApp's classpath.
          # If cljApp exports a classpath, you'd use that.
          # For a shadow-cljs project, you often need the clojure command with the resolved classpath.
          # cljApp derivation doesn't directly expose 'depsCache' or similar.
          # Instead, it provides the clojure-env and the generated jar.
          # The key is to get the classpath correctly for shadow-cljs.
          # clj-nix exports a `clojure-env` helper.
          echo "Building ClojureScript project with shadow-cljs..."
          # Use clj-nix's clojure-env to ensure the correct classpath for shadow-cljs
          # This assumes shadow.cljs.devtools.cli is executable via clojure-env
          ${cljApp.clojure-env}/bin/clojure -M -m shadow.cljs.devtools.cli release app
        '';

        installPhase = ''
          mkdir -p $out/bin $out/share/${projectName}
          cp -r public $out/share/${projectName}/public
          cp -r resources/public/js $out/share/${projectName}/public/js
        '';
      };

      devShells.${system}.default = with pkgs; mkShell {
        # inputsFrom = [ npmDeps cljDeps ]; -- Remove cljDeps as it's no longer a direct input
        inputsFrom = [ npmDeps cljApp ]; # Use cljApp here for its environment
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

          # Ensure cljApp's environment (including classpath for clojure/shadow-cljs) is available
          export PATH=${cljApp.clojure-env}/bin:$PATH
          export CLASSPATH=$(find ${cljApp.classpath} -name "*.jar" | paste -sd ":" -)
        '';
      };
    };
}
