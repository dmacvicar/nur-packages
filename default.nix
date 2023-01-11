# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
{
  AX8-Edit = pkgs.callPackage ./pkgs/AX8-Edit { };
  emacs29 = pkgs.emacs29;
}
