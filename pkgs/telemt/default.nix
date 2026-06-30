{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.4.22";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-LTWdeYLOZpq6bde5LhK9pCcGN+n1MenP8rmpuoHNOM8=";
  };

  cargoHash = "sha256-QnL0GqFppIS2Q51o7IS/RKho4Fja/fyLX2S4yIn4zaA=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MTProxy for Telegram on Rust + Tokio";
    homepage = "https://github.com/telemt/telemt";
    license = licenses.unfree;
    mainProgram = "telemt";
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = platforms.linux;
  };
})
