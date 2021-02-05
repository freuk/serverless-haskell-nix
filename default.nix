{ pkgs ? import (builtins.fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") { } }:
let

  lambda-zip = binpath:
    pkgs.stdenv.mkDerivation {
      name = "lambda-zip";
      buildCommand = ''
        pushd `mktemp -d`
        cp ${
          pkgs.writeScript "bootstrap" ''
            #!/bin/sh
            LD_LIBRARY_PATH=$LAMBDA_TASK_ROOT/lib ./exe
          ''
        } bootstrap
        cp ${binpath} exe
        mkdir lib
        cp `ldd exe | grep -F '=> /' | awk '{print $3}'` lib/
        cp `${pkgs.patchelf}/bin/patchelf --print-interpreter exe` lib/ld.so
        chmod +w exe
        ${pkgs.patchelf}/bin/patchelf --set-interpreter lib/ld.so exe
        ${pkgs.patchelf}/bin/patchelf --set-rpath lib exe
        chmod -w exe
        ${pkgs.zip}/bin/zip -r -9 out.zip ./
        mv out.zip $out
      '';
    };

  lambda-container = binpath:
    pkgs.dockerTools.buildImage {
      name = "lambda";
      tag = "nix";
      config = {
        Entrypoint = [ (pkgs.writeShellScript "entrypoint" "$@") ];
        Cmd = [ binpath ];
      };
    };

in rec {
  lambda = pkgs.haskellPackages.callCabal2nix "lambda" ./. { };
  container = lambda-container "${lambda}/bin/lambda";
  zip = lambda-zip "${lambda}/bin/lambda";
}
