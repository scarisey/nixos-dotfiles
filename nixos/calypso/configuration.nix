{
  inputs,
  outputs,
  lib,
  config,
  ...
}: let
  mac = "02:00:00:00:0a:02";
  tap = "vm-calypso";
  disks = "/data/disk2/vms/calypso-disks";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.microvm.nixosModules.microvm
    ../common.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sylvain = import ../../home-manager/sylvain/x86_64-linux/calypso/home.nix;
    extraSpecialArgs = {inherit inputs outputs;};
  };
  microvm = {
    hypervisor = "qemu";
    vcpu = 6;
    mem = 16384;
    # Without a writable store overlay, microvm.nix disables nix-daemon,
    # and home-manager activation (which needs a working nix) fails at boot.
    writableStoreOverlay = "/nix/.rw-store";
    volumes = [
      {
        image = "${disks}/nix-store-overlay.img";
        mountPoint = config.microvm.writableStoreOverlay;
        size = 20480;
      }
    ];
    interfaces = [
      {
        type = "tap";
        id = tap;
        inherit mac;
      }
    ];
    shares = [
      {
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "virtiofs";
        tag = "data";
        source = "/data/disk2/vms/calypso";
        mountPoint = "/data";
      }
    ];
  };

  networking = {
    hostName = "calypso";
    enableIPv6 = false;
    useNetworkd = true;
    useDHCP = false;
    firewall.allowedTCPPorts = [22];
  };

  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = mac;
    address = ["10.10.10.2/24"];
    routes = [{Gateway = "10.10.10.1";}];
    networkConfig = {
      DNS = ["192.168.1.1"];
      DHCP = "no";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  systemd.tmpfiles.rules = [
    "d /data/secrets 0700 sylvain users -"
  ];

  # Incompatible with microvm.writableStoreOverlay
  nix.settings.auto-optimise-store = lib.mkForce false;
}
