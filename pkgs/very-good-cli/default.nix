{ lib
, buildDartApplication
, fetchFromGitHub
, nix-update-script
}:

buildDartApplication rec {
  pname = "very-good-cli";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "VeryGoodOpenSource";
    repo = "very_good_cli";
    rev = "v${version}";
    hash = "sha256-A5A5CsXcuvnaazf3pDw3nxosjpZIF1NIHxjn8JmtrYg=";
  };

  pubspecLockFile = ./pubspec.lock;
  vendorHash = "sha256-at0+kUtdcIkzCkj47GA9vXxb2nA4WA5Yu3TG+tsKjQA=";

  # passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A Very Good Command-Line Interface for Dart";
    homepage = "https://github.com/VeryGoodOpenSource/very_good_cli";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "very_good";
    broken = true; # problems with isolated url's in aot
  };
}