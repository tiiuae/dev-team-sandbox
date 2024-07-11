# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  powerControl = pkgs.callPackage ../../packages/powercontrol {};
  cfg = config.ghaf.profiles.laptop-x86;
  listenerAddress = config.ghaf.logging.listener.address;
  listenerPort = toString config.ghaf.logging.listener.port;
in {
  imports = [
    ../desktop/graphics
    ../common
    ../host
    #TODO how to reference the miocrovm module here?
    #self.nixosModules.microvm
    #../microvm
    ../hardware/x86_64-generic
    ../hardware/common
    ../hardware/definition.nix
    ../lanzaboote
  ];

  options.ghaf.profiles.laptop-x86 = {
    enable = lib.mkEnableOption "Enable the basic x86 laptop config";

    netvmExtraModules = lib.mkOption {
      description = ''
        List of additional modules to be passed to the netvm.
      '';
      default = [];
    };

    guivmExtraModules = lib.mkOption {
      description = ''
        List of additional modules to be passed to the guivm.
      '';
      default = [];
    };

    enabled-app-vms = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = ''
        List of appvms to include in the Ghaf reference appvms module
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    security.polkit = {
      enable = true;
      extraConfig = powerControl.polkitExtraConfig;
    };

    ghaf = {
      # Hardware definitions
      hardware = {
        x86_64.common.enable = true;
        tpm2.enable = true;
        usb.internal.enable = true;
        usb.external.enable = true;
      };

      # Virtualization options
      virtualization = {
        microvm-host = {
          enable = true;
          networkSupport = true;
        };

        microvm = {
          netvm = {
            enable = true;
            wifi = true;
            extraModules = cfg.netvmExtraModules;
          };

          adminvm = {
            enable = true;
          };

          idsvm = {
            enable = false;
            mitmproxy.enable = false;
          };

          guivm = {
            enable = true;
            extraModules = cfg.guivmExtraModules;
          };

          audiovm = {
            enable = true;
            audio = true;
          };

          appvm = {
            enable = true;
            vms = cfg.enabled-app-vms;
          };
        };
      };

      host = {
        networking.enable = true;
        powercontrol.enable = true;
      };

      # UI applications
      # TODO fix this when defining desktop and apps
      profiles = {
        applications.enable = false;
      };

      # Logging configuration
      logging.client.enable = true;
      logging.client.endpoint = "http://${listenerAddress}:${listenerPort}/loki/api/v1/push";
      logging.listener.address = "admin-vm-debug";
      logging.listener.port = 9999;

      # USB hot plugging configuration
      hardware.usb.vhotplug = {
        enable = true;
        rules = [
          {
            name = "GUIVM";
            qmpSocket = "/var/lib/microvms/gui-vm/gui-vm.sock";
            usbPassthrough = [
              {
                class = 3;
                protocol = 1;
                description = "HID Keyboard";
              }
              {
                class = 3;
                protocol = 2;
                description = "HID Mouse";
              }
              {
                class = 11;
                description = "Chip/SmartCard (e.g. YubiKey)";
              }
              {
                class = 8;
                sublass = 6;
                description = "Mass Storage - SCSI (USB drives)";
                # Currently disabled to leave USB drives connected to the host
                disable = true;
              }
            ];
            evdevPassthrough = {
              enable = true;
              pcieBusPrefix = "rp";
            };
          }
          {
            name = "NetVM";
            qmpSocket = "/var/lib/microvms/net-vm/net-vm.sock";
            usbPassthrough = [
              {
                class = 2;
                sublass = 6;
                description = "Communications - Ethernet Networking";
                # Currently disabled to avoid breaking remote nixos-rebuild,
                # which requires an Ethernet adapter connected to the host
                disable = true;
              }
            ];
          }
          {
            name = "AudioVM";
            qmpSocket = "/var/lib/microvms/audio-vm/audio-vm.sock";
            usbPassthrough = [
              {
                class = 1;
                descripton = "Audio";
              }
            ];
          }
        ];
      };
    };
  };
}
