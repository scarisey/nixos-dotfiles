{inputs, outputs, ...}: let
  mac = "02:00:00:00:0a:02";
  tap = "vm-calypso";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.microvm.nixosModules.microvm
    ../common.nix
  ];

  home-manager = {
    enable = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sylvain = import ../../home-manager/sylvain/x86_64-linux/calypso/home.nix;
    extraSpecialArgs = { inherit inputs outputs; };
  };
  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 16384;
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
}
