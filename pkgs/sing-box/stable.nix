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
  pname = "sing-box";
  version = "1.14.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KoJj5nn0d7uxs5x4arG1p3KGkDmaFAJKiVJ5M5vYxcU=";
  };

  # same for both variants: `go mod vendor` already includes tag-gated
  # imports (e.g. cronet-go behind with_naive_outbound)
  vendorHash = "sha256-DJNYQeCgAouLvpA8caZ0ILi9RYV82wteV6tR3gj+sfI=";

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
    # NOTE: with_embedded_tor no longer exists in upstream code as of 1.14.2
    # (only mentioned in docs), so with_naive_outbound is the only CGO-gated
    # tag. In CGO mode cronet links against the prebuilt static lib shipped
    # in the cronet-go/lib/* Go modules, no Chromium toolchain needed.
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
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
    homepage = "https://sing-box.sagernet.org";
    description = "Universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "sing-box";
  };
})
