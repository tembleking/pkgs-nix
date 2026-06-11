{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "openapi-changes";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "pb33f";
    repo = "openapi-changes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4A23zA5i/9s2lWYyV4Ek9yM/uy9xinMzaUJ6LKYmpyc=";
  };

  vendorHash = "sha256-G252IFG3q7u0Kncm8rVPgYsl2eYo+udgRsj97AnQ99M=";

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
