set dotenv-load

default:
    just --list

rebuild:
    bash -c 'sudo nixos-rebuild switch --impure |& nom'
