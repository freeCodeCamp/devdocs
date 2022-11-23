{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gems = pkgs.bundlerEnv {
          name = "devdocs-gems";
          gemdir = ./.;
        };
        tools = [ gems gems.wrappedRuby ];
      in
      {
        devShells = {
          make-gemset = pkgs.mkShell {
            buildInputs = tools;
            shellHook = ''
              bundle install
              bundix
            '';
          };
          default = pkgs.mkShell
            {
              buildInputs = tools;
              shellHook = ''
                bundle exec thor docs:download --default
                bundle exec rackup
              '';
            };
        };
      });
}
