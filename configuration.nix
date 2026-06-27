{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.nix-index-database.nixosModules.default
  ];

  # Bootloader setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # User configuration
  users.users.joshua = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  # Minimal packages requested
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    rsync
    nh
    neovim
  ];

  # Home Manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.joshua = import ./home.nix;

  # SSH
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable nix-index and its command-not-found integration
  programs.nix-index.enable = true;

  # Disable the default NixOS command-not-found to prevent conflicts
  programs.command-not-found.enable = false;

  # Necessary for Flakes to work after install
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
