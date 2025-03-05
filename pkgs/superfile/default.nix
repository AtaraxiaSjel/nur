{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  exiftool,
  nix-update-script,
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.2.0.0";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-cbDfo+2rwNk4s/YhKhyQvpI4T9CseGyWGtc55ofyBT0=";
  };

  vendorHash = "sha256-I/x2iB/DY5vIrhq54f843iqLc/tFD+ov1AFZvUrh49E=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/superfile \
      --prefix PATH : ${lib.makeBinPath [ exiftool ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/MHNightCat/superfile";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "superfile";
  };
}
