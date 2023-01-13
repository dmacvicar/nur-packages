{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-src.url = "github:emacs-mirror/emacs/emacs-29";
    emacs-src.flake = false;

  };

  outputs = { self, nixpkgs, flake-utils, emacs-overlay, emacs-src,... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
            inherit system;
            overlays = [
              emacs-overlay.overlays.default
              (final: prev: {
                emacs29 = (prev.emacsGit.override {
                  withPgtk = true;
                  withX = false;
                  withWebP = true;
                  withGTK2 = false;
                }).overrideAttrs(old: {
                  name = "emacs29";
                  version = "29.0-${emacs-src.shortRev}";
                  src = emacs-src;
                });
              })];
          };
      in rec {

        packages.AX8-Edit = pkgs.callPackage ./pkgs/AX8-Edit { };
        packages.emacs29 = pkgs.emacs29;
      });
}
