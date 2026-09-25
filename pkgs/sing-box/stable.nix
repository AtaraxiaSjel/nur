{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
  lld,
  nix-update-script,
  nixosTests,
  withCGO ? false,
}:

import ./common.nix {
  inherit
    lib
    buildGoModule
    fetchFromGitHub
    installShellFiles
    coreutils
    lld
    nix-update-script
    nixosTests
    withCGO
    ;

  pname = "sing-box";
  version = "1.14.2";
  homepage = "https://sing-box.sagernet.org";
  src = {
    owner = "SagerNet";
    repo = "sing-box";
    hash = "sha256-KoJj5nn0d7uxs5x4arG1p3KGkDmaFAJKiVJ5M5vYxcU=";
  };
  vendorHash = "sha256-DJNYQeCgAouLvpA8caZ0ILi9RYV82wteV6tR3gj+sfI=";
}
