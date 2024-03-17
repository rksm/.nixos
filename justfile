switch:
    # impure b/c hosts/Roberts-MacBook-Pro/packages.nix access abs path
    darwin-rebuild switch --impure --flake .#Roberts-MacBook-Pro
