set dotenv-load

default:
    just --list

rebuild *args="":
    bash -c 'sudo nixos-rebuild switch {{ args }} |& nom'

build:
     nix build '/etc/nixos/#nixosConfigurations.titan-linux.config.system.build.toplevel --impure'
