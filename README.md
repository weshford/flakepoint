# flakepoint

run flashpoint as a nixflake with the help of [buildFHSEnv](https://nixos.org/manual/nixpkgs/unstable/#sec-fhs-environments) (tjis should handle all libraries dependencies etc)

---

## run once

```bash
nix run github:weshford/flakepoint
```

## installation

add it in your flake

```
flakepoint = {
  url = "github:weshford/flakepoint";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

you can then add it to your overlays so that its available with pkgs.flakepoint directly

`flakepoint = flakepoint.packages.${system}.default;`

then just normally add it to your system:

```
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    flakepoint
  ];
}

# or

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    flakepoint
  ];
}

# or whatever
```

You can also install it to your proflie:

`nix profile install github:weshford/flakepoint`

you don't need to build it yourself either, there exists a cached built already on cachix. (i think) to use it, add it to your config.nix.

```
nix.settings = {
  substituters = [
    "https://cache.nixos.org/"
    "https://weshford.cachix.org/"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "weshford.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
  ];
};
```