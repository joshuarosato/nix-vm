# nix-vm

Minimal NixOS flake config for testing inside VMs. Uses [disko](https://github.com/nix-community/disko) for declarative disk partitioning and [Home Manager](https://github.com/nix-community/home-manager) for user environment management.

## What's included

- Single `ext4` root partition + EFI boot on `/dev/vda`
- User `joshua` with sudo access (password: `nixos`)
- SSH open on port 22 with password auth
- Home Manager wired up for the `joshua` user
- Nix flakes enabled

## Installation

Boot into a NixOS live ISO, then run:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/joshuarosato/nix-vm/main/install.sh)"
```

Or clone the repo and run the script directly:

```bash
git clone https://github.com/joshuarosato/nix-vm
sudo bash nix-vm/install.sh
```

The script will:
1. Clone this repo to `/tmp/nix-vm`
2. Partition and format `/dev/vda` using disko
3. Generate a hardware configuration for the current machine
4. Install NixOS from the flake

Reboot once it completes.

## Manual steps

If you prefer to run each step yourself:

```bash
# 1. Partition and format the disk (destructive)
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- --mode disko ./disko-config.nix

# 2. Generate hardware config
sudo nixos-generate-config --no-filesystems --root /mnt

# 3. Copy the generated hardware config into the repo
cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

# 4. Install
sudo nixos-install --flake .#nixos --no-root-passwd
```

## After install

SSH in with:

```
ssh joshua@<vm-ip>
password: nixos
```

Root login is disabled. Use `sudo` for privileged operations.

## Extending

- **System packages / services** — edit `configuration.nix`
- **User environment** (dotfiles, user packages) — edit `home.nix`
- **Disk layout** — edit `disko-config.nix` (re-partitioning is destructive)
