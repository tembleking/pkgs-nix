{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "openapi-changes";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "pb33f";
    repo = "openapi-changes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uo2gT9vJOaYmZpDMgMNPZwMgl0WhBpw4gC0YI48iRaQ=";
  };

  vendorHash = "sha256-m+0/R7uvvHyKfzCOVa8I7LUPY2C6V8DDwVZ89EYGQG4=";

  env.CGO_ENABLED = 0;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "World's most powerful OpenAPI breaking changes detector";
    homepage = "https://pb33f.io/openapi-changes/";
    license = lib.licenses.asl20;
    mainProgram = "openapi-changes";
  };
})
