# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.hardware.usb.vhotplug;
  inherit (lib) mkEnableOption mkOption types mkIf literalExpression;

  vhotplug = pkgs.callPackage ../../../../packages/vhotplug {};
in {
  options.ghaf.hardware.usb.vhotplug = {
    enable = mkEnableOption "Enable hot plugging of USB devices";

    rules = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "List of virtual machines with USB hot plugging rules.";
      example = literalExpression ''
        [
         {
            name = "GUIVM";
            qmpSocket = "/var/lib/microvms/gui-vm/gui-vm.sock";
            usbPassthrough = [
              {
                class = 3;
                protocol = 1;
                description = "HID Keyboard";

                ignore = [
                  {
                    vid = "046d";
                    pid = "c52b";
                    description = "Logitech, Inc. Unifying Receiver";
                  }
                ];
              },
              {
                vid = "067b";
                pid = "23a3";
                description = "Prolific Technology, Inc. USB-Serial Controller";
                disable = true;
              }
            ];
          }
        ];
      '';
    };
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", GROUP="kvm"
      KERNEL=="event*", GROUP="kvm"
    '';

    environment.etc."vhotplug.conf".text = builtins.toJSON {vms = cfg.rules;};

    systemd.services.vhotplug = {
      enable = true;
      description = "vhotplug";
      wantedBy = ["microvms.target"];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
        ExecStart = "${vhotplug}/bin/vhotplug -a -c /etc/vhotplug.conf";
      };
      startLimitIntervalSec = 0;
    };
  };
}
