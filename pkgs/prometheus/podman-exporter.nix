{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  btrfs-progs,
  gpgme,
  lvm2,
  nix-update-script,
}:

buildGoModule rec {
  pname = "prometheus-podman-exporter";
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-e/69iOlsnumxv+jChuDRkj9zjliEsommZiQOMs2+2Cg=";
  };

  vendorHash = null;

  ldflags =
    let
      pkg = "github.com/containers/prometheus-podman-exporter";
    in
    [
      "-X ${pkg}/cmd.buildVersion=${version}"
      "-X ${pkg}/cmd.buildRevision=${src.rev}"
      "-X ${pkg}/cmd.buildBranch=unknown"
    ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    btrfs-progs
    gpgme
    lvm2
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Prometheus exporter for podman environments exposing containers, pods, images, volumes and networks information.";
    homepage = "https://github.com/containers/prometheus-podman-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "prometheus-podman-exporter";
  };
}
