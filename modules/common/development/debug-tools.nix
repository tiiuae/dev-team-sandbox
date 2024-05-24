# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.development.debug.tools;
in
  with lib; {
    options.ghaf.development.debug.tools = {
      enable = mkEnableOption "Debug Tools";
    };

    config = mkIf cfg.enable {
      environment.etc = {
        audio_test.source = ./audio_test;
      };
      environment.systemPackages = with pkgs;
        [
          # For lspci:
          pciutils

          # For lsusb:
          usbutils

          # Useful in NetVM
          ethtool

          # Basic monitors
          htop
          iftop
          iotop

          traceroute
          dig
          evtest

          # For deleting Linux Boot Manager entries in automated testing
          efibootmgr

          # Performance testing
          speedtest-cli
          iperf
          # Match perf version with kernel.
          config.boot.kernelPackages.perf

          # gRPC inter- and intra-vm testing
          grpcurl
        ]
        # TODO Can this be changed to platformPkgs to filter ?
        # LuaJIT (which is sysbench dependency) not available on RISC-V
        ++ lib.optional (config.nixpkgs.hostPlatform.system != "riscv64-linux") sysbench
        # runtimeShell (unixbench dependency) not available on RISC-V nor on cross-compiled Orin AGX/NX
        ++ lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) unixbench
        # Build VLC only on x86
        ++ lib.optional (config.nixpkgs.hostPlatform.system == "x86_64-linux") vlc;
    };
  }
