{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "openapi-changes";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "pb33f";
    repo = "openapi-changes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BxHvIq4BMMuSXn2XGAK5ndlKXOAMrT2Pon9eY1kVv8Y=";
  };

  vendorHash = "sha256-jXyM25EEDSMsyiu4+dK9KmYjYc0RgvdwBmTu/9rssAs=";

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
