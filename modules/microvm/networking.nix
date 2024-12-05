# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  bridgeNetBase = "192.168.101";
  cfg = config.ghaf.host.networking;
  sshKeysHelper = pkgs.callPackage ../../packages/ssh-keys-helper {
    inherit pkgs;
    inherit config;
  };
  updateSources = import ../host/updater.nix;
  routes = lib.map (entry:
    { Destination = "${entry.ip}/32"; Gateway = "${bridgeNetBase}.1"; }
  ) updateSources.updateSourcesEntries;
in
{
  options.ghaf.host.networking = {
    enable = lib.mkEnableOption "Host networking";
    # TODO add options to configure the network, e.g. ip addr etc
  };

  config = lib.mkIf cfg.enable {
    networking = {
      enableIPv6 = false;
      useNetworkd = true;
      interfaces.virbr0.useDHCP = false;
    };

    systemd.network = {
      netdevs."10-virbr0".netdevConfig = {
        Kind = "bridge";
        Name = "virbr0";
        #      MACAddress = "02:00:00:02:02:02";
      };
      networks."10-virbr0" = {
        matchConfig.Name = "virbr0";
        networkConfig.DHCPServer = false;
        addresses = [ { Address = "${bridgeNetBase}.2/24"; } ];
        routes = routes;
      };
      # Connect VM tun/tap device to the bridge
      # TODO configure this based on IF the netvm is enabled
      networks."11-netvm" = {
        matchConfig.Name = "tap-*";
        networkConfig.Bridge = "virbr0";
      };
    };

    environment.etc = {
      ${config.ghaf.security.sshKeys.getAuthKeysFilePathInEtc} = sshKeysHelper.getAuthKeysSource;
    };

    services.openssh = config.ghaf.security.sshKeys.sshAuthorizedKeysCommand;
  };
}
