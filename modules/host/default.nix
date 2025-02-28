# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Modules that should be only imported to host
#
{ lib, ... }:
{
  networking.hostName = lib.mkDefault "ghaf-host";

  # Overlays should be only defined for host, because microvm.nix uses the
  # pkgs that already has overlays in place. Otherwise the overlay will be
  # applied twice.
  nixpkgs.overlays = [ (import ../../overlays/custom-packages) ];

  ghaf.services.wireguard-gui = {
    enable = true;
    vms = [
      "chrome"
      "business"
    ];
  };

  imports = [
    # To push logs to central location
    ../common/services/wireguard-gui.nix
    ../common/logging/client.nix
  ];
}
