{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
  nix-update-script,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "sing-box";
  version = "1.15.0-alpha.8";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g456S8Pw9GYm0E48fNUAg840r+MinxKTpbcIzQKhniA=";
  };

  vendorHash = "sha256-1xP8RLU0/ZP6j8DbNiPaI0Pnw6PpBNp2hsTTE4U+PWQ=";

  env = {
    CGO_ENABLED = 0;
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
    # CGO required, enable separately with CGO_ENABLED=1
    # "with_embedded_tor"
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
    "badlinkname"
    "tfogo_checklinkname0"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  nativeBuildInputs = [ installShellFiles ];

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
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "unstable"
        "--version-regex"
        "v(.*-(?:alpha|beta|rc).*)"
      ];
    };
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
