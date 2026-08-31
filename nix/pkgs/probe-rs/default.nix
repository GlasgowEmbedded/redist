{
  fetchFromGitHub,
  lib,
  nasm,
  rustPlatform,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "probe-rs";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-C6ioLkU0tmCzWtThPGyOOiD/Z9n8RB5eogAxTmBwDj8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      "nusb-0.2.7" = "sha256-Mo1Od6MHVkxgrI1sLaOfzZ95LGI7U6a48wguTzysbbE=";
    };
  };

  nativeBuildInputs = [
    nasm
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  # Required by libgcc_eh and rustc doesn't add it automatically.
  env = lib.optionalAttrs stdenv.hostPlatform.isx86_32 {
    RUSTFLAGS = "-C link-arg=-lmcfgthread";
  };
}
