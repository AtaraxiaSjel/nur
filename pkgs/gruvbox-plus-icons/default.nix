{
  lib,
  stdenv,
  fetchFromGitHub,
  jdupes,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "gruvbox-plus-icons";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "v${version}";
    hash = "sha256-PT8s4YFvL8YAZpDFSEsDT05S5yLInVOvvcGJIN1TIPU=";
  };

  dontBuild = true;

  nativeBuildInputs = [ jdupes ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -r Gruvbox* $out/share/icons

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Gruvbox Plus icon pack for Linux desktops based on Gruvbox color theme";
    homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
