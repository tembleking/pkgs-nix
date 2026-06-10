{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  unzip,
  jdk17,
  nssTools,
  openssl,
  coreutils,
  gnugrep,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "autofirma";
  version = "1.9.0";

  src = fetchurl {
    url = "https://firmaelectronica.gob.es/content/dam/firmaelectronica/descargas-software/autofirma19/Autofirma_Linux_Debian.zip";
    hash = "sha256-wpwlHy7p8A38h/lYJnfb1DaoNWWYarBBf/Blzq5xZ5g=";
  };

  nativeBuildInputs = [
    dpkg
    unzip
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    unzip "$src"
    dpkg-deb -x autofirma_1_9.deb unpacked

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a unpacked/usr/. "$out/"

    rm "$out/bin/autofirma" "$out/bin/autofirmacl"

    install -Dm755 ${./autofirma.sh} "$out/bin/autofirma"
    substituteInPlace "$out/bin/autofirma" \
      --replace-fail '@cat@' '${coreutils}/bin/cat' \
      --replace-fail '@certutil@' '${nssTools}/bin/certutil' \
      --replace-fail '@chmod@' '${coreutils}/bin/chmod' \
      --replace-fail '@grep@' '${gnugrep}/bin/grep' \
      --replace-fail '@install@' '${coreutils}/bin/install' \
      --replace-fail '@java@' '${jdk17}/bin/java' \
      --replace-fail '@mkdir@' '${coreutils}/bin/mkdir' \
      --replace-fail '@mktemp@' '${coreutils}/bin/mktemp' \
      --replace-fail '@openssl@' '${openssl}/bin/openssl' \
      --replace-fail '@printf@' '${coreutils}/bin/printf' \
      --replace-fail '@rm@' '${coreutils}/bin/rm' \
      --replace-fail '@touch@' '${coreutils}/bin/touch' \
      --replace-fail '@autofirmaJar@' "$out/lib/Autofirma/autofirma.jar"

    substitute "$out/bin/autofirma" "$out/bin/autofirmacl" \
      --replace-fail 'exec ${jdk17}/bin/java' \
                     'exec ${jdk17}/bin/java -Dafirma_debug_level=OFF'

    find "$out" -type d -exec chmod 755 {} +
    find "$out" -type f -exec chmod 644 {} +
    chmod 755 "$out/bin/autofirma" "$out/bin/autofirmacl"

    substituteInPlace "$out/share/applications/afirma.desktop" \
      --replace-fail "Exec=/usr/bin/autofirma" "Exec=$out/bin/autofirma" \
      --replace-fail "Icon=/usr/lib/Autofirma/Autofirma.png" \
                     "Icon=$out/lib/Autofirma/Autofirma.png"

    substituteInPlace "$out/share/metainfo/es.gob.afirma.metainfo.xml" \
      --replace-fail "/usr/share/Autofirma/Autofirma.svg" \
                     "$out/share/Autofirma/Autofirma.svg"

    runHook postInstall
  '';

  meta = {
    description = "Electronic signature application from the Government of Spain";
    homepage = "https://firmaelectronica.gob.es/Home/Descargas.html";
    license = with lib.licenses; [
      eupl11
      gpl2Only
    ];
    platforms = lib.platforms.linux;
    mainProgram = "autofirma";
    maintainers = [ ];
  };
})
