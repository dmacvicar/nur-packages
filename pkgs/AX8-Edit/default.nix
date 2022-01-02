{ stdenv, wine, icoutils, xvfb-run, imagemagick, makeWrapper, fetchurl, makeDesktopItem, lib }:

let
  desktopFile = makeDesktopItem {
    name = "AX8-Edit";
    desktopName = "AX8-Edit";
    genericName="AX8 guitar effects processor utility";
    icon = "AX8-Edit.png";
    exec = "AX8-Edit";
    type = "Application";
    categories = "AudioVideo;Recorder;AudioVideo";
  };
in
stdenv.mkDerivation {
  name = "AX8-Edit-1.9.1";

  buildInputs = [
    wine
  ];

  nativeBuildInputs = [
    xvfb-run
    imagemagick
    icoutils
    makeWrapper
  ];

  preBuild = ''
  '';

  src = fetchurl {
    url = "http://www.fractalaudio.com/downloads/ax8-edit/AX8-Edit-Win-v1p9p1.exe";
    sha256 = "dc35e0971c36fdb5ebb3e344013b6b1ba52b53c39dcfa7300b4aeec3ea4e6b85";
  };

  unpackPhase = ''
    cp $src AX8-Edit-Win.exe
  '';

  installPhase = ''
  # Do not popup asking for Mono for .NET
  export WINEDLLOVERRIDES="mscoree=;winemenubuilder.exe="

  mkdir -p $out
  export WINEPREFIX=$out
  # wine: ... is not owned by you, refusing to create a configuration directory there
  chown $(whoami) $out

  # Run the installer under a virtual X11
  xvfb-run ${wine}/bin/wine ./AX8-Edit-Win.exe /VERYSILENT /SUPPRESSMSGBOXES /SP- /NOICONS

  mv "$out/drive_c/Program Files/Fractal Audio" "$out/FractalAudio"

  # we need to do something with this uggly icon
  ${icoutils}/bin/wrestool -x -t 14 "$out/FractalAudio/AX8-Edit/AX8-Edit.exe" > icon.ico
  nIcon=6
  for s in 16x16 32x32 48x48 256x256; do
    kIcon=$((nIcon++))
    mkdir -p $out/share/icons/hicolor/$s/apps
    convert "icon.ico[$kIcon]" -thumbnail $s -flatten $out/share/icons/hicolor/$s/apps/AX8-Edit.png
  done

  # cant't use makeWrapper as it puts HOME behind single quotes
  mkdir -p $out/bin
  cat << EOF > $out/bin/AX8-Edit
  export WINEDLLOVERRIDES=""
  export WINEPREFIX="\$HOME/.ax8-edit"
  ${wine}/bin/wine "$out/FractalAudio/AX8-Edit/AX8-Edit.exe"
  EOF
  chmod +x $out/bin/AX8-Edit

  install -Dm644 "${desktopFile}/share/applications/"* \
    -t $out/share/applications/
  '';

  meta = with lib; {
    homepage = "https://www.fractalaudio.com/ax8-edit/";
    downloadPage = "https://www.fractalaudio.com/ax8-downloads/";
    description = ''
    Software editor/librarian for the AX8 Amp Modeler + Multi-Fx Pedalboard
    '';
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };

}
