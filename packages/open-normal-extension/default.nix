# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  stdenvNoCC,
  pkgs,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "open-normal-extension";

  src = ./.;

  buildInputs = [
    pkgs.gettext
    pkgs.gnused
  ];

  postInstall = ''
    mkdir -p "$out"
    cp -v ./manifest.json ./open_normal.js ./open_normal.sh "$out"
    chmod a+x "$out/open_normal.sh"
    # Replace $out in json file with actual path
    ${pkgs.gettext}/bin/envsubst < "./fi.ssrc.open_normal.json" > "$out/fi.ssrc.open_normal.json"
    # Remove comments from the .json file (those are not allowed in .json, but our automatic checks require them)
    ${pkgs.gnused}/bin/sed -i '/^\s*\/\//d' "$out/fi.ssrc.open_normal.json"
    # Note that comments are explicitly allowed in manifest.json
  '';

  meta = with lib; {
    description = "Browser extension for Chromium to launch trusted browser";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
