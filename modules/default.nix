{
  authentik = ./authentik.nix;
  homepage = ./homepage.nix;
  hoyolab = ./hoyolab.nix;
  kes = ./kes.nix;
  ocis = ./ocis.nix;
  prometheus-exporters = import ./prometheus-exporters;
  rustic = ./rustic.nix;
  wopiserver = ./wopiserver.nix;
}
