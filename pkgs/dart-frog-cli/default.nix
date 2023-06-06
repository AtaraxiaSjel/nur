{ lib
, buildDartApplication
, fetchFromGitHub
}:

buildDartApplication rec {
  pname = "dart-frog-cli";
  version = "0.3.7";
  src = fetchFromGitHub {
    owner = "VeryGoodOpenSource";
    repo = "dart_frog";
    rev = "dart_frog_cli-v${version}";
    hash = "sha256-z5tDaIPVNPPmlc2e70T1i9B9KVfdz8wROCYZc8/GogQ=";
  };

  sourceRoot = "source/packages/dart_frog_cli";

  pubspecLockFile = ./pubspec.lock;
  vendorHash = "sha256-jNXiG84bAdTl0MttsiXU8VAd+Tpy05YekZ6o1MdEZkk=";

  meta = with lib; {
    description = "The official command line interface for Dart Frog.";
    homepage = "https://github.com/VeryGoodOpenSource/dart_frog/packages/dart_frog_cli";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "dart_frog";
  };
}