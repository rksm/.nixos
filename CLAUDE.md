# Overview

nixos configuration for the following systems:

at ./flake.nix:
- storm: My main workstation
- titan-linux: Older workstation, used for batch jobs and computation intensive tasks
- tuxedo: Laptop

at ./macos/flake.nix:
- airy: Macbook Air 2025
- Roberts-MacBook-Pro: Macbook Pro 2019

# Commands

```shell
# Apply and switch the nixos configuration (either at ./ or ./macos/)
just switch

# Only build the configuration and apply it with the next build (at ./)
just switch build
```

# File structure

```
.
├── justfile
├── flake.nix
├── hosts
│   ├── storm
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   ├── titan-linux
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   └── tuxedo
│       ├── default.nix
│       ├── hardware-configuration.nix
│       ├── home.nix
│       └── nvidia-tuxedo.nix
├── macos
│   ├── flake.nix
│   ├── hosts
│   │   ├── airy
│   │   │   ├── default.nix
│   │   │   ├── home
│   │   │   │   ├── default.nix
│   │   │   │   ├── devenv.nix
│   │   │   │   ├── devops.nix
│   │   │   │   └── rust.nix
│   │   │   └── packages.nix
│   │   └── Roberts-MacBook-Pro
│   │       ├── default.nix
│   │       ├── home
│   │       │   ├── default.nix
│   │       │   ├── devenv.nix
│   │       │   ├── devops.nix
│   │       │   ├── firefox.nix
│   │       │   └── rust.nix
│   │       ├── infra.nix
│   │       └── packages.nix
│   └── justfile
├── packages                                 # vendored packages
│   └── awesome-tiles
└── shared
    ├── linux                                # nixos Linux configuration
    │   ├── audio-video-image-editing.nix
    │   ├── default.nix
    │   ├── docker.nix
    │   ├── fhs.nix
    │   ├── firefox.nix
    │   ├── gaming.nix
    │   ├── linux.nix
    │   ├── mullvad.nix
    │   ├── network.nix
    │   ├── nix-cache.nix
    │   ├── nvidia.nix
    │   ├── packages.nix
    │   ├── postgres.nix
    │   ├── printing.nix
    │   ├── ssh.nix
    │   ├── syncthing.nix
    │   ├── tailscale.nix
    │   ├── users.nix
    │   └── virtualization.nix
    ├── linux-home                             # home-manager configuration for linux
    │   ├── default.nix
    │   ├── devenv.nix
    │   ├── devops.nix
    │   ├── emacs.nix
    │   ├── gnome.nix
    │   ├── packages
    │   │   └── awesome-tiles.nix
    │   ├── packages.nix
    │   └── rust.nix
    └── secrets                                 # git crypt secrets
```
