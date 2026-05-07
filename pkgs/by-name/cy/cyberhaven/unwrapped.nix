{
  stdenv,
  requireFile,
  autoPatchelfHook,
  dpkg,
  openssl,
  libgcc,
  xz,
  zlib,
  bzip2,
  keyutils,
}:
stdenv.mkDerivation rec {
  pname = "cyberhaven-unwrapped";
  version = "24.09.03.91";
  ref = "0dbc90";

  src = requireFile {
    name = "Cyberhaven-${version}-${ref}.deb";
    url = "https://drive.google.com/drive/folders/12cIRewEoypqr0f5jmAXMW_iXZumTLf9h";
    sha256 = "dfc1553ad831599d23854150d9ac5f38e4b0826fbfc038d3916b1eee844fe119";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    openssl
    libgcc.lib
    xz
    zlib
    bzip2
    keyutils.lib
  ];

  installPhase = ''
    runHook preInstall
    dpkg -X $src $out
    rm $out/opt/cyberhaven/lib/libcyberhavennet-legacy.so
    runHook postInstall
  '';

  passthru = {
    inherit ref;
  };
}
