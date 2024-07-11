# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  python3Packages,
  pkgs,
  fetchFromGitHub,
}: let
  qemuqmp = pkgs.callPackage ../qemuqmp {};
in
  python3Packages.buildPythonApplication rec {
    pname = "vhotplug";
    version = "0.1";

    propagatedBuildInputs = [
      python3Packages.pyudev
      python3Packages.psutil
      qemuqmp
    ];

    doCheck = false;

    src = fetchFromGitHub {
      owner = "tiiuae";
      repo = "vhotplug";
      rev = "e7605188b273e51616c68894199441e5325fd58c";
      hash = "sha256-zvXfpcYehw3kp8qa5g9BIhnPmF65TPUJRuKfHWqaEkE=";
    };
  }
