{ pkgs ? import (builtins.fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") { } }:
rec {
  lambda = pkgs.haskellPackages.callCabal2nix "lambda" ./. { };
  lambda-container = pkgs.dockerTools.buildImage {
    name = "lambda";
    tag = "nix";
    config = {
      Entrypoint = [ (pkgs.writeShellScript "entrypoint" "$@") ];
      Cmd = [ "${lambda}/bin/lambda" ];
    };
  };
}
