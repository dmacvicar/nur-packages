{
  description = "Rust flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crate2nix = {
      url = "github:kolloch/crate2nix";
      # if you use git dependencies with branches in Cargo.toml, use this fork
      # https://github.com/kolloch/crate2nix/issues/205
      #url = "github:yusdacra/crate2nix/feat/builtinfetchgit";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crate2nix, ... }:
    let
      # If you change the name here, you must also do it in Cargo.toml
      name = "CHANGE-ME";
      rustChannel = "stable";
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          # Imports
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              rust-overlay.overlay
              (self: super: {
                # Because rust-overlay bundles multiple rust packages into one
                # derivation, specify that mega-bundle here, so that crate2nix
                # will use them automatically.
                rustc = self.rust-bin.${rustChannel}.latest.default;
                cargo = self.rust-bin.${rustChannel}.latest.default;
              })
            ];
          };
          inherit (import "${crate2nix}/tools.nix" { inherit pkgs; })
            generatedCargoNix;

          # Create the cargo2nix project
          project = pkgs.callPackage
            (generatedCargoNix {
              inherit name;
              src = ./.;
            })
            {
              # Individual crate overrides go here
              # Example: https://github.com/balsoft/simple-osd-daemons/blob/6f85144934c0c1382c7a4d3a2bbb80106776e270/flake.nix#L28-L50
              defaultCrateOverrides = pkgs.defaultCrateOverrides // {
                # The himalaya crate itself is overriden here. Typically we
                # configure non-Rust dependencies (see below) here.
                ${name} = oldAttrs: {
                  inherit buildInputs nativeBuildInputs;
                };
              };
            };

          # Configuration for the non-Rust dependencies
          buildInputs = with pkgs; [ openssl.dev ];
          nativeBuildInputs = with pkgs; [ rustc cargo pkgconfig ];
        in
        rec {
          packages.${name} = project.rootCrate.build;

          # `nix build`
          defaultPackage = packages.${name};

          # `nix run`
          apps.${name} = utils.lib.mkApp {
            inherit name;
            drv = packages.${name};
          };
          defaultApp = apps.${name};

          # `nix develop`
          devShell = pkgs.mkShell
            {
              inputsFrom = builtins.attrValues self.packages.${system};
              buildInputs = buildInputs ++ (with pkgs;
                # Tools you need for development go here.
                [
                  cargo-watch
                  pkgs.rust-bin.${rustChannel}.latest.rust-analysis
                ]);
              RUST_SRC_PATH = "${pkgs.rust-bin.${rustChannel}.latest.rust-src}/lib/rustlib/src/rust/library";
            };
        }
      ) // {
      overlay = final: prev: {
        ${name} = self.defaultPackage.${prev.system};
      };
    };
}
