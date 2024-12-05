# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Modules that should be only imported to host
#
{ lib, ... }:
let
  updateSources = import ./updater.nix;
in
{
  networking.hostName = lib.mkDefault "ghaf-host";
  networking.hosts = lib.foldl' (acc: entry:
    acc // { "${entry.ip}" = entry.hostname; }
  ) {} updateSources.updateSourcesEntries;

  # Overlays should be only defined for host, because microvm.nix uses the
  # pkgs that already has overlays in place. Otherwise the overlay will be
  # applied twice.
  nixpkgs.overlays = [ (import ../../overlays/custom-packages) ];
  imports = [
    # To push logs to central location
    ../common/logging/client.nix
  ];
}
