{
  buildPythonPackage,
  fetchPypi,
  lib,
  pythonRelaxDepsHook,
  certifi,
  six,
  python-dateutil,
  urllib3,
  tzlocal,
  setuptools,
}:
buildPythonPackage rec {
  pname = "demisto-py";
  version = "3.2.22";
  format = "wheel";

  src = fetchPypi {
    pname = "demisto_py";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-1GUD7tgIp/sATR6fc/diNPlONs4aBT5LVhNn6iK0PT0=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = true;

  dependencies = [
    certifi
    six
    python-dateutil
    urllib3
    tzlocal
    setuptools
  ];

  meta = {
    description = "Demisto Client for Python";
    homepage = "https://github.com/demisto/demisto-py";
    license = lib.licenses.asl20;
  };
}
