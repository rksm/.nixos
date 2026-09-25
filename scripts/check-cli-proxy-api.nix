# Run from the repository root: nix eval --impure --json --file scripts/check-cli-proxy-api.nix
let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  check =
    machine: localProxy:
    let
      system = flake.nixosConfigurations.${machine};
      evaluated =
        if localProxy == null then
          system
        else
          system.extendModules {
            modules = [ { home-manager.users.robert.services.cli-proxy-api.enableLocal = localProxy; } ];
          };
      home = evaluated.config.home-manager.users.robert;
      enabled = if localProxy == null then machine == "agent-1" else localProxy;
      wrappers = builtins.filter (
        p:
        builtins.elem (p.name or "") [
          "claude-commands"
          "codex-commands"
          "grok-commands"
        ]
      ) home.home.packages;
      endpoint = if enabled then "http://127.0.0.1:8317" else "http://agent-1.taileff843.ts.net:8317";
    in
    assert home.services.cli-proxy-api.enableLocal == enabled;
    assert (home.systemd.user.services ? cli-proxy-api) == enabled;
    assert (home.home.file ? ".cli-proxy-api/auths") == enabled;
    assert (home.home.file ? ".cli-proxy-api/config.yaml") == enabled;
    assert (home.home.activation ? cliProxyApiAuthDir) == enabled;
    assert builtins.elem evaluated.pkgs.cliproxyapi home.home.packages == enabled;
    assert builtins.length wrappers == 3;
    assert builtins.all (p: lib.hasInfix endpoint p.buildCommand) wrappers;
    assert builtins.all (
      p: lib.hasInfix "systemctl --user is-active" p.buildCommand == enabled
    ) wrappers;
    assert
      (evaluated.config.systemd.services ? tailscale-serve-cli-proxy-api)
      == (machine == "agent-1" && enabled);
    true;
in
{
  defaults = lib.genAttrs [ "storm" "tuxedo" "agent-1" ] (machine: check machine null);
  localFallback = lib.genAttrs [ "storm" "tuxedo" ] (machine: check machine true);
  disabledServer = check "agent-1" false;
}
