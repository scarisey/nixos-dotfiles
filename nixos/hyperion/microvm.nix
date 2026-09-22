{
  inputs,
  pkgs,
  ...
}: let
  vmName = "calypso";
  tap = "vm-calypso";
  hostAddress = "10.10.10.1/24";
  shareDir = "/data/disk2/vms/calypso";
in {
  imports = [inputs.microvm.nixosModules.host];

  microvm.vms.${vmName} = {
    flake = inputs.self;
    autostart = true;
  };

  systemd.tmpfiles.rules = [
    "d /data/disk2/vms 0755 root root -"
    "d ${shareDir} 0755 root root -"
  ];

  networking.networkmanager.unmanaged = ["interface-name:${tap}"];
  networking.nat.internalInterfaces = [tap];

  systemd.services."microvm-tap-address@${vmName}" = {
    description = "Host address of the point to point link to MicroVM ${vmName}";
    requires = ["microvm-tap-interfaces@${vmName}.service"];
    after = ["microvm-tap-interfaces@${vmName}.service"];
    before = ["microvm@${vmName}.service"];
    partOf = ["microvm@${vmName}.service"];
    wantedBy = ["microvm@${vmName}.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip address replace ${hostAddress} dev ${tap}
      ${pkgs.iproute2}/bin/ip link set ${tap} up
    '';
  };
}
