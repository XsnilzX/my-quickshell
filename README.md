# my-quickshell

My Own quickshell

## How to Start (manual)

```bash
qs --path src/shell.qml
```

## Home Manager (flake)

Add this repo as an input in your main flake and import the exported module.

```nix
{
  inputs.my-quickshell.url = "github:XsnilzX/my-quickshell";

  outputs = { home-manager, my-quickshell, ... }: {
    homeConfigurations.<user> = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        my-quickshell.homeManagerModules.default
        {
          programs.myQuickshell.enable = true;
        }
      ];
    };
  };
}
```

Optional settings:

```nix
{
  programs.myQuickshell = {
    enable = true;
    autoStart = true;
    workspaceBackend = "hyprland"; # or "niri"
    startNmApplet = false;
    startBluemanApplet = false;
    enableGoather = true;

    # Optional override (default comes from input goather = github:XsnilzX/goather)
    # goatherPackage = inputs.goather.packages.${pkgs.system}.default;

    extraPackages = [];
  };
}
```

With `workspaceBackend = "niri"`, the workspace widget shows indexes `1..N` for the focused monitor.

Apply:

```bash
home-manager switch --flake .#<user>
```
