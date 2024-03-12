{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # # rust
    # rustup
    # sccache
    # cargo
    # rustc
    # llvmPackages.bintools
    # clang
    # pkg-config
    # openssl
    # mold-wrapped
  ];

  # To build rust packages that in turn pull in / build binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];


  # environment.sessionVariables = {
  #   RUSTC_VERSION = "${pkgs.rustc.version}";
  #   LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
  #   # Add precompiled library to rustc search path
  #   RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
  #     # add libraries here (e.g. pkgs.libvmi)
  #   ]);
  #   # Add glibc, clang, glib, and other headers to bindgen search path
  #   BINDGEN_EXTRA_CLANG_ARGS =
  #     # Includes normal include path
  #     (builtins.map (a: ''-I"${a}/include"'') [
  #       # add dev libraries here (e.g. pkgs.libvmi.dev)
  #       pkgs.glibc.dev
  #     ])
  #     # Includes with special directory paths
  #     ++ [
  #       ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
  #       ''-I"${pkgs.glib.dev}/include/glib-2.0"''
  #       ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
  #     ];
  # };

}
