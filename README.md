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
