{ lib, config, pkgs, inputs, outputs, ... }:

{
  # You can import other NixOS modules here
  imports = (builtins.attrValues outputs.nixosModules);

  nixpkgs = {
    # You can add overlays here
    overlays = (builtins.attrValues outputs.overlays) ++ [
      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Time
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Paris";
  };

  #networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.nameservers = [  ];
  services.resolved = {
    enable = true;
    fallbackDns = [ "8.8.8.8" ];
    # domains = [  ];
  };

  #i18n
  i18n = {
    defaultLocale = "fr_FR.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "fr";

  #journald size
  services.journald = {
    extraConfig = ''
      SystemMaxUse=512MB
      RuntimeMaxUse=512MB
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sylvain = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "sylvain";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];
  programs.zsh.enable = true;

  # List services that you want to enable:

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = lib.mkDefault {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
