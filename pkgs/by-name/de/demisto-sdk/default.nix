{
  python3Packages,
  fetchPypi,
  lib,
  nix-update-script,
}:
python3Packages.buildPythonApplication rec {
  pname = "demisto-sdk";
  version = "1.39.4";
  format = "wheel";

  src = fetchPypi {
    pname = "demisto_sdk";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-ZYgw22RUFBr3J6mLBgwmsw7xrdpBZXgLQBWj0wIeHQU=";
  };

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    autopep8
    bandit
    beautifulsoup4
    chardet
    coloredlogs
    configparser
    coverage
    dateparser
    decorator
    demisto-py
    dictdiffer
    docker
    flatten-dict
    gitpython
    giturlparse
    google-cloud-secret-manager
    google-cloud-storage
    imagesize
    inflection
    importlib-resources
    jira
    junitparser
    json5
    jsonschema
    loguru
    lxml
    mergedeep
    more-itertools
    mypy
    neo4j
    networkx
    nltk
    orjson
    ordered-set
    packaging
    paramiko
    pebble
    prettytable
    pydantic_1
    pygithub
    pykwalify
    pylint
    pypdf2
    pytest
    pyspellchecker
    python-dateutil
    python-dotenv
    python-gitlab
    requests
    ruamel-yaml
    setuptools
    slack-sdk
    tabulate
    tenacity
    toml
    typer
    typing-extensions
    ujson
    urllib3
    vulture
    wcmatch
    werkzeug
    yamlordereddictloader
  ];

  dontCheckRuntimeDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" "--url" "https://github.com/demisto/demisto-sdk" ];
  };

  meta = {
    description = "Demisto SDK for building XSOAR content";
    homepage = "https://github.com/demisto/demisto-sdk";
    license = lib.licenses.mit;
    mainProgram = "demisto-sdk";
  };
}
