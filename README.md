# NixOs-Config
My NixOs Configuration and note to quickly bootstrap my dev environnement

## In WSL nix Image : 
Copy the flake.nix to /etc/nixos/
## Bootstrap the flake : 
```
sudo nixos-rebuild boot  --extra-experimental-features nix-command --extra-experimental-features flakes --flake
```
```
wsl -t NixOs
wsl -d NixOS --user root exit
wsl -t NixOs
wsl --shutdown 
```
