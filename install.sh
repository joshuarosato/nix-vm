#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/joshuarosato/nix-vm"
REPO_DIR="/tmp/nix-vm"

if [[ $EUID -ne 0 ]]; then
  echo "error: run as root (e.g. sudo bash install.sh)" >&2
  exit 1
fi

# 1. Clone the repo
echo "==> Cloning $REPO_URL..."
rm -rf "$REPO_DIR"
git clone "$REPO_URL" "$REPO_DIR"
cd "$REPO_DIR"

# 2. Partition and format disks
echo "==> Partitioning disks with disko..."
nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- --mode disko ./disko-config.nix

# 3. Generate hardware config (no filesystem entries — disko owns those)
echo "==> Generating hardware configuration..."
nixos-generate-config --no-filesystems --root /mnt

# 4. Pull the generated hardware config into the repo
echo "==> Copying hardware-configuration.nix..."
cp /mnt/etc/nixos/hardware-configuration.nix "$REPO_DIR/hardware-configuration.nix"

# 5. Install
# --no-root-passwd: root login is disabled in the config; use the joshua user
# (password: nixos) over SSH or at the console instead.
echo "==> Installing NixOS..."
nixos-install --flake "$REPO_DIR#nixos" --no-root-passwd

echo ""
echo "==> Done. Reboot to start your new system."
echo "    SSH: ssh joshua@<vm-ip>  (password: nixos)"
