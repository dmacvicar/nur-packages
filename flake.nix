{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
            inherit system;
          };
      in rec {
        packages.google-cloud-sdk = pkgs.google-cloud-sdk.withExtraComponents ([ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ]);
        packages.AX8-Edit = pkgs.callPackage ./pkgs/AX8-Edit { };
      });
}
