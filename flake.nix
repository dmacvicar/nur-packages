{
  description = " My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-src.url = "github:emacs-mirror/emacs/emacs-29";
    emacs-src.flake = false;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, emacs-overlay, emacs-src, flake-utils }: let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in rec {
    packages = forAllSystems (system: import ./default.nix {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          emacs-overlay.overlays.default
	        (final : prev: {
            emacs29 = prev.emacsGit.overrideAttrs (old: {
              name = "emacs29";
              # It's important this starts with the major number for Nix's
              # Emacs infra.  For example, it's used to blank out archaic
              # versions of the Seq package in MELPA.
              version = "29.0-${emacs-src.shortRev}";
              src = emacs-src;
              withPgtk = true;
            }); 
          })
        ];
      };
    });
  };
}
