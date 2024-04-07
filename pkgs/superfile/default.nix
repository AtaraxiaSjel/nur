{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, exiftool
, nix-update-script
}:

buildGoModule rec {
  pname = "superfile";
  version = "v1.0.0";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = version;
    hash = "sha256-FDsEzmFshwT3ZhIwS0YmhzAVVTbamvok2yco3A0mB3Q=";
  } + "/src";

  vendorHash = "sha256-i4OB9z8GapihAXn5k4pRpdZ5ICF544EUOstqnoO2xKM=";

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
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
