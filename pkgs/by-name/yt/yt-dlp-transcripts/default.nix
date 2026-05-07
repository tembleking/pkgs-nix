{
  python3Packages,
  fetchPypi,
  lib,
}:
python3Packages.buildPythonApplication {
  pname = "yt-dlp-transcripts";
  version = "0.1.1";
  pyproject = true;

  src = fetchPypi {
    pname = "yt_dlp_transcripts";
    version = "0.1.1";
    hash = "sha256-dCDJdhL6uM7qVWKr3b4HTqWJDKXhcpW7tGtHXYbHV1E=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    yt-dlp
    youtube-transcript-api
    click
  ];

  meta = {
    description = "Extract video info and transcripts from YouTube";
    homepage = "https://github.com/LinuxIsCool/yt-dlp-transcripts";
    license = lib.licenses.mit;
    mainProgram = "yt-dlp-transcripts";
  };
}
