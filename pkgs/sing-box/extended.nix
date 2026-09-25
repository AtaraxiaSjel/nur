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

buildGoModule (finalAttrs: {
  pname = "sing-box-extended";
  version = "1.14.1-extended-2.7.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "shtorm-7";
    repo = "sing-box-extended";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bDE90wcoTLBm3lDICO+z7Kl+hhIXBYZN5lsrLXQbL10=";
  };

  # same for both variants: `go mod vendor` already includes tag-gated
  # imports (e.g. cronet-go behind with_naive_outbound)
  vendorHash = "sha256-fR6ZlkSBiM0EiGwd6mWQ07p+gMnYuhugai4x4SsUNiU=";

  env = {
    CGO_ENABLED = if withCGO then 1 else 0;
  }
  // lib.optionalAttrs withCGO {
    # cronet's prebuilt static lib is only linkable with lld (bfd ld rejects
    # the archive); same as upstream's `build-naive env` (CGO_LDFLAGS=-fuse-ld=lld)
    CGO_LDFLAGS = "-fuse-ld=lld";
  };

  tags = [
    "with_gvisor"
    "with_quic"
    "with_grpc"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_v2ray_api"
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
    # extended-specific, all non-CGO
    "with_masque"
    "with_mtproxy"
    "with_trusttunnel"
    "with_call"
    "with_sudoku"
    "with_manager"
    # with_admin_panel needs service/admin_panel/dist generated via
    # `make build_admin_panel` (npm + cmd/internal/admin_panel_pack),
    # not checked into git. Wire up later with a frontend build.
    # "with_admin_panel"
    "with_profiler"
    # NOTE: with_embedded_tor no longer exists in upstream code (only mentioned
    # in docs; the fork's tor support is identical to upstream's), so
    # with_naive_outbound is the only CGO-gated tag. In CGO mode cronet links
    # against the prebuilt static lib shipped in the cronet-go/lib/* Go
    # modules, no Chromium toolchain needed.
    "badlinkname"
    "tfogo_checklinkname0"
  ]
  ++ lib.optionals withCGO [ "with_naive_outbound" ];

  subPackages = [
    "cmd/sing-box"
  ];

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals withCGO [ lld ];

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
    "-X=runtime.godebugDefault=multipathtcp=0,tlssha1=1"
    "-checklinkname=0"
  ];

  # no tests in sandbox (matches nixpkgs sing-box)
  doCheck = false;

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests = { inherit (nixosTests) sing-box; };
  };

  meta = {
    homepage = "https://github.com/shtorm-7/sing-box-extended";
    description = "Universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "sing-box";
  };
})
