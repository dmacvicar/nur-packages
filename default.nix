{ pkgs ? import <nixpkgs> { } }:

{
  AX8-Edit = pkgs.callPackage ./pkgs/AX8-Edit { };
  salt = pkgs.callPackage ./pkgs/salt { };
}
