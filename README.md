# NixOs-Config
My NixOs Configuration and note to quickly bootstrap my dev environnement

## Enable flakes

Add this to your `/etc/nix/configuration.nix`
```nix
    # /etc/nix/configuration.nix
    # ....
    
    imports = [
      # ...
      ./system-customisation.nix
    ];
    
    #...
```

Copy the `system-customisation.nix` file in this repository to your `/etc/nix/` directory.

## Enable home-manager:
