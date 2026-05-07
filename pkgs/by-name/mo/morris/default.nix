{
  stdenv,
  autoreconfHook,
  pkg-config,
  intltool,
  gettext,
  libtool,
  gtk2,
  glib,
  boost,
  wrapGAppsHook3,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "morris";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "farindk";
    repo = "morris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ow6dWJOB3OHYL5JQoy1VpJaG9WlO2fNwPnX59+e1bM4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    intltool
    gettext
    libtool
    wrapGAppsHook3
    glib
  ];

  buildInputs = [
    gtk2
    glib
    boost
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
  ];

  preAutoreconf = ''
    export ACLOCAL_PATH="${gettext}/share/gettext/m4''${ACLOCAL_PATH:+:$ACLOCAL_PATH}"
  '';

  env.NIX_CFLAGS_COMPILE = "-O0";
})
