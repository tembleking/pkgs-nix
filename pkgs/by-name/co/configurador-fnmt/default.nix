{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  jre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "configuradorfnmt";
  version = "5.1.2";

  src = fetchurl {
    url = "https://descargas.cert.fnmt.es/Linux/configuradorfnmt_${finalAttrs.version}.amd64.deb";
    hash = "sha256-kAVzQ3hNbfi7rZ3OexO1O8W1i2wbb6WXuwixbX8CtgY=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir unpacked

    dpkg-deb --fsys-tarfile "$src" \
      | tar -x \
          --no-same-owner \
          --no-same-permissions \
          -C unpacked

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"

    # Flatten Debian /usr layout into Nix $out
    if [ ! -d unpacked/usr ]; then
      echo "error: Debian package does not contain /usr" >&2
      exit 1
    fi
    cp -a unpacked/usr/. "$out/"

    substituteInPlace "$out/bin/configuradorfnmt" \
      --replace-fail "cd /usr/lib/configuradorfnmt" \
                     "cd $out/lib/configuradorfnmt" \
      --replace-fail "/usr/lib/configuradorfnmt/jre/bin/java" \
                     "${jre}/bin/java" \
      --replace-fail '$*' '"$@"'

    substituteInPlace "$out/share/applications/configuradorfnmt.desktop" \
      --replace-fail "Exec=/usr/bin/configuradorfnmt" "Exec=$out/bin/configuradorfnmt" \
      --replace-fail "Icon=/usr/lib/configuradorfnmt/configuradorfnmt.png" \
                     "Icon=$out/lib/configuradorfnmt/configuradorfnmt.png"

    # # Normalize ownership/perms for Nix store
    # chmod -R u+rwX,go+rX "$out"
    # find "$out" -type d -exec chmod 755 {} \;
    # find "$out" -type f -perm -111 -exec chmod 755 {} \;

    # Ensure java visible
    if [ -d "$out/bin" ]; then
      for exe in "$out"/bin/*; do
        [ -f "$exe" ] || continue
        [ -x "$exe" ] || continue

        wrapProgram "$exe" \
          --prefix PATH : ${lib.makeBinPath [ jre ]}
      done
    fi

    runHook postInstall
  '';

  meta = {
    description = "Configurador FNMT-RCM para generación de claves";
    homepage = "https://www.sede.fnmt.gob.es";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    mainProgram = "configuradorfnmt";
    maintainers = [ ];
  };
})
