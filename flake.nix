{
  description = "A simple ClojureScript demo with shadow-cljs and Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = nixpkgs.lib.systems.flakeExposed;

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f pkgsFor.${system});

      pkgsFor = nixpkgs.lib.genAttrs supportedSystems (system:
        import nixpkgs {
          inherit system;
        });
    in
    {
      devShells = nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jdk21
              nodejs
              clojure
            ];

            shellHook = ''
              echo "Entering ClojureScript development shell for ${pkgs.system}."
              echo "To start shadow-cljs, run: clj -M:cljs watch app"
              echo "Then open http://localhost:8000 in your browser."
            '';
          };
        }
      );
    };
}
